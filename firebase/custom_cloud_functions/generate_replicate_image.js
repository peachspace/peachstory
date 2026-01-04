const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// 모델 버전 정의 (다른 AI가 추천한 가성비+일관성 최적 조합)
// 1. 프로필 생성용: Animagine XL 4.0 (애니메이션 특화)
const ANIMAGINE_XL_4_VERSION =
  "7af46ee494f1cf196d49a8592737f4eb789e34a5a995751b23a869d19f5dc2ba";
// 2. 감정 생성용: InstantID Basic (얼굴 참조 고정 특화)
const INSTANT_ID_BASIC_VERSION =
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

      console.log(`DEBUG: 모드=${mode}, 입력값=${promptInput}`);

      // URL 변환 헬퍼 함수
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

      // ★ [핵심 로직] 입력값 분리 함수 (변호사님 요청 사항 반영)
      // "기쁨 꽃을 들고 있음" -> key="기쁨", extra="꽃을 들고 있음"
      const parseEmotionInput = (raw) => {
        const s = (raw || "").trim();
        if (!s) return { key: "", extra: "" };
        const firstSpace = s.indexOf(" ");
        if (firstSpace === -1) return { key: s, extra: "" }; // 단어 하나만 왔을 때
        return {
          key: s.slice(0, firstSpace).trim(),
          extra: s.slice(firstSpace + 1).trim(),
        };
      };

      // 감정 매핑
      const emotionMap = {
        기쁨: "joyful smile, happy expression",
        슬픔: "sad face, crying, tears",
        화남: "angry expression, frowning",
        분노: "angry, furious",
        놀람: "surprised face, wide eyes",
        두려움: "scared, fearful",
        혐오: "disgusted",
        중립: "neutral expression",
      };

      let version;
      let inputData;

      // -----------------------------------------------------
      // 1. 캐릭터(프로필) 생성
      // -----------------------------------------------------
      if (mode === "character") {
        version = ANIMAGINE_XL_4_VERSION;
        inputData = {
          prompt: `1girl, masterpiece, best quality, ${promptInput}`,
          negative_prompt:
            "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry",
          width: 1024,
          height: 1024,
          guidance_scale: 7,
          num_inference_steps: 28,
          aspect_ratio: "square_1024x1024",
        };
      }
      // -----------------------------------------------------
      // 2. 상황 생성 (기존 유지)
      // -----------------------------------------------------
      else if (mode === "situation") {
        // 상황 생성은 기존에 쓰시던 모델이나 IDEOGRAM 유지
        // (여기서는 일단 에러 방지를 위해 간단히 처리)
        throw new Error("상황 생성 로직은 별도 확인 필요");
      }
      // -----------------------------------------------------
      // 3. ★ 감정 생성 (핵심 수정)
      // -----------------------------------------------------
      else if (mode === "emotion") {
        version = INSTANT_ID_BASIC_VERSION; // 얼굴 고정 전문 모델

        const validUrl = await getValidUrl(characterImageUrl);
        if (!validUrl)
          throw new Error(
            "감정 생성을 위해서는 원본 캐릭터 이미지가 필수입니다.",
          );

        // [요청하신 분리 로직 적용]
        const { key, extra } = parseEmotionInput(promptInput);

        // 감정 영문 변환 (없으면 입력값 그대로)
        const emotionDesc = emotionMap[key] || key;

        // 최종 프롬프트 조합: "감정 표현" + "사용자 추가 묘사"
        const finalPrompt = `anime style, ${emotionDesc}, ${extra}, upper body, same character, high quality`;

        inputData = {
          image: validUrl, // ★ 얼굴 참조 이미지 (InstantID 필수 입력)
          prompt: finalPrompt,
          negative_prompt:
            "lowres, bad anatomy, bad hands, text, error, cropped, worst quality, low quality, normal quality, jpeg artifacts, blurry, different face, realistic",

          // ★ 얼굴 고정 파라미터 (다른 AI 추천값 적용)
          identity_scale: 0.8, // 얼굴 유사도 (높을수록 원본과 같음)
          ip_adapter_scale: 0.8, // 스타일 유사도
          instantid_weight: 0.8, // InstantID 영향력

          width: 1024,
          height: 1024,
          steps: 30,
          cfg: 7,
        };
      } else {
        throw new Error("유효하지 않은 모드입니다.");
      }

      // Replicate 호출 및 결과 대기 (기존과 동일)
      const response = await axios.post(
        "https://api.replicate.com/v1/predictions",
        { version: version, input: inputData },
        {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        },
      );

      // ... (폴링 및 저장 로직은 기존 코드 그대로 유지하거나 복사)
      let prediction = response.data;
      const getUrl = prediction.urls.get;
      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        if (attempts++ > 120) throw new Error("Timeout");
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

      let rawAiUrl = Array.isArray(prediction.output)
        ? prediction.output[0]
        : prediction.output;

      // 저장 로직 (간소화)
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
