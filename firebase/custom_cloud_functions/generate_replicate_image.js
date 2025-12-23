const functions = require("firebase-functions");
const axios = require("axios");

// 도우미 함수: 일정 시간 대기 (밀리초 단위)
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

exports.generateReplicateImage = functions
  .runWith({
    secrets: ["REPLICATE_API_KEY"],
    timeoutSeconds: 540, // 9분 타임아웃
    memory: "512MB",
  })
  .https.onCall(async (data, context) => {
    console.log(">>> [v2025_SAFE_MODE] 함수 실행 시작 <<<");

    // 1. 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Auth required");
    }

    try {
      // 2. 앱에서 보낸 데이터 수신
      const characterImageUrl = data.characterImageUrl;
      const prompt = data.prompt || "anime style, high quality";

      console.log(`입력 프롬프트: ${prompt}`);
      console.log(
        `캐릭터 이미지 URL: ${characterImageUrl || "없음(신규생성)"}`,
      );

      let apiUrl = "https://api.replicate.com/v1/predictions";
      let requestBody = {};

      // 강력한 성인물 차단 필터 (Negative Prompt)
      const safetyNegativePrompt =
        "nsfw, nude, naked, censored, nipple, genitals, sexual, provocative, breast, uncensored, cleavage, worst quality, low quality, jpeg artifacts, ugly, duplicate, morbid, mutilated, extra fingers, mutated hands, poorly drawn hands, poorly drawn face, mutation, deformed, blurry, dehydrated, bad anatomy, bad proportions, extra limbs, cloned face, disfigured, gross proportions, malformed limbs, missing arms, missing legs, extra arms, extra legs, fused fingers, too many fingers, long neck, username, watermark, signature";

      // 3. 모델 및 입력값 설정
      if (characterImageUrl) {
        // [CASE A] 캐릭터 유지 (Image-to-Image)
        requestBody = {
          version:
            "9c77a3c2f884193fcee4d89645f02a0b9def9434f9e03cb98460456b831c8772",
          input: {
            image: characterImageUrl,
            prompt: `anime style, ${prompt}`,
            negative_prompt: `realistic, photo, 3d, ${safetyNegativePrompt}`,
            width: 1024,
            height: 1024,
            number_of_outputs: 1,
            randomise_poses: true,
          },
        };
      } else {
        // [CASE B] 신규 캐릭터 생성 (Text-to-Image)
        requestBody = {
          version:
            "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
          input: {
            prompt: `anime style, character design, ${prompt}, safe for work`, // safe for work 추가
            negative_prompt: `photographic, realistic, distortion, ${safetyNegativePrompt}`, // 강력한 차단 필터 적용
            width: 1024,
            height: 1024,
            scheduler: "K_EULER",
            num_outputs: 1,
          },
        };
      }

      // 4. Replicate 생성 요청
      let prediction;
      try {
        const initialResponse = await axios.post(apiUrl, requestBody, {
          headers: {
            Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            "Content-Type": "application/json",
          },
        });
        prediction = initialResponse.data;
      } catch (axiosError) {
        console.error(
          "Replicate 요청 실패 상세:",
          axiosError.response?.data || axiosError.message,
        );
        throw new Error(
          `Replicate 요청 거부됨: ${JSON.stringify(axiosError.response?.data || axiosError.message)}`,
        );
      }

      console.log("생성 작업 ID:", prediction.id);
      const getUrl = prediction.urls.get;

      // 5. 폴링 (Polling)
      let attempts = 0;
      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        attempts++;
        if (attempts > 60) throw new Error("시간 초과 (Timeout)");
        await sleep(2000);

        const statusResponse = await axios.get(getUrl, {
          headers: { Authorization: `Bearer ${process.env.REPLICATE_API_KEY}` },
        });
        prediction = statusResponse.data;
      }

      // 6. 결과 반환
      if (prediction.status === "succeeded") {
        const output = prediction.output;
        const finalImageUrl = Array.isArray(output) ? output[0] : output;

        if (!finalImageUrl) throw new Error("결과 URL이 비어있음");
        console.log("이미지 생성 성공:", finalImageUrl);
        return { success: true, imageUrl: finalImageUrl };
      } else {
        // 실패 원인이 NSFW인 경우 친절한 메시지로 변환
        const errorMsg = prediction.error || "알 수 없는 오류";
        console.error("Replicate 처리 실패:", errorMsg);

        if (errorMsg.includes("NSFW")) {
          throw new Error(
            "이미지가 너무 선정적이어서 AI가 차단했습니다. 다른 프롬프트로 다시 시도해주세요.",
          );
        }

        throw new Error(`AI 처리 실패: ${errorMsg}`);
      }
    } catch (error) {
      console.error("최종 에러 핸들러:", error.message);
      throw new functions.https.HttpsError("internal", error.message);
    }
  });
