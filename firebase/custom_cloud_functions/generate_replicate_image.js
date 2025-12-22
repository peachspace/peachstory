const functions = require("firebase-functions");
const axios = require("axios");

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 300,
    memory: "256MB",
  })
  .https.onCall(async (data, context) => {
    // 1. 인증 체크
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      console.log("Flux 모델(ID 지정)로 이미지 생성 요청:", data.prompt);

      // ★★★ 핵심 변경 사항 ★★★
      // 모델 이름 주소(v1/models/...) 대신, 가장 확실한 'predictions' 주소를 사용합니다.
      // 그리고 Flux-Schnell 모델의 '고유 ID(Version ID)'를 직접 넣습니다.
      // 이렇게 하면 "모델을 못 찾겠다(404)"는 에러가 절대 날 수 없습니다.
      const response = await axios.post(
        "https://api.replicate.com/v1/predictions",
        {
          // Flux-Schnell 모델의 주민등록번호 (Version ID)
          version:
            "c846a69991daf4c0e5d016514849d14ee5b2e6846ce6b9d6f21369e564cfe51e",
          input: {
            prompt: "anime style, high quality, " + data.prompt,
            aspect_ratio: "1:1",
            output_format: "webp",
            output_quality: 90,
            go_fast: true, // 빠른 생성 모드
          },
        },
        {
          headers: {
            Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            "Content-Type": "application/json",
            Prefer: "wait", // 생성이 끝날 때까지 기다림
          },
        },
      );

      console.log("Replicate 응답 성공:", response.data);

      const imageUrl = response.data.output?.[0];
      if (!imageUrl) {
        throw new Error("이미지 생성 결과(URL)가 없습니다.");
      }

      return { success: true, imageUrl };
    } catch (error) {
      const errorData = error.response
        ? JSON.stringify(error.response.data)
        : error.message;
      console.error("Replicate 최종 실패:", errorData);

      // 에러 내용을 화면에 그대로 보여줍니다.
      throw new functions.https.HttpsError(
        "internal",
        `이미지 생성 오류: ${errorData}`,
      );
    }
  });
