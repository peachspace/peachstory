const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// 모델 버전 상수 정의
const ANIMAGINE_VERSION =
  "6d17167db6b7e31a65191c51f3d3cd0f864c14aee708a66ecfbc8c4e696ad06b"; // 캐릭터 & 감정 생성용
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
      const rawMode = data.mode || "character";
      const mode = String(rawMode).trim().toLowerCase();
      const prompt = data.prompt || "anime style";
      let characterImageUrl = data.characterImageUrl;

      console.log(`DEBUG: 시작 Mode=${mode}, Prompt=${prompt}`);

      // [공통 함수] 이미지 URL 유효성 검사 및 변환 (GS -> Signed URL)
      const getValidUrl = async (url) => {
        if (!url || url.length < 5) return null;
        if (url.startsWith("http")) return url;
        try {
          const bucket = admin.storage().bucket();
          let path = url;
          if (path.startsWith("gs://"))
            path = path.split("/").slice(3).join("/");
          const [exists] = await bucket.file(path).exists();
          if (exists) {
            const [signedUrl] = await bucket.file(path).getSignedUrl({
              action: "read",
              expires: Date.now() + 3600000,
            });
            return signedUrl;
          }
        } catch (e) {
          console.error("URL 변환 실패", e);
        }
        return null;
      };

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
        const validUrl = await getValidUrl(characterImageUrl);
        if (!validUrl)
          throw new Error("상황 생성을 위해서는 캐릭터 이미지가 필수입니다.");

        inputData = {
          prompt: prompt,
          character_reference_image: validUrl,
          style_type: "Fiction",
          aspect_ratio: "1:1",
        };
      }
      // ====================================================
      // [CASE 3] 감정 생성 (Emotion / Image-to-Image)
      // ====================================================
      else if (mode === "emotion") {
        version = ANIMAGINE_VERSION;
        const validUrl = await getValidUrl(characterImageUrl);
        if (!validUrl)
          throw new Error(
            "감정 생성을 위해서는 원본 캐릭터 이미지가 필수입니다.",
          );

        inputData = {
          // 프롬프트에 감정 키워드를 강조하고 얼굴 클로즈업 유도
          prompt: `masterpiece, best quality, face shot, close up, ${prompt}, consistent character, same face`,
          negative_prompt:
            "lowres, bad anatomy, bad hands, text, error, extra digit, fewer digits, cropped, worst quality, low quality, blurry, changing hair color, changing eye color, different person",
          image: validUrl, // ★ 원본 이미지를 참조
          strength: 0.75, // ★ 0.75: 원본을 적당히 유지하면서 표정 변화 허용
          width: 1024,
          height: 1024,
          guidance_scale: 7,
          num_inference_steps: 28,
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

      // Output 파싱
      let rawAiUrl = prediction.output;
      if (Array.isArray(rawAiUrl)) rawAiUrl = rawAiUrl[0];
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
        return { success: true, imageUrl: rawAiUrl };
      }
    } catch (error) {
      console.error("Function Error:", error);
      return { success: false, error: error.message };
    }
  });
