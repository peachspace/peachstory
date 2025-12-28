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
    // 1. 디버깅 로그
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
      // [이미지 URL 변환 로직]
      // ----------------------------------------------------
      let isValidUrl = false;
      let hasImageInput = false; // 이미지가 입력되었는지 여부 체크

      if (
        characterImageUrl &&
        typeof characterImageUrl === "string" &&
        characterImageUrl.length > 5
      ) {
        hasImageInput = true;
        characterImageUrl = characterImageUrl.trim();

        if (characterImageUrl.startsWith("http")) {
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
      // Replicate 요청 (캐릭터 일관성 유지 모델)
      // ----------------------------------------------------
      let apiUrl = "https://api.replicate.com/v1/predictions";

      // 모델 버전 (consistent-character)
      const version =
        "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772";

      let inputData = {
        prompt: `anime style, ${prompt}`,
        negative_prompt: "low quality, distortion, text, watermark",
        width: 1024,
        height: 1024,
        num_outputs: 1,
      };

      // [핵심 수정 1] 캐릭터 이미지가 입력되었는데 URL 변환에 실패했다면 에러 발생 (엉뚱한 그림 방지)
      if (hasImageInput && !isValidUrl) {
        throw new Error(
          "캐릭터 이미지를 불러올 수 없습니다. 경로를 확인해주세요.",
        );
      }

      // [핵심 수정 2] 파라미터 이름을 'image' -> 'subject'로 변경
      if (isValidUrl) {
        inputData.subject = characterImageUrl;
      } else {
        // 이미지가 아예 없는 경우 (필요 시 에러 처리하거나 텍스트 모드로 분기)
        // 여기서는 캐릭터 생성이 목적이므로 에러 처리합니다.
        throw new Error("캐릭터 이미지가 필요합니다.");
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
      // 결과 이미지 저장
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

        const [permUrl] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2100",
        });

        return { success: true, imageUrl: permUrl };
      } catch (saveErr) {
        console.error("DEBUG: 저장 실패, 원본 반환:", saveErr);
        return { success: true, imageUrl: rawAiUrl };
      }
    } catch (error) {
      console.error("DEBUG: 최종 에러:", error);
      return { success: false, error: error.message };
    }
  });
