const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin"); // [추가] 버킷 이름 가져오기 위해 필요

if (!admin.apps.length) {
  admin.initializeApp();
}

// 도우미 함수: 일정 시간 대기
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540,
    memory: "512MB",
  })
  .https.onCall(async (data, context) => {
    console.log(">>> [v2025_FIXED] 이미지 경로 자동 보정 모드 <<<");

    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      let characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style, high quality";

      console.log("[DEBUG] 원본 경로:", characterImageUrl);

      // URL 검증 및 변환 로직 강화
      let isValidUrl = false;
      if (characterImageUrl && typeof characterImageUrl === "string") {
        characterImageUrl = characterImageUrl.trim();

        // 1. gs:// 형식 변환 (기존 코드)
        if (characterImageUrl.startsWith("gs://")) {
          const parts = characterImageUrl.replace("gs://", "").split("/");
          const bucket = parts[0];
          const path = parts.slice(1).join("%2F");
          characterImageUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${path}?alt=media`;
        }
        // 2. [★수정됨] http도 아니고 gs도 아닌 '단순 경로(users/...)'가 들어왔을 때 처리
        else if (!characterImageUrl.startsWith("http")) {
          // 기본 스토리지 버킷 이름 가져오기
          const bucket = admin.storage().bucket().name;
          // 경로의 슬래시(/)를 %2F로 인코딩해야 함
          const encodedPath = encodeURIComponent(characterImageUrl);
          characterImageUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodedPath}?alt=media`;
          console.log(
            "[DEBUG] 단순 경로를 Full URL로 변환함:",
            characterImageUrl,
          );
        }

        // 최종적으로 http로 시작하면 유효하다고 판단
        if (characterImageUrl.startsWith("http")) isValidUrl = true;
      }

      console.log("[DEBUG] 최종 사용 URL:", characterImageUrl);
      console.log("[DEBUG] isValidUrl 판정:", isValidUrl);

      let apiUrl = "https://api.replicate.com/v1/predictions";
      let requestBody = {};

      const commonInputOptions = {
        disable_safety_checker: true,
        safety_checker: false,
      };

      if (isValidUrl) {
        // [CASE A] 캐릭터 참조 (Image-to-Image)
        requestBody = {
          version:
            "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772",
          input: {
            ...commonInputOptions,
            image: characterImageUrl, // 변환된 정식 URL이 들어감
            prompt: `anime style, ${prompt}`,
            negative_prompt:
              "realistic, photo, 3d, text, error, cropped, worst quality, low quality, jpeg artifacts, signature, watermark, username, blurry",
            width: 1024,
            height: 1024,
            number_of_outputs: 1,
            randomise_poses: true,
          },
        };
      } else {
        // [CASE B] 캐릭터 미참조 (Text-to-Image)
        // URL이 없거나 깨졌을 때만 이리로 옴
        console.log(
          "[WARN] 유효하지 않은 이미지 URL입니다. 텍스트로만 생성합니다.",
        );
        requestBody = {
          version:
            "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
          input: {
            ...commonInputOptions,
            prompt: `anime style, character design, ${prompt}`,
            negative_prompt: "photographic, realistic, low quality, distortion",
            width: 1024,
            height: 1024,
            scheduler: "K_EULER",
            num_outputs: 1,
          },
        };
      }

      // 요청 보내기
      const initialResponse = await axios.post(apiUrl, requestBody, {
        headers: {
          Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
          "Content-Type": "application/json",
        },
      });

      let prediction = initialResponse.data;
      const getUrl = prediction.urls.get;

      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        attempts++;
        if (attempts > 60) throw new Error("시간 초과");
        await sleep(2000);

        const statusResponse = await axios.get(getUrl, {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        });
        prediction = statusResponse.data;
      }

      if (prediction.status === "succeeded") {
        const output = prediction.output;
        const finalImageUrl = Array.isArray(output) ? output[0] : output;
        return { success: true, imageUrl: finalImageUrl };
      } else {
        const errorMsg = prediction.error || "알 수 없는 오류";
        console.error("Replicate 실패:", errorMsg);
        if (errorMsg.includes("NSFW")) {
          throw new Error("※경고: 모델의 강제 필터가 작동했습니다.");
        }
        throw new Error(`AI 처리 실패: ${errorMsg}`);
      }
    } catch (error) {
      console.error("최종 에러 핸들러:", error);
      throw new functions.https.HttpsError("internal", error.message);
    }
  });
