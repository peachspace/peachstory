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
    // 1. 디버깅 로그 (Firebase Console에서 확인 가능)
    console.log(
      "DEBUG: 함수 시작. 입력된 이미지 경로:",
      data.characterImageUrl,
    );

    if (!context.auth) {
      return { success: false, error: "로그인이 필요합니다." };
    }

    try {
      let characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style";
      const userId = context.auth.uid;

      // ----------------------------------------------------
      // [핵심] users/ 경로가 들어오면 다운로드 가능한 URL로 변환
      // ----------------------------------------------------
      let isValidUrl = false;
      if (
        characterImageUrl &&
        typeof characterImageUrl === "string" &&
        characterImageUrl.length > 5
      ) {
        characterImageUrl = characterImageUrl.trim();

        if (characterImageUrl.startsWith("http")) {
          // 이미 http URL이면 그대로 사용
          isValidUrl = true;
        } else {
          // gs:// 또는 users/ 경로 처리 -> Signed URL 발급
          try {
            const bucket = admin.storage().bucket();
            let path = characterImageUrl;
            if (path.startsWith("gs://"))
              path = path.split("/").slice(3).join("/");

            console.log("DEBUG: 변환할 스토리지 경로:", path);

            const file = bucket.file(path);
            const [exists] = await file.exists();

            if (exists) {
              // 1시간 유효한 임시 URL 생성
              const [signedUrl] = await file.getSignedUrl({
                action: "read",
                expires: Date.now() + 60 * 60 * 1000,
              });
              characterImageUrl = signedUrl;
              isValidUrl = true;
              console.log("DEBUG: Signed URL 발급 성공");
            } else {
              console.warn("DEBUG: 파일이 존재하지 않음");
            }
          } catch (e) {
            console.error("DEBUG: URL 변환 중 에러:", e);
          }
        }
      }

      // ----------------------------------------------------
      // Replicate 요청 (안전장치 준수)
      // ----------------------------------------------------
      let apiUrl = "https://api.replicate.com/v1/predictions";

      // 안전장치(disable_safety_checker) 제거됨 - 정석 구현
      let inputData = {
        prompt: `anime style, ${prompt}`,
        negative_prompt: "low quality, distortion, text, watermark",
        width: 1024,
        height: 1024,
        num_outputs: 1,
      };

      if (isValidUrl) {
        inputData.image = characterImageUrl;
        // Image-to-Image 모델
        var version =
          "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772";
      } else {
        console.log(
          "DEBUG: 이미지가 없거나 유효하지 않아 Text-to-Image로 전환",
        );
        // Text-to-Image 모델
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
      const getUrl = prediction.urls.get;

      // 대기 (Polling)
      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        if (attempts++ > 60) throw new Error("시간 초과 (Timeout)");
        await sleep(2000);
        prediction = (
          await axios.get(getUrl, {
            headers: {
              Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            },
          })
        ).data;
      }

      if (prediction.status !== "succeeded") {
        throw new Error(prediction.error || "AI 생성 실패");
      }

      const rawAiUrl = prediction.output[0] || prediction.output;

      // ----------------------------------------------------
      // 결과 이미지 저장 (CORS 및 영구 보관 해결)
      // ----------------------------------------------------
      try {
        const imgResp = await axios.get(rawAiUrl, {
          responseType: "arraybuffer",
        });
        const fileName = `ai_gen_${Date.now()}.png`;
        const file = admin
          .storage()
          .bucket()
          .file(`users/${userId}/uploads/${fileName}`);

        await file.save(imgResp.data, {
          metadata: { contentType: "image/png" },
        });

        // 2100년까지 유효한 URL 발급 (사실상 영구)
        const [permUrl] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2100",
        });

        return { success: true, imageUrl: permUrl };
      } catch (saveErr) {
        console.error("DEBUG: 저장 실패, 원본 반환:", saveErr);
        // 저장이 안 되어도 AI가 만든 원본 주소라도 반환 (차선책)
        return { success: true, imageUrl: rawAiUrl };
      }
    } catch (error) {
      console.error("DEBUG: 최종 에러:", error);
      return { success: false, error: error.message };
    }
  });
