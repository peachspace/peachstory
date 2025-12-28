const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// 모델 버전 상수 정의
const ANIMAGINE_VERSION =
  "6d17167db6b7e31a65191c51f3d3cd0f864c14aee708a66ecfbc8c4e696ad06b"; // 캐릭터 생성용
const IDEOGRAM_VERSION =
  "77d8da192375ce51fa632db399ba3765e6f08da36890f0be5e3e479e09dd79ea"; // 상황 생성용

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540,
    memory: "1GB",
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) return { success: false, error: "로그인이 필요합니다." };

    try {
      const userId = context.auth.uid;
      // ★ 핵심: 모드 분기 (기본값은 캐릭터 생성)
      const mode = data.mode || "character";
      const prompt = data.prompt || "anime style";
      let characterImageUrl = data.characterImageUrl;

      console.log(`DEBUG: 시작 Mode=${mode}, Prompt=${prompt}`);

      let version;
      let inputData;

      // ====================================================
      // [CASE 1] 캐릭터 생성 (Text-to-Image)
      // ====================================================
      if (mode === "character") {
        version = ANIMAGINE_VERSION;
        inputData = {
          prompt: `1girl, masterpiece, best quality, ${prompt}`,
          negative_prompt:
            "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry",
          width: 1024,
          height: 1024,
          guidance_scale: 7,
          num_inference_steps: 28,
        };
      }
      // ====================================================
      // [CASE 2] 상황 생성 (Image-to-Image / Reference)
      // ====================================================
      else if (mode === "situation") {
        version = IDEOGRAM_VERSION;

        // 이미지 주소 변환 (gs:// -> Signed URL)
        let validUrl = null;
        if (
          characterImageUrl &&
          typeof characterImageUrl === "string" &&
          characterImageUrl.length > 5
        ) {
          if (characterImageUrl.startsWith("http")) {
            validUrl = characterImageUrl;
          } else {
            // 경로 처리
            try {
              const bucket = admin.storage().bucket();
              let path = characterImageUrl;
              if (path.startsWith("gs://"))
                path = path.split("/").slice(3).join("/");
              const [exists] = await bucket.file(path).exists();
              if (exists) {
                const [signedUrl] = await bucket.file(path).getSignedUrl({
                  action: "read",
                  expires: Date.now() + 3600000,
                });
                validUrl = signedUrl;
              }
            } catch (e) {
              console.error("URL 변환 실패", e);
            }
          }
        }

        if (!validUrl) {
          throw new Error("상황 생성을 위해서는 캐릭터 이미지가 필수입니다.");
        }

        inputData = {
          prompt: prompt,
          character_reference_image: validUrl, // Ideogram은 이 필드를 사용
          style_type: "Fiction", // 애니메이션 스타일
          aspect_ratio: "1:1",
        };
      } else {
        throw new Error("유효하지 않은 모드입니다.");
      }

      // Replicate 호출
      const response = await axios.post(
        "https://api.replicate.com/v1/predictions",
        { version: version, input: inputData },
        {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        },
      );

      let prediction = response.data;
      const getUrl = prediction.urls.get;

      // Polling
      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        if (attempts++ > 60) throw new Error("Timeout");
        await sleep(2000);
        prediction = (
          await axios.get(getUrl, {
            headers: {
              Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            },
          })
        ).data;
      }

      if (prediction.status !== "succeeded")
        throw new Error(prediction.error || "생성 실패");

      // ★ Output 파싱 (문자열 또는 배열 처리)
      let rawAiUrl = prediction.output;
      if (Array.isArray(rawAiUrl)) rawAiUrl = rawAiUrl[0]; // 배열이면 첫번째
      if (typeof rawAiUrl !== "string")
        throw new Error("결과 URL을 찾을 수 없습니다.");

      // 서버 저장 및 반환
      try {
        const imgResp = await axios.get(rawAiUrl, {
          responseType: "arraybuffer",
        });
        const fileName = `${mode}_${Date.now()}.png`;
        const file = admin
          .storage()
          .bucket()
          .file(`users/${userId}/uploads/${fileName}`);

        await file.save(imgResp.data, {
          metadata: { contentType: "image/png" },
        });
        const [permUrl] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2100",
        });

        return { success: true, imageUrl: permUrl };
      } catch (saveErr) {
        console.error("저장 실패:", saveErr);
        return { success: true, imageUrl: rawAiUrl }; // 원본이라도 반환
      }
    } catch (error) {
      console.error("Function Error:", error);
      return { success: false, error: error.message };
    }
  });
