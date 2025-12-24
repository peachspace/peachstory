const functions = require("firebase-functions");
const axios = require("axios");

// 도우미 함수: 일정 시간 대기
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540,
    memory: "512MB",
  })
  .https.onCall(async (data, context) => {
    // [확인용 로그] 이 로그가 보여야 새 코드가 적용된 것입니다.
    console.log(">>> [v2025_FREEDOM] 검열 해제 모드 실행 <<<");

    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      let characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style, high quality";
      // ✅ (추가) 변환 전 원본 확인
      console.log(
        "[DEBUG] raw characterImageUrl:",
        characterImageUrl,
        "type:",
        typeof characterImageUrl,
      );

      // URL 검증 및 변환
      let isValidUrl = false;
      if (characterImageUrl && typeof characterImageUrl === "string") {
        characterImageUrl = characterImageUrl.trim();
        if (characterImageUrl.startsWith("gs://")) {
          const parts = characterImageUrl.replace("gs://", "").split("/");
          const bucket = parts[0];
          const path = parts.slice(1).join("%2F");
          characterImageUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${path}?alt=media`;
        }
        if (characterImageUrl.startsWith("http")) isValidUrl = true;
      }

      // ✅ (추가) 변환 후 최종값 + 판정
      console.log("[DEBUG] final characterImageUrl:", characterImageUrl);
      console.log("[DEBUG] isValidUrl:", isValidUrl);

      let apiUrl = "https://api.replicate.com/v1/predictions";
      let requestBody = {};

      // ★ 검열 해제 옵션 (가장 중요) ★
      const commonInputOptions = {
        disable_safety_checker: true, // 검열 끄기
        safety_checker: false,
      };

      if (isValidUrl) {
        // [CASE A] 캐릭터 유지 (상황 이미지)
        requestBody = {
          version:
            "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772",
          input: {
            ...commonInputOptions,
            image: characterImageUrl,
            prompt: `anime style, ${prompt}`,
            // negative_prompt에서 검열 관련 단어 제거함
            negative_prompt:
              "realistic, photo, 3d, text, error, cropped, worst quality, low quality, jpeg artifacts, signature, watermark, username, blurry",
            width: 1024,
            height: 1024,
            number_of_outputs: 1,
            randomise_poses: true,
          },
        };
      } else {
        // [CASE B] 캐릭터 신규 생성
        requestBody = {
          version:
            "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
          input: {
            ...commonInputOptions,
            // 'safe for work' 제거함
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

      // 대기 (Polling)
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

      // 결과 반환
      if (prediction.status === "succeeded") {
        const output = prediction.output;
        const finalImageUrl = Array.isArray(output) ? output[0] : output;
        return { success: true, imageUrl: finalImageUrl };
      } else {
        const errorMsg = prediction.error || "알 수 없는 오류";
        console.error("Replicate 실패:", errorMsg);

        // 에러 메시지 변경 (배포 확인용)
        if (errorMsg.includes("NSFW")) {
          throw new Error(
            "※경고: 모델의 강제 필터가 작동했습니다. 더 순화된 표현을 써보세요.",
          );
        }
        throw new Error(`AI 처리 실패: ${errorMsg}`);
      }
    } catch (error) {
      throw new functions.https.HttpsError("internal", error.message);
    }
  });
