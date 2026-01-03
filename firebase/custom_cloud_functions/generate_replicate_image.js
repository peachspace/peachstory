const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ★ 모델 정의 (둘 다 IDEOGRAM 사용 추천, 또는 얼굴 참조가 되는 모델로 통일)
const ANIMAGINE_VERSION =
  "6d17167db6b7e31a65191c51f3d3cd0f864c14aee708a66ecfbc8c4e696ad06b";
const IDEOGRAM_VERSION =
  "77d8da192375ce51fa632db399ba3765e6f08da36890f0be5e3e479e09dd79ea";

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540,
    memory: "1GB",
    minInstances: 1, // 속도 향상을 위해 1개 상시 대기
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) return { success: false, error: "로그인이 필요합니다." };

    try {
      const userId = context.auth.uid;
      // 공백/대소문자 문제 방지
      const rawMode = data.mode || "character";
      const mode = String(rawMode).trim().toLowerCase();

      const prompt = data.prompt || "anime style";
      let characterImageUrl = data.characterImageUrl;

      console.log(`DEBUG: 시작 Mode=${mode}, Prompt=${prompt}`);

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
      } else if (mode === "situation") {
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
      // ★ [수정됨] 감정 생성 로직 변경
      else if (mode === "emotion") {
        version = IDEOGRAM_VERSION; // 상황 생성과 동일한 모델 사용 (얼굴 참조 기능 활용)

        const validUrl = await getValidUrl(characterImageUrl);
        if (!validUrl)
          throw new Error(
            "감정 생성을 위해서는 원본 캐릭터 이미지가 필수입니다.",
          );

        const emotionMap = {
          기쁨: "joyful smile, happy expression",
          슬픔: "sad face, crying, tears",
          화남: "angry expression, frowning",
          놀람: "surprised face, wide eyes",
          두려움: "scared face, fearful",
          혐오: "disgusted face",
          중립: "neutral expression",
        };
        const cleanPrompt = prompt ? prompt.trim() : "";
        const emotionDesc = emotionMap[cleanPrompt] || cleanPrompt;

        inputData = {
          // ★ [수정] 'close up', 'face shot' 제거 -> 'portrait', 'upper body' 등으로 변경하여 자연스럽게
          prompt: `A high-quality anime portrait of the character, ${emotionDesc}, upper body shot, keeping the exact same face features and hair style as the reference image, consistent character design, detailed background`,
          character_reference_image: validUrl, // 얼굴 고정
          style_type: "Fiction",
          aspect_ratio: "1:1", // 필요시 비율 조정
        };
      } else {
        throw new Error("유효하지 않은 모드입니다.");
      }

      // Replicate 호출 (재시도 로직 포함 권장하지만 여기선 기본 호출)
      const response = await axios.post(
        "https://api.replicate.com/v1/predictions",
        { version: version, input: inputData },
        {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        },
      );

      // ... (이후 폴링 및 저장 로직은 기존과 동일)
      let prediction = response.data;
      const getUrl = prediction.urls.get;

      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        if (attempts++ > 120) throw new Error("Timeout"); // 타임아웃 넉넉히
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

      let rawAiUrl = prediction.output;
      if (Array.isArray(rawAiUrl)) rawAiUrl = rawAiUrl[0];
      if (typeof rawAiUrl !== "string")
        throw new Error("결과 URL을 찾을 수 없습니다.");

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
