const functions = require("firebase-functions");
const axios = require("axios");

exports.generateReplicateImage = functions
  // Secret Manager 사용
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 300,
    memory: "256MB",
  })
  .https.onCall(async (data, context) => {
    // 1. 인증 체크
    if (!context.auth)
      throw new functions.https.HttpsError("unauthenticated", "Auth required");

    try {
      // 2. [수정됨] 죽은 모델(lucataco) 대신 살아있는 최신 모델(SDXL Lightning) 사용
      // 속도가 매우 빠르고(4 steps), 화질이 좋습니다.
      const response = await axios.post(
        "https://api.replicate.com/v1/models/bytedance/sdxl-lightning-4step/predictions",
        {
          input: {
            // 프롬프트: 애니메이션 스타일 강조
            prompt: "anime style, masterpiece, best quality, " + data.prompt,
            negative_prompt:
              "low quality, bad anatomy, worst quality, lowres, blurry, ugly",
            width: 1024, // SDXL 모델은 1024 해상도가 기본입니다
            height: 1024,
            num_inference_steps: 4, // 4단계만으로 충분 (비용 절약)
            guidance_scale: 0,
          },
        },
        {
          headers: {
            // Secret Manager에서 키를 가져옴
            Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            "Content-Type": "application/json",
            Prefer: "wait",
          },
        },
      );

      const imageUrl = response.data.output?.[0];
      if (!imageUrl) throw new Error("이미지 생성 결과가 비어있습니다");
      return { success: true, imageUrl };
    } catch (error) {
      // 에러 내용을 상세히 출력
      const errorData = error.response
        ? JSON.stringify(error.response.data)
        : error.message;
      console.error("Replicate Error:", errorData);
      throw new functions.https.HttpsError(
        "internal",
        `Replicate 실패: ${errorData}`,
      );
    }
  });
