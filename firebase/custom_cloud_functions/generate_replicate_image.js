const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/** ------------------------------------------------------------------
 * 0. 환경 설정 및 초기화
 * ------------------------------------------------------------------ */
// 배포 전 환경변수 설정:
// firebase functions:config:set storage.bucket="your-project.appspot.com" replicate.key="r8_..."
const CONFIG_BUCKET =
  functions.config().storage?.bucket || process.env.FIREBASE_STORAGE_BUCKET;
const CONFIG_API_KEY =
  functions.config().replicate?.key || process.env.REPLICATE_API_KEY;

const USER_CACHE = new Map();
const MAX_CACHE_SIZE = 5000;
const CACHE_TTL_MS = 5 * 60 * 1000;

const EMOTION_MAP = {
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
  지루함: "bored, resting chin on hand, dull eyes, uninterested",
  멍함: "blank stare, dazed, spacing out, empty eyes",
  호기심: "curious look, tilting head, sparkling eyes, interested",
  진지: "serious face, focused, stern, intense gaze",
  결의: "determined eyes, strong will, unwavering",
  미침: "insane laughter, crazy eyes, yandere, psycho",
  취함: "drunk, flushed face, dizzy eyes, tipsy",
  아픔: "sick, pale, feverish, coughing, weak",
  배고픔: "drooling, looking at food, hungry",
};

function getExtensionFromMime(contentType) {
  if (!contentType) return ".png";
  if (contentType.includes("jpeg") || contentType.includes("jpg"))
    return ".jpg";
  if (contentType.includes("webp")) return ".webp";
  return ".png";
}

async function getUserPremiumStatus(userId) {
  const now = Date.now();
  const cached = USER_CACHE.get(userId);

  if (cached) {
    if (now - cached.timestamp < CACHE_TTL_MS) {
      USER_CACHE.delete(userId);
      USER_CACHE.set(userId, cached);
      return cached.isPremium;
    }
    USER_CACHE.delete(userId);
  }

  try {
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();
    const isPremium = userDoc.exists && userDoc.data().isPremium === true;

    if (USER_CACHE.size >= MAX_CACHE_SIZE) {
      const firstKey = USER_CACHE.keys().next().value;
      USER_CACHE.delete(firstKey);
    }
    USER_CACHE.set(userId, { isPremium, timestamp: now });
    return isPremium;
  } catch (e) {
    console.error(`[DB Error] User:${userId}`, e);
    return false;
  }
}

// [보안] 버킷 자동 보정 및 URL 검증
function isValidInputUrl(urlStr, allowedBucket) {
  try {
    const url = new URL(urlStr);
    if (url.protocol !== "https:") return false;

    // 버킷명 정규화 (설정에 'project-id'만 있어도 '.appspot.com' 붙여서 비교)
    let targetBucket = allowedBucket;
    if (targetBucket && !targetBucket.includes(".")) {
      targetBucket += ".appspot.com";
    }

    let bucketName = "";
    if (url.hostname === "firebasestorage.googleapis.com") {
      const match = url.pathname.match(/^\/v0\/b\/([^/]+)\/o\//);
      if (match) bucketName = match[1];
    } else if (url.hostname === "storage.googleapis.com") {
      const match = url.pathname.match(/^\/([^/]+)\//);
      if (match) bucketName = match[1];
    } else {
      return false;
    }
    return bucketName === targetBucket;
  } catch (_) {
    return false;
  }
}

function isValidOutputUrl(urlStr) {
  try {
    const url = new URL(urlStr);
    return (
      url.protocol === "https:" &&
      (url.hostname === "replicate.delivery" ||
        url.hostname.endsWith(".replicate.delivery"))
    );
  } catch (_) {
    return false;
  }
}

function safeSeed(seedLike) {
  const n = parseInt(seedLike, 10);
  if (!n || n === 0 || Number.isNaN(n))
    return Math.floor(Math.random() * 2147483647);
  return n;
}

/** ------------------------------------------------------------------
 * 1. 모델 설정
 * ------------------------------------------------------------------ */
const STYLE_CONFIG = {
  애니: {
    version: "3f3246eb760773d22e03290623f993309e3774620023ee468498894474773c39",
    steps: 28,
    guidance: 7.0,
    supportsRef: true,
    imgField: "image",
    strField: "prompt_strength",
    prefix:
      "masterpiece, best quality, anime style, cel shading, clean lineart, detailed eyes",
    premiumPrefix: "masterpiece, best quality, anime style, clean lineart",
  },
  웹툰: {
    version: "3f3246eb760773d22e03290623f993309e3774620023ee468498894474773c39",
    steps: 28,
    guidance: 7.0,
    supportsRef: true,
    imgField: "image",
    strField: "prompt_strength",
    prefix:
      "masterpiece, best quality, webtoon style, manhwa, bold outlines, flat color, vivid colors, single panel, one scene, no split frames",
    premiumPrefix:
      "masterpiece, best quality, webtoon style, bold outlines, flat color",
  },
  세미리얼: {
    version: "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
    steps: 30,
    guidance: 7.0,
    supportsRef: true,
    imgField: "image",
    strField: "prompt_strength",
    prefix:
      "masterpiece, best quality, semi-realistic illustration, 3d render style, soft lighting, detailed texture",
    premiumPrefix: "masterpiece, best quality, semi-realistic, soft lighting",
  },
  실사: {
    version: "33279060bbbb8858700eb2146350a98d96ef334fcf817f37eb05915e1534aa1c",
    steps: 25,
    guidance: 6.0,
    supportsRef: true,
    imgField: "image",
    strField: "prompt_strength",
    prefix:
      "photorealistic, raw photo, 8k, cinematic lighting, realistic skin texture, dslr, film grain",
    premiumPrefix: "photorealistic, raw photo, cinematic lighting",
  },
};

const PREMIUM_MODELS = {
  INSTANT_ID: {
    version: "c1e14995eb835c9180f836173079b5d21b0b57e7535b46e3981882b53f608988",
    faceInput: "image",
    poseInput: "pose_image",
    idStrength: "ip_adapter_scale",
    poseStrength: "controlnet_conditioning_scale",
    stepsField: "num_inference_steps",
    guidanceField: "guidance_scale",
  },
  IP_ADAPTER: {
    version: "24a139a031e406f3438e1467439506691c28c616892697843b0d24326555239a",
    faceInput: "image",
    idStrength: "scale",
    stepsField: "num_inference_steps",
    guidanceField: "guidance_scale",
  },
};

const NEG_BASE =
  "lowres, worst quality, low quality, blurry, watermark, error, bad anatomy, bad hands, missing fingers, extra digit, cropped";
const NEG_STANDARD = `${NEG_BASE}, text, multiple views, comic panels`;
const NEG_WEBTOON = `${NEG_BASE}, multiple views, speech bubble, caption, dialog box, typeset, text, panel borders, split view`;

function normalizeStyle(raw) {
  const s = String(raw || "애니").trim();
  if (s.includes("웹툰")) return "웹툰";
  if (s.includes("세미")) return "세미리얼";
  if (s.includes("실사") || s.includes("영화")) return "실사";
  return "애니";
}

function normalizeMode(raw) {
  const m = String(raw || "character")
    .trim()
    .toLowerCase();
  if (m.includes("main")) return "main";
  if (m.includes("emotion")) return "emotion";
  if (m.includes("situation")) return "situation";
  if (m.includes("background")) return "background";
  return "character";
}

function getPrompt(
  styleConfig,
  mode,
  basePrompt,
  promptInput,
  isPremium,
  hasRef,
) {
  const prefix =
    isPremium && hasRef ? styleConfig.premiumPrefix : styleConfig.prefix;
  const identityLock = basePrompt ? `same character, ${basePrompt}` : "";

  let finalInput = promptInput;
  if (mode === "emotion") {
    const rawKey = promptInput.trim().split(" ")[0];
    const cleanKey = rawKey.replace(/[^\w\s\u3131-\uD79D]/g, "");

    const mapped = EMOTION_MAP[cleanKey] || EMOTION_MAP[rawKey];
    if (mapped) finalInput = mapped;
  }

  if (mode === "character")
    return `solo, portrait, upper body, focus on face, ${styleConfig.prefix}, ${identityLock}, ${finalInput}`;
  if (mode === "emotion")
    return `solo, portrait, focus on face, ${prefix}, ${identityLock}, ${finalInput}`;
  if (mode === "situation")
    return `solo, full body, dynamic pose, ${prefix}, ${identityLock}, ${finalInput}`;
  if (mode === "background")
    return `scenery, no humans, ${styleConfig.prefix}, ${finalInput}`;
  return `solo, portrait, cinematic lighting, ${prefix}, ${identityLock}, ${finalInput}`;
}

/** ------------------------------------------------------------------
 * 3. 외부 통신 (안정성 극대화)
 * ------------------------------------------------------------------ */
// [개선] Create 요청 재시도 (429/5xx 대응)
async function callReplicate(apiKey, version, input) {
  let retries = 2; // 최대 2회 재시도 (총 3회)
  while (true) {
    try {
      const response = await axios.post(
        "https://api.replicate.com/v1/predictions",
        { version, input },
        {
          headers: { Authorization: `Bearer ${apiKey}`, Prefer: "wait=30" },
          timeout: 45000,
        },
      );
      return response.data;
    } catch (e) {
      // 429(Too Many Requests) 또는 5xx 에러면 잠시 대기 후 재시도
      if (
        retries > 0 &&
        e.response &&
        (e.response.status === 429 || e.response.status >= 500)
      ) {
        console.warn(`[CREATE RETRY] Status ${e.response.status}, retrying...`);
        await sleep(1500); // 1.5초 대기
        retries--;
        continue;
      }
      throw e; // 그 외 에러는 즉시 throw
    }
  }
}

async function pollReplicate(apiKey, getUrl) {
  let prediction = null;
  const startTime = Date.now();
  const DEADLINE = 450 * 1000;
  let retryCount = 0;

  while (Date.now() - startTime < DEADLINE) {
    try {
      prediction = (
        await axios.get(getUrl, {
          headers: { Authorization: `Bearer ${apiKey}` },
          timeout: 10000,
        })
      ).data;

      // 성공/진행 중 응답 시 카운트 리셋
      if (prediction.status) retryCount = 0;

      if (prediction.status === "succeeded") return prediction;

      if (
        prediction.status !== "starting" &&
        prediction.status !== "processing"
      ) {
        const err = new Error(
          prediction.error ||
            `Replicate failed with status: ${prediction.status}`,
        );
        err.isTerminal = true;
        throw err;
      }
    } catch (pollErr) {
      if (pollErr.isTerminal) throw pollErr;
      if (pollErr.response) {
        const s = pollErr.response.status;
        // [수정] 400번대(400~499)는 대부분 Terminal로 처리 (단 429는 제외)
        if (s >= 400 && s < 500 && s !== 429) {
          const e = new Error(`Polling Fatal Error: ${s}`);
          e.isTerminal = true;
          throw e;
        }
      }

      const baseDelay = pollErr.response?.status === 429 ? 5000 : 2000;
      const delay =
        Math.min(baseDelay * Math.pow(1.5, retryCount), 15000) +
        Math.random() * 500;

      console.warn(
        `[POLL RETRY #${retryCount + 1}] Waiting ${Math.round(delay)}ms. Error: ${pollErr.message}`,
      );
      await sleep(delay);
      retryCount++;
      continue;
    }

    await sleep(2000);
  }
  throw new Error("Replicate poll timeout (deadline exceeded)");
}

async function saveToStorage(bucketName, userId, mode, rawAiUrl) {
  if (!isValidOutputUrl(rawAiUrl)) {
    try {
      const blockedHost = new URL(rawAiUrl).hostname;
      console.warn(`[Blocked Host] ${blockedHost}`);
    } catch (_) {}
    throw new Error(`Security Block: Unauthorized output host`);
  }

  const imgResp = await axios.get(rawAiUrl, {
    responseType: "arraybuffer",
    maxContentLength: 20 * 1024 * 1024,
    maxBodyLength: 20 * 1024 * 1024,
    timeout: 20000,
    validateStatus: (status) => status >= 200 && status < 300,
  });

  const contentType = imgResp.headers["content-type"];
  if (!contentType || !contentType.startsWith("image/")) {
    throw new Error(`Security Block: Invalid content-type (${contentType})`);
  }

  const ext = getExtensionFromMime(contentType);
  const fileName = `${mode}_${Date.now()}${ext}`;

  // bucketName은 이미 검증된 값이거나 정규화된 값
  const file = admin
    .storage()
    .bucket(bucketName)
    .file(`users/${userId}/uploads/${fileName}`);

  await file.save(imgResp.data, {
    metadata: { contentType: contentType },
  });

  const [permUrl] = await file.getSignedUrl({
    action: "read",
    expires: "03-01-2100",
  });
  return permUrl;
}

exports.generateReplicateImage = functions
  .runWith({ timeoutSeconds: 540, memory: "1GB" })
  .https.onCall(async (data, context) => {
    // 설정 검증
    if (!CONFIG_BUCKET || !CONFIG_API_KEY) {
      console.error("Missing Environment Config");
      return { success: false, error: "Server Configuration Error" };
    }

    if (!context.auth) return { success: false, error: "Auth required." };
    const userId = context.auth.uid;

    try {
      const isPremium = await getUserPremiumStatus(userId);
      const mode = normalizeMode(data.mode);
      const style = normalizeStyle(data.style);

      const promptInput = String(data.prompt || "").trim();
      const basePrompt = String(data.basePrompt || "").trim();
      const referenceImageUrl = String(data.referenceImageUrl || "").trim();
      const poseImageUrl = String(data.poseImageUrl || "").trim();

      const seed = safeSeed(data.seed);

      // 버킷 정규화 (설정에 .appspot.com 없으면 붙여서 사용)
      let targetBucket = CONFIG_BUCKET;
      if (!targetBucket.includes(".")) {
        targetBucket += ".appspot.com";
      }

      if (
        referenceImageUrl &&
        !isValidInputUrl(referenceImageUrl, targetBucket)
      ) {
        return { success: false, error: "Invalid ref URL (Bucket Mismatch)" };
      }
      if (poseImageUrl && !isValidInputUrl(poseImageUrl, targetBucket)) {
        return { success: false, error: "Invalid pose URL (Bucket Mismatch)" };
      }

      console.log(
        `[REQ] User=${userId}, Premium=${isPremium}, Style=${style}, Mode=${mode}, Seed=${seed}`,
      );

      const config = STYLE_CONFIG[style] || STYLE_CONFIG["애니"];
      const finalPrompt = getPrompt(
        config,
        mode,
        basePrompt,
        promptInput,
        isPremium,
        !!referenceImageUrl,
      );

      let versionToUse = config.version;
      let usedPipeline = "Standard";
      let inputData = {};

      // 4. 파이프라인 분기

      // [CASE 0] 배경
      if (mode === "background") {
        usedPipeline = "Standard_Background";
        inputData = {
          prompt: finalPrompt,
          negative_prompt: `${style === "웹툰" ? NEG_WEBTOON : NEG_STANDARD}, people, character, human, girl, boy`,
          width: 1024,
          height: 768,
          num_inference_steps: config.steps,
          guidance_scale: config.guidance,
          seed: seed,
        };
      }
      // [CASE 1] 프리미엄 & 참조 이미지
      else if (mode !== "character" && referenceImageUrl && isPremium) {
        // [1-A] 실사 -> InstantID
        if (style === "실사") {
          usedPipeline = "Premium_InstantID";
          versionToUse = PREMIUM_MODELS.INSTANT_ID.version;
          const p = PREMIUM_MODELS.INSTANT_ID;

          inputData = {
            prompt: finalPrompt,
            negative_prompt: NEG_STANDARD,
            [p.faceInput]: referenceImageUrl,
            width: 896,
            height: 1152,
            seed: seed,
            [p.stepsField]: 30,
            [p.guidanceField]: 5,
            [p.idStrength]: mode === "situation" ? 0.75 : 0.85,
            [p.poseStrength]: 0.8,
          };
          if (mode === "situation" && poseImageUrl) {
            inputData[p.poseInput] = poseImageUrl;
            inputData[p.poseStrength] = 1.0;
          }
        }
        // [1-B] 애니/웹툰 -> IP-Adapter
        else {
          usedPipeline = "Premium_IP_Adapter";
          versionToUse = PREMIUM_MODELS.IP_ADAPTER.version;
          const p = PREMIUM_MODELS.IP_ADAPTER;

          inputData = {
            prompt: finalPrompt,
            negative_prompt: style === "웹툰" ? NEG_WEBTOON : NEG_STANDARD,
            [p.faceInput]: referenceImageUrl,
            width: 896,
            height: 1152,
            seed: seed,
            [p.stepsField]: 30,
            [p.guidanceField]: 7.5,
          };

          let idScale = 0.75;
          if (style === "웹툰") idScale = mode === "situation" ? 0.7 : 0.6;
          else idScale = mode === "situation" ? 0.85 : 0.75;
          inputData[p.idStrength] = idScale;
        }
      }
      // [CASE 2] 일반 / 무료
      else {
        usedPipeline = "Standard";
        inputData = {
          prompt: finalPrompt,
          negative_prompt: style === "웹툰" ? NEG_WEBTOON : NEG_STANDARD,
          width: 896,
          height: 1152,
          num_inference_steps: config.steps,
          guidance_scale: config.guidance,
          seed: seed,
        };

        if (
          mode !== "character" &&
          mode !== "background" &&
          referenceImageUrl &&
          config.supportsRef
        ) {
          inputData[config.imgField] = referenceImageUrl;
          let str = 0.55;
          if (mode === "emotion") str = 0.4;
          else if (mode === "situation") str = style === "웹툰" ? 0.6 : 0.65;
          inputData[config.strField] = str;
        }
      }

      console.log(`[EXEC] Pipeline: ${usedPipeline}, Style: ${style}`);

      // 5. 실행 및 폴백
      let prediction;
      try {
        const created = await callReplicate(
          CONFIG_API_KEY,
          versionToUse,
          inputData,
        );
        prediction = await pollReplicate(CONFIG_API_KEY, created.urls.get);
      } catch (reqErr) {
        if (usedPipeline.startsWith("Premium") && !reqErr.isTerminal) {
          const errMsg = reqErr.response?.data?.error || reqErr.message;
          console.warn(
            `[FALLBACK] ${usedPipeline} failed (${errMsg}) -> Standard`,
          );

          const fallbackConfig = STYLE_CONFIG[style] || STYLE_CONFIG["애니"];
          versionToUse = fallbackConfig.version;

          inputData = {
            prompt: finalPrompt,
            negative_prompt: style === "웹툰" ? NEG_WEBTOON : NEG_STANDARD,
            width: 896,
            height: 1152,
            num_inference_steps: fallbackConfig.steps,
            guidance_scale: fallbackConfig.guidance,
            seed: seed,
          };

          if (
            mode !== "character" &&
            referenceImageUrl &&
            fallbackConfig.supportsRef
          ) {
            inputData[fallbackConfig.imgField] = referenceImageUrl;
            inputData[fallbackConfig.strField] = 0.55;
          }

          const created2 = await callReplicate(
            CONFIG_API_KEY,
            versionToUse,
            inputData,
          );
          prediction = await pollReplicate(CONFIG_API_KEY, created2.urls.get);
          usedPipeline += "_Fallback";
        } else {
          throw reqErr;
        }
      }

      const rawAiUrl = Array.isArray(prediction.output)
        ? prediction.output[0]
        : prediction.output;

      try {
        // [수정] targetBucket (정규화된 버킷명) 사용
        const permUrl = await saveToStorage(
          targetBucket,
          userId,
          mode,
          rawAiUrl,
        );
        return {
          success: true,
          imageUrl: permUrl,
          seed: seed,
          pipeline: usedPipeline,
        };
      } catch (e) {
        console.error("Storage Save Failed:", e.message);
        if (e.message.includes("Security Block")) {
          return { success: false, error: "Image blocked by security policy." };
        }
        return {
          success: true,
          imageUrl: rawAiUrl,
          seed: seed,
          pipeline: usedPipeline,
        };
      }
    } catch (error) {
      console.error(
        "Replicate Error:",
        error.response?.status,
        JSON.stringify(error.response?.data || {}),
      );
      return { success: false, error: error.message };
    }
  });
