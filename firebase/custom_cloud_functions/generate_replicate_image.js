const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ★ 모델: Animagine XL 4.0
const ANIMAGINE_XL_4_VERSION =
  "7af46ee494f1cf196d49a8592737f4eb789e34a5a995751b23a869d19f5dc2ba";

exports.generateReplicateImage = functions
  .runWith({
    timeoutSeconds: 540,
    memory: "1GB",
  })
  .https.onCall(async (data, context) => {
    // [TRACE] 로그
    console.log("[TRACE] generateReplicateImage Started");

    if (!context.auth) return { success: false, error: "Auth required." };

    try {
      const userId = context.auth.uid;
      const rawMode = data.mode || "character";
      const mode = String(rawMode).trim().toLowerCase();

      const promptInput = data.prompt || "";
      const baseDescription = data.basePrompt || "";

      // Seed 처리 (상황 모드는 Seed 필수, 배경은 선택)
      let seed =
        data.seed && parseInt(data.seed) !== 0
          ? parseInt(data.seed)
          : Math.floor(Math.random() * 2147483647);

      console.log(
        `[REQ] mode=${mode}, seed=${seed}, base=${!!baseDescription}, prompt=${promptInput}`,
      );

      // ★ [기존 코드 유지] 감정 매핑 (삭제하지 않음!)
      const emotionMap = {
        무감정:
          "neutral expression, calm face, looking straight, closed mouth, serene",
        기쁨: "joyful smile, happy expression, laughing, beaming, radiant",
        슬픔: "sad face, teary eyes, crying, melancholic, gloomy, depressed",
        화남: "angry expression, frowning, rage, furious, annoyed, mad",
        놀람: "surprised face, wide eyes, open mouth, shocked, stunned",
        공포: "horrified, screaming, trembling, pale face",
        혐오: "disgusted expression, grimace, revolted, loathing",
        사랑: "loving gaze, blushing, romantic expression, affectionate",
        설렘: "excited, anticipating, blushing, sparkling eyes",
        안도: "relieved sigh, relaxed face, at ease, comforted",
        감동: "touched, emotional, teary smile, moved",
        자신감: "confident smirk, determined look, proud, bold",
        장난: "playful wink, sticking tongue out, mischievous smile, teasing",
        만족: "satisfied nod, content smile, pleased, fulfilled",
        감사: "thankful expression, gentle smile, appreciative",
        짜증: "annoyed, irritated, rolling eyes, grumpy",
        질투: "jealous glare, pouting, envious, resentful",
        실망: "disappointed, sighing, looking down, let down",
        우울: "depressed, lifeless eyes, heavy atmosphere, hopeless",
        고통: "painful expression, agony, suffering, wincing",
        부끄러움: "embarrassed, blushing heavily, hiding face, shy, ashamed",
        당황: "flustered, sweating, confused, awkward smile",
        경멸: "scornful look, sneering, looking down on, disdain",
        불안: "anxious, biting nails, nervous, worried, uneasy",
        피곤: "tired, dark circles, yawning, exhausted, sleepy",
        지루함: "bored, resting chin on hand, dull eyes, uniterested",
        멍함: "blank stare, dazed, spacing out, empty eyes",
        호기심: "curious look, tilting head, sparkling eyes, interested",
        진지: "serious face, focused, stern, intense gaze",
        결의: "determined eyes, strong will, unwavering",
        미침: "insane laughter, crazy eyes, yandere, psycho",
        취함: "drund, flushed face, dizzy eyes, tipsy",
        아픔: "sick, pale, feverish, coughing, weak",
        배고픔: "drooling, looking at food, hungry",
        중립: "neutral expression, calm, indifferent",
      };

      // 공통 설정
      let inputData = {
        num_inference_steps: 28,
        guidance_scale: 7,
        width: 896,
        height: 1152, // 세로 비율
        seed: seed,
        negative_prompt:
          "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, full body, wide shot",
      };

      // -----------------------------------------------------
      // 1. Character (기존 유지)
      // -----------------------------------------------------
      if (mode === "character") {
        inputData.prompt = `solo, masterpiece, best quality, anime style, portrait, upper body, focus on face, ${promptInput}`;
        inputData.negative_prompt += ", multiple views, comic panels";
      }
      // -----------------------------------------------------
      // 2. Emotion (기존 유지)
      // -----------------------------------------------------
      else if (mode === "emotion") {
        if (!baseDescription)
          throw new Error("캐릭터의 Base Prompt가 필요합니다.");

        // 기존 로직 복구: 입력된 감정 키워드를 Map에서 찾아서 변환
        let emotionKey = promptInput.trim().split(" ")[0];
        let extraDesc = promptInput.replace(emotionKey, "").trim();
        let emotionEng = emotionMap[emotionKey] || promptInput; // 매핑 없으면 입력값 그대로

        inputData.prompt = `solo, masterpiece, best quality, anime style, portrait, upper body, focus on face, ${baseDescription}, ${emotionEng}, ${extraDesc}`;
      }
      // -----------------------------------------------------
      // 3. Situation (행동/상황) - [수정됨: 행동 우선순위 강화]
      // -----------------------------------------------------
      else if (mode === "situation") {
        if (!baseDescription)
          throw new Error("Base Prompt required for consistency.");

        // ★ [변경점] 구도를 잡기 위해 행동(promptInput)을 앞에 둠
        inputData.prompt = `masterpiece, best quality, anime style, solo, ${promptInput}, ${baseDescription}`;

        // 전신이 나와야 하므로 'full body' 등의 네거티브 제거 (필수)
        inputData.negative_prompt =
          "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, multiple views";
      }
      // -----------------------------------------------------
      // 4. Background (배경) - [신규 추가]
      // -----------------------------------------------------
      else if (mode === "background") {
        // 배경은 사람 없이 풍경만
        inputData.prompt = `masterpiece, best quality, anime style, scenery, no humans, landscape, indoors or outdoors, ${promptInput}`;
        // 사람 관련 태그 강력 차단
        inputData.negative_prompt +=
          ", girl, boy, woman, man, people, character, person, human, 1girl, 1boy, face, body";
      } else {
        throw new Error(`Invalid mode: ${mode}`);
      }

      // Replicate 호출 (Animagine 단일 모델)
      const response = await axios.post(
        "https://api.replicate.com/v1/predictions",
        { version: ANIMAGINE_XL_4_VERSION, input: inputData },
        {
          headers: {
            Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            Prefer: "wait=60",
          },
        },
      );

      let prediction = response.data;
      const getUrl = prediction.urls.get;
      let attempts = 0;

      while (
        prediction.status === "starting" ||
        prediction.status === "processing"
      ) {
        if (attempts++ > 600) throw new Error("Timeout");
        await sleep(1000);
        prediction = (
          await axios.get(getUrl, {
            headers: {
              Authorization: `Bearer ${process.env.REPLICATE_API_KEY}`,
            },
          })
        ).data;
      }

      if (prediction.status !== "succeeded")
        throw new Error(prediction.error || "Failed");

      let rawAiUrl = Array.isArray(prediction.output)
        ? prediction.output[0]
        : prediction.output;

      // Storage Upload (기존 로직 유지)
      try {
        const imgResp = await axios.get(rawAiUrl, {
          responseType: "arraybuffer",
        });
        const fileName = `${mode}_${Date.now()}.png`;
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

        // ★ seed 반환 (앱에서 저장용)
        return { success: true, imageUrl: permUrl, seed: seed };
      } catch (saveErr) {
        return { success: true, imageUrl: rawAiUrl, seed: seed };
      }
    } catch (error) {
      console.error(error);
      return { success: false, error: error.message };
    }
  });
