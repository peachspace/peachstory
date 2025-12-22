const functions = require("firebase-functions");
const axios = require("axios");

exports.generateReplicateImage = functions
  // Secret Manager의 키를 사용합니다.
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 300,
    memory: "256MB",
  })
  .https.onCall(async (data, context) => {
    // 1. 로그인 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다.",
      );
    }

    try {
      console.log("Flux 모델로 이미지 생성 요청 중...");

      // 2. [변경됨] 공식 모델 'Flux-Schnell' 사용 (주소가 확실하여 404가 안 뜹니다)
      const response = await axios.post(
        "https://api.replicate.com/v1/models/black-forest-labs/flux-schnell/predictions",
        {
          input: {
            // Flux 모델은 복잡한 설정 없이 프롬프트만 주면 됩니다.
            prompt: "anime style, high quality, " + data.prompt,
            aspect_ratio: "1:1", // 비율 설정 (1:1, 16:9 등 가능)
            output_format: "webp", // 용량 작고 화질 좋음
            output_quality: 90,
            go_fast: true, // 빠른 생성 모드 켜기
          },
        },
        {
          headers: {
            Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            "Content-Type": "application/json",
            Prefer: "wait", // 생성이 끝날 때까지 기다렸다가 응답 받음
          },
        },
      );

      console.log("Replicate 응답 성공:", response.data);

      // 3. 결과 이미지 주소 추출
      const imageUrl = response.data.output?.[0];
      if (!imageUrl) {
        throw new Error("생성된 이미지가 없습니다 (URL 비어있음)");
      }

      return { success: true, imageUrl };
    } catch (error) {
      // 4. 에러 발생 시 상세 내용을 로그에 남김
      const errorData = error.response
        ? JSON.stringify(error.response.data)
        : error.message;
      console.error("Replicate 실패 상세 내용:", errorData);

      // 앱 화면에도 에러 내용을 보여줌
      throw new functions.https.HttpsError(
        "internal",
        `이미지 생성 실패: ${errorData}`,
      );
    }
  });
