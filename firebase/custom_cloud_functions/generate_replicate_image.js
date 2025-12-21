const functions = require("firebase-functions");
const axios = require("axios");

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"], // Secret Manager 사용
    timeoutSeconds: 300,
    memory: "256MB",
  })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      // ★ 여기가 핵심! 살아있는 최신 모델로 교체했습니다.
      const response = await axios.post(
        "https://api.replicate.com/v1/models/bytedance/sdxl-lightning-4step/predictions",
        {
          input: {
            prompt: "anime style, masterpiece, best quality, " + data.prompt,
            negative_prompt:
              "low quality, bad anatomy, worst quality, lowres, blurry, ugly",
            width: 1024,
            height: 1024,
            num_inference_steps: 4, // 4단계라 요금도 저렴!
            guidance_scale: 0,
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

      const imageUrl = response.data.output?.[0];
      if (!imageUrl) throw new Error("이미지 생성 결과가 비어있습니다");

      return { success: true, imageUrl };
    } catch (error) {
      const errorData = error.response
        ? JSON.stringify(error.response.data)
        : error.message;
      console.error("Replicate API Error Details:", errorData);
      throw new functions.https.HttpsError(
        "internal",
        `Replicate 실패: ${errorData}`,
      );
    }
  });
