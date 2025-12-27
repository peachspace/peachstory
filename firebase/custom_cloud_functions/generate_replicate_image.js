const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540,
    memory: "1GB",
  })
  .https.onCall(async (data, context) => {
    console.log(">>> [v2025_FINAL] AI Image Generation Started");

    if (!context.auth) {
      return { success: false, imageUrl: null, error: "Auth Required" };
    }

    try {
      let characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style";
      const userId = context.auth.uid;

      // 1. Signed URL 발급 (권한 문제 해결)
      let isValidUrl = false;
      if (characterImageUrl && typeof characterImageUrl === "string") {
        if (characterImageUrl.startsWith("http")) {
          isValidUrl = true;
        } else {
          try {
            const bucket = admin.storage().bucket();
            let path = characterImageUrl;
            if (path.startsWith("gs://"))
              path = path.split("/").slice(3).join("/");

            const file = bucket.file(path);
            const [exists] = await file.exists();
            if (exists) {
              const [signedUrl] = await file.getSignedUrl({
                action: "read",
                expires: Date.now() + 3600000,
              });
              characterImageUrl = signedUrl;
              isValidUrl = true;
            }
          } catch (e) {
            console.error("URL Convert Error:", e);
          }
        }
      }

      // 2. Replicate 요청
      let apiUrl = "https://api.replicate.com/v1/predictions";
      let inputData = {
        prompt: `anime style, ${prompt}`,
        negative_prompt: "bad quality, distortion",
        width: 1024,
        height: 1024,
        num_outputs: 1,
      };

      if (isValidUrl) {
        inputData.image = characterImageUrl;
        // 모델 버전: Image-to-Image
        var version =
          "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772";
      } else {
        // 모델 버전: Text-to-Image
        var version =
          "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b";
      }

      const initialResponse = await axios.post(
        apiUrl,
        { version: version, input: inputData },
        {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        },
      );

      let prediction = initialResponse.data;
      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        if (attempts++ > 60) throw new Error("Timeout");
        await sleep(2000);
        prediction = (
          await axios.get(prediction.urls.get, {
            headers: {
              Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            },
          })
        ).data;
      }

      if (prediction.status !== "succeeded")
        throw new Error(prediction.error || "Failed");

      const rawUrl = prediction.output[0] || prediction.output;

      // 3. 서버에서 바로 저장 (CORS 방지)
      try {
        const imgResp = await axios.get(rawUrl, {
          responseType: "arraybuffer",
        });
        const fileName = `ai_${Date.now()}.png`;
        const file = admin
          .storage()
          .bucket()
          .file(`users/${userId}/uploads/${fileName}`);

        await file.save(imgResp.data, {
          metadata: { contentType: "image/png" },
        });
        const [permUrl] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2100",
        });

        return { success: true, imageUrl: permUrl }; // ★ 최종 주소 반환
      } catch (saveErr) {
        console.error("Save Error:", saveErr);
        return { success: true, imageUrl: rawUrl }; // 저장 실패시 원본이라도 반환
      }
    } catch (error) {
      console.error("Function Error:", error);
      // 에러가 나도 앱이 죽지 않게 Map 형태로 반환
      return { success: false, imageUrl: null, error: error.message };
    }
  });
