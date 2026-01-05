const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// 모델 정의
const ANIMAGINE_XL_4_VERSION =
  "7af46ee494f1cf196d49a8592737f4eb789e34a5a995751b23a869d19f5dc2ba";
const INSTANT_ID_VERSION =
  "5225e059ede1d8378c27ea6e859fa95c3ade3d3b1e7aad19d8ddfa9890972f1b";

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540,
    memory: "1GB",
    minInstances: 1,
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) return { success: false, error: "로그인이 필요합니다." };

    try {
      const userId = context.auth.uid;
      const rawMode = data.mode || "character";
      const mode = String(rawMode).trim().toLowerCase();
      const promptInput = data.prompt || "";
      const characterImageUrl = data.characterImageUrl;

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
        기쁨: "joyful smile, happy, laughing",
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
      // 1. 캐릭터(프로필) 생성 - Animagine XL 4.0
      // -----------------------------------------------------
      if (mode === "character") {
        version = ANIMAGINE_XL_4_VERSION;
        inputData = {
          prompt: `1girl, masterpiece, best quality, anime style, portrait, upper body, focus on face, ${promptInput}`,
          negative_prompt:
            "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, full body, wide shot",

          // ★ [Animagine 파라미터]
          // Animagine은 'num_inference_steps'를 사용합니다.
          num_inference_steps: 22, // 28 -> 22 (품질 타협 없이 속도 향상)
          guidance_scale: 7,
          width: 1024,
          height: 1024,
        };
      }
      // -----------------------------------------------------
      // 2. 감정 생성 - InstantID Basic
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
          image: validUrl,
          prompt: finalPrompt,
          negative_prompt:
            "lowres, bad anatomy, bad hands, text, error, cropped, worst quality, low quality, normal quality, jpeg artifacts, blurry, different face, realistic, 3d, photorealistic, nsfw",

          // ★ [InstantID Basic 파라미터 - 핵심 수정]
          // 이 모델은 'num_inference_steps' 대신 'steps'를, 'guidance_scale' 대신 'cfg'를 씁니다.
          // 이름이 틀리면 Replicate가 무시하거나 에러를 냅니다.

          steps: 12, // ★ 30 -> 12 (속도 2.5배 향상)
          cfg: 4.0, // ★ guidance_scale 대신 cfg 사용

          identity_scale: 0.9,
          ip_adapter_scale: 0.8,
          instantid_weight: 0.8,

          // enable_lcm: true, // 이 버전은 LCM 미지원 가능성이 높으므로 제거 (안정성 우선)

          width: 1024,
          height: 1024,
        };
      } else if (mode === "situation") {
        throw new Error("상황 생성은 별도 구현 필요");
      } else {
        throw new Error("유효하지 않은 모드입니다.");
      }

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
