const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// [중요] 사용자님의 버킷 주소
const MANUAL_BUCKET_FALLBACK = "ssss-ehfczw.appspot.com";

const firebaseConfig = (() => {
  try {
    return process.env.FIREBASE_CONFIG
      ? JSON.parse(process.env.FIREBASE_CONFIG)
      : {};
  } catch {
    return {};
  }
})();

const AUTO_BUCKET =
  functions.config().storage?.bucket ||
  firebaseConfig.storageBucket ||
  process.env.FIREBASE_STORAGE_BUCKET ||
  (process.env.GCLOUD_PROJECT
    ? `${process.env.GCLOUD_PROJECT}.appspot.com`
    : undefined);

const CONFIG_BUCKET = AUTO_BUCKET || MANUAL_BUCKET_FALLBACK;

const MODEL_VERSION_CACHE = new Map();
const MODEL_VERSION_TTL_MS = 10 * 60 * 1000;
const MODEL_VERSION_INFLIGHT = new Map();

// ... (감정 맵 유지) ...
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

function normalizeBucketName(bucket) {
  if (!bucket) return "";
  const b = String(bucket).trim();
  return b.includes(".") ? b : `${b}.appspot.com`;
}

function extractBucketNameFromFirebaseUrl(url) {
  try {
    if (url.hostname === "firebasestorage.googleapis.com") {
      const match = url.pathname.match(/^\/v0\/b\/([^/]+)\/o\//);
      return match ? match[1] : "";
    }
    if (url.hostname === "storage.googleapis.com") {
      const match = url.pathname.match(/^\/([^/]+)\//);
      return match ? match[1] : "";
    }
    if (url.hostname.endsWith(".storage.googleapis.com")) {
      return url.hostname.replace(".storage.googleapis.com", "");
    }
  } catch (_) {}
  return "";
}

function isValidInputUrl(urlStr, allowedBucketRaw) {
  try {
    const url = new URL(urlStr);
    if (url.protocol !== "https:") return false;
    const allowedBucket = normalizeBucketName(allowedBucketRaw);
    const bucketFromUrl = extractBucketNameFromFirebaseUrl(url);
    if (!bucketFromUrl) return false;
    return bucketFromUrl === allowedBucket;
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
 * 1. 모델 레지스트리 (V16.0: cjwbw 원복 + 검증된 해시)
 * ------------------------------------------------------------------ */
const MODEL_REGISTRY = {
  // [수정 A] cjwbw로 원복하고, 확실히 작동하는 버전 해시 적용
  ANIMAGINE_XL: {
    owner: "cjwbw",
    name: "animagine-xl-3.1",
    version: "6afe2e6b27dad2d6f480b59195c221884b6acc589ff4d05ff0e5fc058690fbb9",
    schema: "SDXL_ANIMAGINE",
  },
  REALVIS_XL: {
    owner: "adirik",
    name: "realvisxl-v4.0",
    version: "85a58cc74b90c1b6c7c7e08c82c32c02d7462a98b1fd69e7fbf99f948c1d5267",
    schema: "SDXL_STANDARD",
  },
  INSTANT_ID: {
    owner: "zsxkib",
    name: "instant-id",
    version: "2e4785a4d80dadf580077b2244c8d7c05d8e3faac04a04c02d8e099dd2876789",
    schema: "INSTANT_ID",
  },
  IP_ADAPTER: {
    owner: "lucataco",
    name: "ip-adapter-sdxl-face",
    version: "226c6bf67a75a129b0f978e518fed33e1fb13956e15761c1ac53c9d2f898c9af",
    schema: "IP_ADAPTER",
  },
};

const STYLE_MAPPING = {
  애니: {
    baseModel: "ANIMAGINE_XL",
    identityModel: "IP_ADAPTER",
    prefix:
      "masterpiece, best quality, high quality anime illustration, light novel illustration, soft shading, clean lineart, smooth gradients, glossy eyes, detailed hair, delicate highlights",
    neg: "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, jpeg artifacts, signature, watermark, username, blurry, character sheet, reference sheet, turnaround, multiple views, collage, panel, split view, multiple characters, 2girls, 2people, crowd, chibi",
  },
  웹툰: {
    baseModel: "ANIMAGINE_XL",
    identityModel: "IP_ADAPTER",
    prefix:
      "masterpiece, best quality, webtoon style, manhwa, bold outlines, flat color, vivid colors",
    neg: "lowres, bad anatomy, bad hands, speech bubble, caption, text, dialog box, typeset, panel borders, split view, multiple views, multiple characters, crowd",
  },
  세미리얼: {
    baseModel: "REALVIS_XL",
    identityModel: "INSTANT_ID",
    prefix:
      "masterpiece, best quality, semi-realistic illustration, 3d render style, soft lighting, detailed texture",
    neg: "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, cartoon, anime",
  },
  실사: {
    baseModel: "REALVIS_XL",
    identityModel: "INSTANT_ID",
    prefix:
      "photorealistic, raw photo, 8k, cinematic lighting, realistic skin texture, dslr, film grain",
    neg: "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, cartoon, anime, illustration, painting",
  },
};

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

function buildPrompt(mode, styleObj, basePrompt, scenePrompt, isRefMode) {
  const prefix = styleObj.prefix;
  const identityLock =
    isRefMode && basePrompt ? `same character, ${basePrompt}` : basePrompt;
  const single = "solo, 1girl, single character, centered composition";

  let finalScene = scenePrompt;
  if (mode === "emotion") {
    const rawKey = scenePrompt.trim().split(" ")[0];
    const cleanKey = rawKey.replace(/[^\w\s\u3131-\uD79D]/g, "");
    const mapped = EMOTION_MAP[cleanKey] || EMOTION_MAP[rawKey];
    if (mapped) finalScene = mapped;
    finalScene = `(${finalScene}:1.4)`;
  }

  if (mode === "character")
    return `${single}, close-up portrait, head and shoulders, simple background, ${prefix}, ${identityLock}, neutral expression`;
  if (mode === "emotion")
    return `${single}, close-up portrait, focus on face, ${prefix}, ${identityLock}, ${finalScene}`;
  if (mode === "situation")
    return `${single}, full body, dynamic action pose, ${prefix}, ${identityLock}, (${finalScene}:1.3)`;
  if (mode === "main")
    return `${single}, cover art, cinematic composition, ${prefix}, ${identityLock}, ${finalScene}, dramatic lighting, detailed background`;
  if (mode === "background")
    return `scenery, no humans, ${prefix}, ${finalScene}`;

  return `${single}, ${prefix}, ${identityLock}, ${finalScene}`;
}

function cacheKey(owner, name) {
  return `${owner}/${name}`;
}

async function fetchLatestVersionIdFromReplicate(apiKey, owner, name) {
  const url = `https://api.replicate.com/v1/models/${encodeURIComponent(owner)}/${encodeURIComponent(name)}`;
  let retries = 2;

  while (true) {
    try {
      const resp = await axios.get(url, {
        headers: { Authorization: `Bearer ${apiKey}` },
        timeout: 10000,
        validateStatus: (s) => s >= 200 && s < 500,
      });

      if (resp.status === 200) {
        const latest = resp.data?.latest_version;
        const versionId = latest?.id || resp.data?.latest_version_id;
        if (!versionId)
          throw new Error(`Missing latest_version.id for ${owner}/${name}`);
        return versionId;
      }

      // 429/5xx 에러 시 재시도 (대기 시간 증가)
      if ((resp.status === 429 || resp.status >= 500) && retries-- > 0) {
        await sleep(2000 * (3 - retries));
        continue;
      }
      throw new Error(
        `Replicate GET error: ${resp.status} ${JSON.stringify(resp.data)}`,
      );
    } catch (e) {
      if (retries-- > 0 && !e.response) {
        await sleep(1000);
        continue;
      }
      throw e;
    }
  }
}

async function getModelVersionCached(apiKey, modelInfo) {
  if (!modelInfo?.owner || !modelInfo?.name) return modelInfo.version;
  const key = cacheKey(modelInfo.owner, modelInfo.name);
  const now = Date.now();

  const cached = MODEL_VERSION_CACHE.get(key);
  if (cached && now - cached.ts < MODEL_VERSION_TTL_MS && cached.version)
    return cached.version;
  const inflight = MODEL_VERSION_INFLIGHT.get(key);
  if (inflight) return inflight;

  const p = (async () => {
    try {
      const latestId = await fetchLatestVersionIdFromReplicate(
        apiKey,
        modelInfo.owner,
        modelInfo.name,
      );
      MODEL_VERSION_CACHE.set(key, { version: latestId, ts: Date.now() });
      return latestId;
    } catch (err) {
      console.warn(`[VERSION_FETCH_FAIL] Using fallback: ${err.message}`);
      if (modelInfo.version) return modelInfo.version;
      throw err;
    } finally {
      MODEL_VERSION_INFLIGHT.delete(key);
    }
  })();
  MODEL_VERSION_INFLIGHT.set(key, p);
  return p;
}

function isInvalidVersion422(err) {
  const status = err?.response?.status;
  const title = String(err?.response?.data?.title || "").toLowerCase();
  const detail = String(err?.response?.data?.detail || "").toLowerCase();
  return (
    status === 422 &&
    (title.includes("invalid version") ||
      title.includes("not permitted") ||
      detail.includes("version does not exist") ||
      detail.includes("invalid version") ||
      detail.includes("not permitted"))
  );
}

function invalidateModelCaches(owner, name) {
  const key = cacheKey(owner, name);
  MODEL_VERSION_CACHE.delete(key);
}

function createReplicatePayload(
  modelKey,
  prompt,
  neg,
  width,
  height,
  seed,
  refImage,
  poseImage,
  mode,
) {
  const modelInfo = MODEL_REGISTRY[modelKey];
  if (!modelInfo) throw new Error(`Unknown Model Key: ${modelKey}`);
  const input = {};

  if (modelInfo.schema === "SDXL_ANIMAGINE") {
    input.prompt = prompt;
    input.negative_prompt = neg;
    input.width = width;
    input.height = height;
    input.guidance_scale = 7.0;
    input.num_inference_steps = 30;
    input.seed = seed;
  } else if (modelInfo.schema === "SDXL_STANDARD") {
    input.prompt = prompt;
    input.negative_prompt = neg;
    input.width = width;
    input.height = height;
    input.guidance_scale = 5.0;
    input.num_inference_steps = 30;
    input.seed = seed;
  } else if (modelInfo.schema === "INSTANT_ID") {
    input.prompt = prompt;
    input.negative_prompt = neg;
    input.image = refImage;
    if (poseImage) {
      input.pose_image = poseImage;
      input.controlnet_conditioning_scale = 0.8;
    }
    if (mode === "emotion") input.ip_adapter_scale = 0.5;
    else if (mode === "situation") input.ip_adapter_scale = 0.6;
    else input.ip_adapter_scale = 0.8;
    input.guidance_scale = 5.0;
    input.num_inference_steps = 30;
    input.seed = seed;
  } else if (modelInfo.schema === "IP_ADAPTER") {
    input.prompt = prompt;
    input.negative_prompt = neg;
    input.image = refImage;
    if (mode === "emotion") input.scale = 0.45;
    else if (mode === "situation") input.scale = 0.55;
    else input.scale = 0.7;
    if (poseImage) {
      input.control_image = poseImage;
      input.control_weight = 0.75;
    }
    input.seed = seed;
  }
  return { version: null, input: input };
}

async function callReplicate(apiKey, version, input) {
  let retries = 3;
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
      const status = e?.response?.status;

      // 429 에러 발생 시 대기
      if (retries > 0 && status === 429) {
        const ra = Number(e?.response?.data?.retry_after) || 8;
        const waitMs = ra * 1000 + 1000;
        console.warn(
          `[REPLICATE 429] Limit reached. Waiting ${waitMs / 1000}s...`,
        );
        await sleep(waitMs);
        retries--;
        continue;
      }

      if (retries > 0 && status && status >= 500) {
        await sleep(1500);
        retries--;
        continue;
      }
      throw e;
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
  if (!contentType || !contentType.startsWith("image/"))
    throw new Error(`Security Block: Invalid content-type (${contentType})`);
  const ext = getExtensionFromMime(contentType);
  const fileName = `${mode}_${Date.now()}${ext}`;
  const file = admin
    .storage()
    .bucket(bucketName)
    .file(`users/${userId}/uploads/${fileName}`);
  await file.save(imgResp.data, { metadata: { contentType: contentType } });
  const [permUrl] = await file.getSignedUrl({
    action: "read",
    expires: "03-01-2100",
  });
  return permUrl;
}

exports.generateReplicateImage = functions
  .runWith({
    timeoutSeconds: 540,
    memory: "1GB",
    secrets: ["REPLICATE_API_KEY"],
  })
  .https.onCall(async (data, context) => {
    // [확인용] V16.0: CJWBW 원복 + 선(先) 조회 로직 (B안) 적용
    console.log("=== VERSION CHECK: V16.0 (CJWBW RESTORE & PRE-FETCH) ===");

    const CONFIG_API_KEY =
      process.env.REPLICATE_API_KEY || functions.config().replicate?.key;

    if (!CONFIG_BUCKET || !CONFIG_API_KEY) {
      return { success: false, error: "Server Config Error." };
    }

    try {
      const acct = await axios.get("https://api.replicate.com/v1/account", {
        headers: { Authorization: `Bearer ${CONFIG_API_KEY}` },
        timeout: 5000,
      });
      console.log(
        "[REPLICATE_ACCOUNT] Token Owner:",
        acct.data?.username,
        "Type:",
        acct.data?.type,
      );
    } catch (e) {
      console.warn("[REPLICATE_ACCOUNT] Check Failed:", e.message);
    }

    if (!context.auth) return { success: false, error: "Auth required." };
    const userId = context.auth.uid;

    try {
      const mode = normalizeMode(data.mode);
      const style = normalizeStyle(data.style);

      const promptInput = String(data.prompt || "").trim();
      const basePrompt = String(data.basePrompt || "").trim();
      const referenceImageUrl = String(data.referenceImageUrl || "").trim();
      const poseImageUrl = String(data.poseImageUrl || "").trim();
      const seed = safeSeed(data.seed);

      const targetBucket = normalizeBucketName(CONFIG_BUCKET);
      if (
        referenceImageUrl &&
        !isValidInputUrl(referenceImageUrl, targetBucket)
      )
        return { success: false, error: "Invalid ref URL" };
      if (poseImageUrl && !isValidInputUrl(poseImageUrl, targetBucket))
        return { success: false, error: "Invalid pose URL" };

      console.log(
        `[REQ] User=${userId}, Style=${style}, Mode=${mode}, Seed=${seed}`,
      );

      const styleObj = STYLE_MAPPING[style] || STYLE_MAPPING["애니"];
      const finalPrompt = buildPrompt(
        mode,
        styleObj,
        basePrompt,
        promptInput,
        !!referenceImageUrl,
      );

      let usedModelKey = styleObj.baseModel;
      let usedPipeline = "Base";

      if (mode !== "background" && referenceImageUrl) {
        usedModelKey = styleObj.identityModel;
        usedPipeline = "Identity";
      }

      console.log(
        `[EXEC] Pipeline: ${usedPipeline}, Model: ${usedModelKey}, Style: ${style}`,
      );

      let payloadObj = createReplicatePayload(
        usedModelKey,
        finalPrompt,
        styleObj.neg,
        mode === "main" || mode === "background" ? 1024 : 896,
        mode === "main" || mode === "background" ? 768 : 1152,
        seed,
        referenceImageUrl,
        poseImageUrl,
        mode,
      );

      // [핵심 변경 B안] 생성 요청 전에 '최신 버전'을 먼저 확보하여 422 원천 차단
      // 잘못된 버전으로 찌르지 않으므로 -> 422 안 남 -> 재시도 안 함 -> 429 안 남
      const modelInfo = MODEL_REGISTRY[usedModelKey];
      const versionToUse = await getModelVersionCached(
        CONFIG_API_KEY,
        modelInfo,
      );
      payloadObj.version = versionToUse;

      let prediction;
      try {
        const created = await callReplicate(
          CONFIG_API_KEY,
          payloadObj.version,
          payloadObj.input,
        );
        prediction = await pollReplicate(CONFIG_API_KEY, created.urls.get);
      } catch (reqErr) {
        // 만약 그래도 422나면 최후의 수단으로 재시도 (빈도는 매우 낮을 것임)
        if (isInvalidVersion422(reqErr) && modelInfo.owner && modelInfo.name) {
          console.warn(
            `[AUTO-HEAL] 422 Detected. Waiting 8s for rate limit reset...`,
          );
          await sleep(8000);

          console.warn(`[AUTO-HEAL] Fetching fresh version...`);
          invalidateModelCaches(modelInfo.owner, modelInfo.name);
          const freshVersion = await getModelVersionCached(
            CONFIG_API_KEY,
            modelInfo,
          );
          payloadObj.version = freshVersion;

          const createdRetry = await callReplicate(
            CONFIG_API_KEY,
            payloadObj.version,
            payloadObj.input,
          );
          prediction = await pollReplicate(
            CONFIG_API_KEY,
            createdRetry.urls.get,
          );
        } else if (usedPipeline === "Identity" && !reqErr.isTerminal) {
          console.warn(
            `[FALLBACK] Identity Model failed -> Switch to Base Model`,
          );
          await sleep(8000);

          usedModelKey = styleObj.baseModel;
          const baseInfo = MODEL_REGISTRY[usedModelKey];

          // Base Model Payload 재생성
          payloadObj = createReplicatePayload(
            usedModelKey,
            finalPrompt,
            styleObj.neg,
            896,
            1152,
            seed,
            null,
            null,
            mode,
          );
          // Base 모델도 선 조회
          payloadObj.version = await getModelVersionCached(
            CONFIG_API_KEY,
            baseInfo,
          );

          const created2 = await callReplicate(
            CONFIG_API_KEY,
            payloadObj.version,
            payloadObj.input,
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
          model: usedModelKey,
          pipeline: usedPipeline,
        };
      } catch (e) {
        console.error("Storage Save Failed:", e.message);
        if (e.message.includes("Security Block"))
          return { success: false, error: "Image blocked by security policy." };
        return {
          success: true,
          imageUrl: rawAiUrl,
          seed: seed,
          model: usedModelKey,
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
