const functions = require("firebase-functions");
const axios = require("axios");

// 도우미 함수: 일정 시간 대기 (밀리초 단위)
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540, // 타임아웃을 9분으로 넉넉하게 연장
    memory: "512MB",
  })
  .https.onCall(async (data, context) => {
    // 1. 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      // 2. 앱에서 보낸 데이터 수신
      const characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style, high quality";

      console.log("-----------------------------------------");
      console.log(
        "요청 시작 - 캐릭터 이미지:",
        characterImageUrl || "없음 (신규 생성)",
      );
      console.log("프롬프트:", prompt);

      let apiUrl = "https://api.replicate.com/v1/predictions";
      let requestBody = {};

      // 3. 분기 처리: 캐릭터 이미지 유무에 따라 모델 및 입력값 결정
      if (characterImageUrl) {
        // [CASE A] 상황 이미지 (캐릭터 얼굴 유지)
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
        // [CASE B] 신규 캐릭터 생성 (SDXL)
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

      // 4. Replicate에 생성 요청 (비동기)
      const initialResponse = await axios.post(apiUrl, requestBody, {
        headers: {
          Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
          "Content-Type": "application/json",
        },
      });

      let prediction = initialResponse.data;
      const getUrl = prediction.urls.get;

      console.log("생성 작업 시작됨. ID:", prediction.id);

      // 5. 폴링(Polling) 루프: 완료될 때까지 상태 확인
      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        attempts++;
        if (attempts > 60) {
          // 약 2분(2초*60회) 초과 시 타임아웃 처리
          throw new Error("이미지 생성 시간 초과 (Timeout)");
        }

        await sleep(2000); // 2초 대기

        const statusResponse = await axios.get(getUrl, {
          headers: {
            Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
          },
        });

        prediction = statusResponse.data;
        // console.log(`[${attempts}] 상태 확인 중: ${prediction.status}`);
      }

      // 6. 결과 처리
      if (prediction.status === "succeeded") {
        const output = prediction.output;
        if (!output || output.length === 0) throw new Error("결과 없음");

        const finalImageUrl = Array.isArray(output) ? output[0] : output;
        console.log("이미지 생성 완료:", finalImageUrl);

        return { success: true, imageUrl: finalImageUrl };
      } else {
        // 실패한 경우
        const errorMsg = prediction.error || "알 수 없는 오류";
        console.error("Replicate 실패:", errorMsg);
        throw new Error(`이미지 생성 실패: ${errorMsg}`);
      }
    } catch (error) {
      console.error("최종 에러 발생:", error.message);
      throw new functions.https.HttpsError(
        "internal",
        error.message || "서버 내부 오류 발생",
      );
    }
  });
