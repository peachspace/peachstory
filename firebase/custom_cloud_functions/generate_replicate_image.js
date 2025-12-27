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
    memory: "1GB", // 메모리 넉넉하게
  })
  .https.onCall(async (data, context) => {
    console.log(">>> [v2025_FINAL] AI 생성 및 서버 자동 저장 모드 <<<");

    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      let characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style, high quality";
      const userId = context.auth.uid;

      // 1. 이미지 주소 처리 (Signed URL 발급 등) - 기존 로직 유지
      let isValidUrl = false;
      if (characterImageUrl && typeof characterImageUrl === "string") {
        characterImageUrl = characterImageUrl.trim();
        if (characterImageUrl.startsWith("http")) {
          isValidUrl = true;
        } else {
          // gs:// 나 users/ 경로가 들어왔을 때 처리
          try {
            let storagePath = characterImageUrl;
            if (characterImageUrl.startsWith("gs://")) {
              storagePath = characterImageUrl.split("/").slice(3).join("/");
            }
            const bucket = admin.storage().bucket();
            const file = bucket.file(storagePath);
            const [exists] = await file.exists();
            if (exists) {
              const [signedUrl] = await file.getSignedUrl({
                action: "read",
                expires: Date.now() + 60 * 60 * 1000,
              });
              characterImageUrl = signedUrl;
              isValidUrl = true;
            }
          } catch (e) {
            console.error("URL 변환 실패:", e);
          }
        }
      }

      // 2. Replicate에 생성 요청
      let apiUrl = "https://api.replicate.com/v1/predictions";
      let requestBody = {};
      const commonInputOptions = {
        disable_safety_checker: true,
        safety_checker: false,
      };

      if (isValidUrl) {
        requestBody = {
          version:
            "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772",
          input: {
            ...commonInputOptions,
            image: characterImageUrl,
            prompt: `anime style, ${prompt}`,
            negative_prompt:
              "realistic, photo, 3d, text, error, cropped, worst quality, low quality, jpeg artifacts, signature, watermark, username, blurry",
            width: 1024,
            height: 1024,
            num_outputs: 1,
            randomise_poses: true,
          },
        };
      } else {
        requestBody = {
          version:
            "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
          input: {
            ...commonInputOptions,
            prompt: `anime style, character design, ${prompt}`,
            negative_prompt: "photographic, realistic, low quality, distortion",
            width: 1024,
            height: 1024,
            scheduler: "K_EULER",
            num_outputs: 1,
          },
        };
      }

      const initialResponse = await axios.post(apiUrl, requestBody, {
        headers: {
          Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
          "Content-Type": "application/json",
        },
      });

      let prediction = initialResponse.data;
      const getUrl = prediction.urls.get;
      let attempts = 0;

      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        attempts++;
        if (attempts > 60) throw new Error("Time out");
        await sleep(2000);
        const statusResponse = await axios.get(getUrl, {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        });
        prediction = statusResponse.data;
      }

      if (prediction.status !== "succeeded") {
        throw new Error(prediction.error || "Generation Failed");
      }

      const rawAiImageUrl = Array.isArray(prediction.output)
        ? prediction.output[0]
        : prediction.output;

      // ======================================================
      // [핵심 해결] 3. 서버가 직접 다운로드해서 Firebase에 저장
      // ======================================================
      try {
        // (1) AI 이미지 다운로드 (서버끼리는 CORS 문제 없음)
        const imageResponse = await axios.get(rawAiImageUrl, {
          responseType: "arraybuffer",
        });
        const buffer = Buffer.from(imageResponse.data, "binary");

        // (2) Firebase Storage에 저장
        const fileName = `ai_gen_${Date.now()}.png`;
        const filePath = `users/${userId}/uploads/${fileName}`; // 사용자 폴더에 저장
        const bucket = admin.storage().bucket();
        const file = bucket.file(filePath);

        await file.save(buffer, {
          metadata: { contentType: "image/png" },
        });

        // (3) 영구 다운로드 URL 생성 (Long-lived Signed URL)
        // 2100년까지 유효한 주소를 만듭니다.
        const [permanentUrl] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2100",
        });

        console.log("Firebase 저장 성공:", permanentUrl);

        // ★ 앱으로 '저장된 주소'를 반환합니다.
        return { success: true, imageUrl: permanentUrl };
      } catch (saveError) {
        console.error("서버 저장 중 에러:", saveError);
        // 저장이 실패해도 일단 원본이라도 줍니다.
        return { success: true, imageUrl: rawAiImageUrl };
      }
    } catch (error) {
      console.error("최종 에러:", error);
      throw new functions.https.HttpsError("internal", error.message);
    }
  });
