const functions = require("firebase-functions");
const axios = require("axios");

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 300,
    memory: "512MB",
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      // 1. 앱에서 보낸 데이터 수신
      const characterImageUrl = data.characterImageUrl; // (없을 수도 있음)
      const prompt = data.prompt || "anime style, high quality";

      console.log(
        "캐릭터 이미지:",
        characterImageUrl ? characterImageUrl : "없음 (신규 생성)",
      );
      console.log("프롬프트:", prompt);

      let apiUrl = "https://api.replicate.com/v1/predictions";
      let requestBody = {};

      // 2. 분기 처리: 캐릭터 이미지가 있는 경우 vs 없는 경우
      if (characterImageUrl) {
        // [CASE A] 상황 이미지 생성 (캐릭터 얼굴 유지)
        // 기존에 사용하시던 'consistent-character' 모델 또는 유사 모델 사용
        requestBody = {
          version:
            "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772", // 기존 버전 유지
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
        // [CASE B] 캐릭터 신규 생성 (텍스트 -> 이미지)
        // 이미지가 없을 때는 SDXL 같은 일반 고성능 모델을 사용합니다.
        requestBody = {
          // Stability AI의 SDXL 1.0 모델 버전
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

      // 3. Replicate API 호출
      const response = await axios.post(apiUrl, requestBody, {
        headers: {
          Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
          "Content-Type": "application/json",
          Prefer: "wait",
        },
      });

      // 4. 결과 처리
      const output = response.data.output;
      if (!output || output.length === 0)
        throw new Error("이미지 생성 실패 (Replicate 응답 없음)");

      // 모델에 따라 output이 문자열 하나일 수도 있고, 배열일 수도 있음
      const finalImageUrl = Array.isArray(output) ? output[0] : output;

      return { success: true, imageUrl: finalImageUrl };
    } catch (error) {
      console.error("에러 발생:", error.response?.data || error.message);
      // 상세 에러 내용을 클라이언트로 전달
      throw new functions.https.HttpsError(
        "internal",
        JSON.stringify(error.response?.data || error.message),
      );
    }
  });
