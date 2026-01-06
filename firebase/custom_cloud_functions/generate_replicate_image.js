const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// 모델 정의
// 1. 프로필: Animagine XL 4.0 (애니메이션 퀄리티 최상)
const ANIMAGINE_XL_4_VERSION =
  "7af46ee494f1cf196d49a8592737f4eb789e34a5a995751b23a869d19f5dc2ba";
// 2. 감정: InstantID (얼굴 고정 특화)
const INSTANT_ID_VERSION =
  "5225e059ede1d8378c27ea6e859fa95c3ade3d3b1e7aad19d8ddfa9890972f1b";

exports.generateReplicateImage = functions
  .runWith({
    // secrets: ["REPLICATE_API_KEY"], // ★ [배포 에러 원인 1] 제거 (기존 환경설정 사용)
    timeoutSeconds: 540,
    memory: "1GB",
    // minInstances: 1, // ★ [배포 에러 원인 2] 제거 (Spark 요금제 호환성 이슈 방지)
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) return { success: false, error: "로그인이 필요합니다." };

    try {
      const userId = context.auth.uid;
      const rawMode = data.mode || "character";
      const mode = String(rawMode).trim().toLowerCase();
      const promptInput = data.prompt || "";
      const characterImageUrl = data.characterImageUrl;

      // URL 변환 헬퍼
      const getValidUrl = async (url) => {
        if (!url || url.length < 5) return null;
        if (url.startsWith("http")) return url;
        try {
          const bucket = admin.storage().bucket();
          let path = url.startsWith("gs://")
            ? url.split("/").slice(3).join("/")
            : url;
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

      // 입력값 분리
      const parseEmotionInput = (raw) => {
        const s = (raw || "").trim();
        if (!s) return { key: "", extra: "" };
        const firstSpace = s.indexOf(" ");
        if (firstSpace === -1) return { key: s, extra: "" };
        return {
          key: s.slice(0, firstSpace).trim(),
          extra: s.slice(firstSpace + 1).trim(),
        };
      };

      const emotionMap = {
        기쁨: "joyful smile, happy expression, laughing",
        슬픔: "sad face, crying, tears",
        화남: "angry expression, frowning, rage",
        분노: "angry, furious, shouting",
        놀람: "surprised face, wide eyes, open mouth",
        두려움: "scared, fearful, pale",
        혐오: "disgusted, grimace",
        중립: "neutral expression, calm",
      };

      let version;
      let inputData;

      // -----------------------------------------------------
      // 1. 캐릭터(프로필) 생성
      // -----------------------------------------------------
      if (mode === "character") {
        version = ANIMAGINE_XL_4_VERSION;
        inputData = {
          // 얼굴 인식을 위해 상반신/인물화 강제
          prompt: `1girl, masterpiece, best quality, anime style, portrait, upper body, focus on face, ${promptInput}`,
          negative_prompt:
            "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, full body, wide shot",
          num_inference_steps: 25,
          guidance_scale: 7,
          width: 1024,
          height: 1024,
        };
      }
      // -----------------------------------------------------
      // 2. 감정 생성 (InstantID)
      // -----------------------------------------------------
      else if (mode === "emotion") {
        version = INSTANT_ID_VERSION;

        const validUrl = await getValidUrl(characterImageUrl);
        if (!validUrl)
          throw new Error(
            "감정 생성을 위해서는 원본 캐릭터 이미지가 필수입니다.",
          );

        const { key, extra } = parseEmotionInput(promptInput);
        const emotionDesc = emotionMap[key] || key;

        const finalPrompt = `anime style, flat color, cel shaded, ${emotionDesc}, ${extra}, upper body, same character identity, high quality`;

        inputData = {
          image: validUrl, // 참조 이미지
          prompt: finalPrompt,
          negative_prompt:
            "lowres, bad anatomy, bad hands, text, error, cropped, worst quality, low quality, normal quality, jpeg artifacts, blurry, different face, realistic, 3d, photorealistic, nsfw",

          // ★ [핵심] 얼굴 고정 파라미터 상향 (1.0 = 최대)
          identity_scale: 1.0,
          ip_adapter_scale: 0.8,
          instantid_weight: 0.8,

          // ★ [속도 개선] LCM 적용 (빠른 생성)
          steps: 8, // 'num_inference_steps' -> 'steps'
          cfg: 1.5, // 'guidance_scale' -> 'cfg'

          width: 1024,
          height: 1024,
        };
      }
      // -----------------------------------------------------
      // 3. 상황 생성
      // -----------------------------------------------------
      else if (mode === "situation") {
        throw new Error("상황 생성은 별도 구현 필요");
      } else {
        throw new Error("유효하지 않은 모드입니다.");
      }

      // Replicate 호출
      // ★ API Key는 secrets 대신 process.env 사용 (기존 설정이 있다면)
      // 만약 환경변수가 없다면 아래 headers 부분에 직접 키를 넣어서 테스트 해보세요.
      const response = await axios.post(
        "https://api.replicate.com/v1/predictions",
        { version: version, input: inputData },
        {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        },
      );

      let prediction = response.data;
      const getUrl = prediction.urls.get;
      let attempts = 0;

      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        if (attempts++ > 120) throw new Error("Timeout");
        await sleep(1000);
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

      let rawAiUrl = Array.isArray(prediction.output)
        ? prediction.output[0]
        : prediction.output;

      // 저장 로직
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
        return { success: true, imageUrl: rawAiUrl };
      }
    } catch (error) {
      console.error(error);
      return { success: false, error: error.message };
    }
  });
