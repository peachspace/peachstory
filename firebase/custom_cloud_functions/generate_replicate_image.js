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
    memory: "512MB",
  })
  .https.onCall(async (data, context) => {
    console.log(">>> [v2025_SIGNED_URL] 보안 이미지 처리 모드 <<<");

    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      let characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style, high quality";

      console.log("[DEBUG] 입력된 경로:", characterImageUrl);

      // ---------------------------------------------------------
      // [핵심 로직] Signed URL (임시 다운로드 주소) 발급
      // ---------------------------------------------------------
      let isValidUrl = false;

      if (characterImageUrl && typeof characterImageUrl === "string") {
        characterImageUrl = characterImageUrl.trim();

        // 1. 이미 http로 시작하면(외부 URL) 그대로 사용
        if (characterImageUrl.startsWith("http")) {
          isValidUrl = true;
        }
        // 2. gs:// 로 시작하거나, users/ 등 단순 경로인 경우 -> Signed URL 발급
        else {
          let storagePath = characterImageUrl;

          // gs:// 제거
          if (characterImageUrl.startsWith("gs://")) {
            storagePath = characterImageUrl.split("/").slice(3).join("/");
            // gs://bucket_name/path/to/file -> path/to/file
          }

          console.log("[DEBUG] 스토리지 파일 경로:", storagePath);

          try {
            const bucket = admin.storage().bucket(); // 기본 버킷 사용
            const file = bucket.file(storagePath);

            // 파일 존재 여부 확인 (옵션)
            const [exists] = await file.exists();
            if (!exists) {
              console.warn("[WARN] 파일이 스토리지에 없습니다:", storagePath);
              // 파일이 없으면 텍스트 생성 모드로 전환 (isValidUrl = false)
            } else {
              // 60분 동안 유효한 임시 주소 생성
              const [signedUrl] = await file.getSignedUrl({
                action: "read",
                expires: Date.now() + 60 * 60 * 1000, // 1시간
              });

              characterImageUrl = signedUrl;
              isValidUrl = true;
              console.log(
                "[DEBUG] Signed URL 발급 성공(일부):",
                signedUrl.substring(0, 50) + "...",
              );
            }
          } catch (signErr) {
            console.error("[ERROR] Signed URL 발급 실패:", signErr);
            // 실패 시 텍스트 모드로 진행
          }
        }
      }

      // ---------------------------------------------------------
      // AI 요청 (Replicate)
      // ---------------------------------------------------------
      let apiUrl = "https://api.replicate.com/v1/predictions";
      let requestBody = {};
      const commonInputOptions = {
        disable_safety_checker: true,
        safety_checker: false,
      };

      if (isValidUrl) {
        // [CASE A] 이미지 참조 (Image-to-Image)
        console.log("[INFO] 이미지 참조 모드로 실행합니다.");
        requestBody = {
          version:
            "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772",
          input: {
            ...commonInputOptions,
            image: characterImageUrl, // ★ 여기서 Signed URL이 전달됨
            prompt: `anime style, ${prompt}`,
            negative_prompt:
              "realistic, photo, 3d, text, error, cropped, worst quality, low quality, jpeg artifacts, signature, watermark, username, blurry",
            width: 1024,
            height: 1024,
            number_of_outputs: 1,
            randomise_poses: true,
          },
        };
      } else {
        // [CASE B] 텍스트 생성 (Text-to-Image)
        console.log("[INFO] 텍스트 생성 모드로 실행합니다. (이미지 없음/실패)");
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

      // Replicate API 호출
      const initialResponse = await axios.post(apiUrl, requestBody, {
        headers: {
          Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
          "Content-Type": "application/json",
        },
      });

      // 결과 폴링 (Polling)
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

      if (prediction.status === "succeeded") {
        const output = prediction.output;
        const finalImageUrl = Array.isArray(output) ? output[0] : output;
        return { success: true, imageUrl: finalImageUrl };
      } else {
        const errorMsg = prediction.error || "Unknown Error";
        if (errorMsg.includes("NSFW")) throw new Error("NSFW filter triggered");
        throw new Error(`AI Process Failed: ${errorMsg}`);
      }
    } catch (error) {
      console.error("Final Handler Error:", error);
      throw new functions.https.HttpsError("internal", error.message);
    }
  });
