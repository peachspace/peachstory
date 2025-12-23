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
      // 1. 앱에서 보낸 캐릭터 사진 URL과 상황 설명을 받습니다.
      const characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style";

      // 사진이 없으면 에러를 냅니다.
      if (!characterImageUrl) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "캐릭터 이미지가 필요합니다.",
        );
      }

      console.log("캐릭터 이미지:", characterImageUrl);
      console.log("상황 프롬프트:", prompt);

      // 2. 'consistent-character' 모델 호출 (사진을 보고 그리는 모델)
      const response = await axios.post(
        "https://api.replicate.com/v1/predictions",
        {
          version:
            "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772",
          input: {
            image: characterImageUrl, // ★ 핵심: 캐릭터 사진을 모델에 입력
            prompt: `anime style, ${prompt}`, // 애니 스타일 강제 적용
            negative_prompt: "realistic, photo, 3d, bad anatomy",
            width: 1024,
            height: 1024,
            number_of_outputs: 1,
            randomise_poses: true, // 얼굴은 유지하되 포즈는 자유롭게
          },
        },
        {
          headers: {
            Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            "Content-Type": "application/json",
            Prefer: "wait",
          },
        },
      );

      // 3. 결과 이미지 주소 반환
      const output = response.data.output;
      if (!output || output.length === 0) throw new Error("이미지 생성 실패");

      return { success: true, imageUrl: output[0] };
    } catch (error) {
      console.error("에러 발생:", error.response?.data || error.message);
      throw new functions.https.HttpsError(
        "internal",
        JSON.stringify(error.response?.data || error.message),
      );
    }
  });
