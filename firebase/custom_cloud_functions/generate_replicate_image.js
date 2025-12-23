const functions = require("firebase-functions");
const axios = require("axios");

// 도우미 함수: 일정 시간 대기 (밀리초 단위)
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540, // 9분 타임아웃
    memory: "512MB",
  })
  .https.onCall(async (data, context) => {
    // 1. 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      console.log(">>> [v2025_DEBUG_MODE] 함수 실행 시작 <<<"); // 배포 확인용 로그

      // 2. 데이터 수신 및 로그
      const characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style, high quality";

      console.log(`입력 프롬프트: ${prompt}`);
      console.log(
        `캐릭터 이미지 URL: ${characterImageUrl || "없음(신규생성)"}`,
      );

      let apiUrl = "https://api.replicate.com/v1/predictions";
      let requestBody = {};

      // 3. 모델 및 입력값 설정
      if (characterImageUrl) {
        // [CASE A] 캐릭터 유지 (fofr/consistent-character 모델)
        // 주의: URL이 유효하지 않거나 접근 불가능하면 Replicate에서 에러 발생
        requestBody = {
          version:
            "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772",
          input: {
            image: characterImageUrl,
            prompt: `anime style, ${prompt}`,
            negative_prompt:
              "realistic, photo, 3d, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry",
            width: 1024,
            height: 1024,
            number_of_outputs: 1,
            randomise_poses: true,
          },
        };
      } else {
        // [CASE B] 신규 생성 (SDXL 모델)
        requestBody = {
          version:
            "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
          input: {
            prompt: `anime style, character design, ${prompt}`,
            negative_prompt: "photographic, realistic, low quality, distortion",
            width: 1024,
            height: 1024,
            scheduler: "K_EULER",
            num_outputs: 1,
          },
        };
      }

      // 4. Replicate 생성 요청
      let prediction;
      try {
        const initialResponse = await axios.post(apiUrl, requestBody, {
          headers: {
            Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            "Content-Type": "application/json",
          },
        });
        prediction = initialResponse.data;
      } catch (axiosError) {
        // Replicate 요청 자체가 실패한 경우 (다른 AI가 말한 원인 파악용)
        console.error(
          "Replicate 요청 실패 상세:",
          axiosError.response?.data || axiosError.message,
        );
        throw new Error(
          `Replicate 요청 거부됨: ${JSON.stringify(axiosError.response?.data || axiosError.message)}`,
        );
      }

      console.log("생성 작업 ID:", prediction.id);
      const getUrl = prediction.urls.get;

      // 5. 폴링 (Polling)
      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        attempts++;
        if (attempts > 60) throw new Error("시간 초과 (Timeout)");
        await sleep(2000);

        const statusResponse = await axios.get(getUrl, {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        });
        prediction = statusResponse.data;
      }

      // 6. 결과 반환
      if (prediction.status === "succeeded") {
        const output = prediction.output;
        const finalImageUrl = Array.isArray(output) ? output[0] : output;

        if (!finalImageUrl) throw new Error("결과 URL이 비어있음");
        return { success: true, imageUrl: finalImageUrl };
      } else {
        // 생성 중 실패 (모델 오류 등)
        console.error("Replicate 처리 실패:", prediction.error);
        throw new Error(`AI 처리 실패: ${prediction.error}`);
      }
    } catch (error) {
      console.error("최종 에러 핸들러:", error.message);
      // 클라이언트에게 에러 내용을 그대로 전달 (디버깅용)
      throw new functions.https.HttpsError("internal", error.message);
    }
  });
