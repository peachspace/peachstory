const functions = require("firebase-functions");
const axios = require("axios");

exports.generateReplicateImage = functions
  .runWith({ secrets: ["REPLICATE_API_KEY"], timeoutSeconds: 300 })
  .https.onCall(async (data, context) => {
    if (!context.auth)
      throw new functions.https.HttpsError("unauthenticated", "Auth required");

    try {
      const response = await axios.post(
        "https://api.replicate.com/v1/models/lucataco/anything-v5/predictions",
        {
          input: {
            prompt: "masterpiece, best quality, anime style, " + data.prompt,
            negative_prompt:
              "low quality, bad anatomy, worst quality, lowres, blurry",
            width: 512,
            height: 768,
            num_inference_steps: 20,
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
      if (!imageUrl) throw new Error("No image generated");
      return { success: true, imageUrl };
    } catch (error) {
      console.error("Replicate Error:", error.message);
      throw new functions.https.HttpsError("internal", "Image gen failed");
    }
  });
