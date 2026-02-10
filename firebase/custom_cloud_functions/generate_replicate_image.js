const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// =====================================================
// ✅ 스키마 불일치 확인용 스위치 (true면 prompt/negative_prompt만 보냄)
// =====================================================
const MINIMAL_PAYLOAD = false; // 필요할 때 true로 바꿔서 테스트

// ===============================
// ✅ (1) 스타일/퀄리티 토큰 고정용: 유저 입력에서 제거할 키워드
// ===============================
const FORBIDDEN_STYLE_RE =
  /(\bmasterpiece\b|\bbest quality\b|\bhigh quality\b|\banime\b|\bwebtoon\b|\bmanhwa\b|\blineart\b|\bcel shading\b|\bflat color\b|\b8k\b|\b4k\b|\bphotorealistic\b|\brealistic\b|\bcinematic\b|\brender\b|\bstyle\b|\bquality\b)/gi;

// ===============================
// ✅ (2) 서버에서만 고정할 생성 파라미터(클라 값 무시)
// - 너 workflow(ComfyUI)가 받는 키로만 유지해야 함
// ===============================
const GEN_PARAMS = {
  steps: 7,
  cfg: 2.6,
  // sampler가 workflow input으로 존재한다면 여기에 고정 (없으면 아예 보내지 말 것)
  // sampler: "euler_a",
};

// ===============================
// ✅ (3) IP-Adapter 모드별 상한(clamp)
// ===============================
const IP_CAP = {
  character: { base: 0.7, max: 0.75 },
  emotion: { base: 0.85, max: 0.9 },
  situation: { base: 0.9, max: 0.95 },
  main: { base: 0.9, max: 0.95 },
  event: { base: 0.85, max: 0.9 },
  background: { base: 0.0, max: 0.0 }, // 배경은 reference 영향 거의 필요 없음(원하면 조정)
};

// [중요] 사용자님의 버킷 주소 (기존 유지)
const MANUAL_BUCKET_FALLBACK = "ssss-ehfczw.firebasestorage.app";

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

// Replicate version 캐시
const MODEL_VERSION_CACHE = new Map();
const MODEL_VERSION_TTL_MS = 10 * 60 * 1000;
const MODEL_VERSION_INFLIGHT = new Map();

/** -----------------------------
 * 감정 맵(기존 유지)
 * ----------------------------- */
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

/** ---------------------------------------------------------
 * ✅ ComfyUI 모델 레지스트리 (핀 version 사용)
 * --------------------------------------------------------- */
const MODEL_REGISTRY = {
  PEACH_COMFY_ANIME: {
    owner: "peachspace",
    name: "peach-comfy-anime",
    version: "205534767bb5412bfeccb2e8f2af1042ef2a5473e17eec9bf59248acc2beef2c",
    schema: "PEACH_COMFY_ANIME",
  },
};

const STYLE_MAPPING = {
  애니: {
    modelKey: "PEACH_COMFY_ANIME",
    prefix:
      "masterpiece, best quality, high quality anime illustration, light novel illustration, soft shading, clean lineart, smooth gradients, glossy eyes, detailed hair, delicate highlights",
    neg: "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, jpeg artifacts, signature, watermark, username, blurry, character sheet, reference sheet, turnaround, multiple views, collage, panel, split view, multiple characters, 2girls, 2people, crowd, chibi",
  },
  웹툰: {
    modelKey: "PEACH_COMFY_ANIME",
    prefix:
      "masterpiece, best quality, webtoon style, manhwa, bold outlines, flat color, vivid colors",
    neg: "lowres, bad anatomy, bad hands, speech bubble, caption, text, dialog box, typeset, panel borders, split view, multiple views, multiple characters, crowd",
  },
};

function normalizeStyle(raw) {
  const s = String(raw || "애니").trim();
  if (s.includes("웹툰")) return "웹툰";
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
  if (m.includes("event")) return "event";
  return "character";
}

// ✅ 유저 입력에서 스타일/퀄리티 토큰 제거(서버 강제)
function stripStyleTokens(text) {
  if (!text) return "";
  return String(text)
    .replace(FORBIDDEN_STYLE_RE, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function pickGenderToken(basePrompt) {
  const bp = String(basePrompt || "").toLowerCase();
  if (bp.includes("1boy")) return "1boy";
  if (bp.includes("1girl")) return "1girl";
  if (bp.includes("male") || bp.includes("man") || bp.includes("boy"))
    return "1boy";
  if (bp.includes("female") || bp.includes("woman") || bp.includes("girl"))
    return "1girl";
  return "";
}

// ✅ 해법 A(불변 속성 태그) 강제 가중치: 모드별 weight
function identityWeightByMode(mode) {
  if (mode === "emotion") return 1.2;
  if (mode === "situation") return 1.1;
  if (mode === "main") return 1.1;
  if (mode === "event") return 1.1;
  if (mode === "character") return 1.15;
  return 1.05;
}

function buildIdentityTags(mode, basePrompt) {
  const bp = String(basePrompt || "").trim();
  if (!bp) return "";
  if (mode === "background") return "";
  const w = identityWeightByMode(mode);
  // ✅ 불변 속성 태그는 항상 강하게 고정
  return `(${bp}:${w.toFixed(2)})`;
}

function buildPrompt(mode, styleObj, basePromptRaw, scenePromptRaw) {
  const prefix = styleObj.prefix;

  // ✅✅✅ (1) 유저 입력에서 스타일 토큰 제거 (서버 강제)
  const basePrompt = stripStyleTokens(basePromptRaw);
  let scenePrompt = stripStyleTokens(scenePromptRaw);

  const gender = pickGenderToken(basePrompt);
  const single = gender
    ? `solo, ${gender}, single character, centered composition`
    : "solo, single character, centered composition";

  let finalScene = String(scenePrompt || "").trim();

  if (mode === "emotion") {
    const partsRaw = finalScene.trim().split(/\s+/);
    const rawKey = partsRaw[0] || "";
    const cleanKey = rawKey.replace(/[,\[\]\(\)"]/g, "").trim();
    const mapped =
      EMOTION_MAP[cleanKey] || EMOTION_MAP[cleanKey.replace(/\s+/g, "")];
    if (mapped) {
      const rest = partsRaw.slice(1).join(" ").trim();
      finalScene = rest ? `${mapped}, ${rest}` : mapped;
    }
    finalScene = `(${finalScene}:1.35)`;
  }

  const identityTags = buildIdentityTags(mode, basePrompt);

  const parts = [];

  if (mode === "background") {
    parts.push("scenery, no humans");
    parts.push(prefix);
    if (finalScene) parts.push(finalScene);
    return parts.filter(Boolean).join(", ");
  }

  if (mode === "character") {
    parts.push(single);
    parts.push(
      "upper body, waist up, medium shot, include shoulders and torso",
    );
    parts.push("centered composition, some headroom");
    parts.push("simple background");
    parts.push(prefix);
    if (identityTags) parts.push(identityTags);
    parts.push("neutral expression");
    parts.push("not a close-up, subject not too large in frame");
    return parts.filter(Boolean).join(", ");
  }

  if (mode === "emotion") {
    parts.push(single);
    const lower = String(scenePromptRaw || "").toLowerCase();
    const hasFraming =
      /(full body|upper body|waist up|medium shot|long shot|wide shot|cowboy shot|three-quarter|close-up)/.test(
        lower,
      );
    if (!hasFraming) parts.push("upper body, waist up, medium shot");
    parts.push(prefix);
    if (identityTags) parts.push(identityTags);
    if (finalScene) parts.push(finalScene);
    return parts.filter(Boolean).join(", ");
  }

  if (mode === "situation") {
    parts.push(single);
    parts.push("full body, dynamic action pose");
    parts.push(prefix);
    if (identityTags) parts.push(identityTags);
    if (finalScene) parts.push(`(${finalScene}:1.2)`);
    return parts.filter(Boolean).join(", ");
  }

  if (mode === "main") {
    parts.push(single);
    parts.push("cover art, cinematic composition");
    parts.push(prefix);
    if (identityTags) parts.push(identityTags);
    if (finalScene) parts.push(finalScene);
    parts.push("dramatic lighting, detailed background");
    return parts.filter(Boolean).join(", ");
  }

  parts.push(single);
  parts.push(prefix);
  if (identityTags) parts.push(identityTags);
  if (finalScene) parts.push(finalScene);
  return parts.filter(Boolean).join(", ");
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

// ✅ 모드별 해상도/비율 고정 (서버 강제)
function fixedSizeByMode(mode) {
  const isWide = mode === "main" || mode === "background";
  const isProfileSquare = mode === "character";
  const width = isWide ? 1024 : isProfileSquare ? 1024 : 896;
  const height = isWide ? 768 : isProfileSquare ? 1024 : 1152;
  return { width, height };
}

// ✅ IP-Adapter 스케일 clamp (서버 강제)
function clampIp(mode, maybeUserIp) {
  const cap = IP_CAP[mode] || IP_CAP.character;
  let v = cap.base;

  if (maybeUserIp !== undefined && maybeUserIp !== null) {
    const n = Number(maybeUserIp);
    if (!Number.isNaN(n) && n > 0) v = n;
  }

  if (v > cap.max) v = cap.max;
  if (v < 0) v = 0;
  return v;
}

/** ---------------------------------------------------------
 * ✅ payload 생성 ("" 금지: 값 없으면 key 제거)
 * + (2) steps/cfg/sampler 서버 고정
 * + (3) ip_adapter_scale 모드별 상한
 * --------------------------------------------------------- */
function createPeachComfyPayload({
  prompt,
  negative,
  width,
  height,
  seed,
  referenceImageUrl,
  poseImageUrl,
  mode,
  userIpScale,
}) {
  const input = {
    prompt,
    negative_prompt: negative,
    width,
    height,
    seed,

    // ✅✅✅ (2) 서버에서만 고정
    steps: GEN_PARAMS.steps,
    cfg: GEN_PARAMS.cfg,

    mode: mode,
  };

  // ✅ sampler가 workflow input으로 존재할 때만 사용
  if (GEN_PARAMS.sampler) input.sampler = GEN_PARAMS.sampler;

  // ✅✅✅ (3) reference 있을 때만 ip_adapter_scale 포함
  if (referenceImageUrl) {
    input.ip_adapter_scale = clampIp(mode, userIpScale);
  }

  // ✅✅✅ 핵심: 빈 문자열 넣지 말고, 있을 때만 key 추가
  if (referenceImageUrl) input.reference_image = referenceImageUrl;
  if (poseImageUrl) input.pose_image = poseImageUrl;

  return { version: null, input };
}

/** ---------------------------------------------------------
 * ✅ callReplicate: 4xx도 resp.data 받게 + detail 포함 throw
 * --------------------------------------------------------- */
async function callReplicate(apiKey, version, input) {
  let retries = 3;

  while (true) {
    try {
      const resp = await axios.post(
        "https://api.replicate.com/v1/predictions",
        { version, input },
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            Prefer: "wait=30",
            "Cancel-After": "10m",
          },
          timeout: 45000,
          validateStatus: (s) => s >= 200 && s < 500,
        },
      );

      if (resp.status >= 200 && resp.status < 300) return resp.data;

      throw new Error(
        `Replicate POST failed: ${resp.status} ${JSON.stringify(resp.data)}`,
      );
    } catch (e) {
      const status = e?.response?.status;

      if (retries > 0 && status === 429) {
        const ra = Number(e?.response?.data?.retry_after) || 8;
        await sleep(ra * 1000 + 1000);
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
          prediction.error || `Replicate failed: ${prediction.status}`,
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

  throw new Error("Replicate poll timeout");
}

async function saveToStorage(bucketName, userId, mode, rawAiUrl) {
  if (!isValidOutputUrl(rawAiUrl))
    throw new Error(`Security Block: Unauthorized output host`);

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
  const file = admin
    .storage()
    .bucket(bucketName)
    .file(`users/${userId}/uploads/${fileName}`);

  await file.save(imgResp.data, { metadata: { contentType } });
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
    const CONFIG_API_KEY =
      process.env.REPLICATE_API_KEY || functions.config().replicate?.key;
    if (!CONFIG_BUCKET || !CONFIG_API_KEY)
      return { success: false, error: "Server Config Error." };
    if (!context.auth) return { success: false, error: "Auth required." };

    const userId = context.auth.uid;

    try {
      const mode = normalizeMode(data.mode);
      const style = normalizeStyle(data.style);

      // ✅✅✅ (1) 스타일 토큰 제거는 buildPrompt 내부에서 다시 하지만,
      // 여기서도 1차 trim 정도만 수행
      const promptInput = String(data.prompt || "").trim();
      const basePrompt = String(data.basePrompt || "").trim();

      const referenceImageUrl = String(data.referenceImageUrl || "").trim();
      const poseImageUrl = String(data.poseImageUrl || "").trim();
      const seed = safeSeed(data.seed);

      // 레퍼런스 필수 체크 (character만 예외)
      if (mode !== "character" && !referenceImageUrl) {
        return { success: false, error: "referenceImageUrl required." };
      }

      const targetBucket = normalizeBucketName(CONFIG_BUCKET);

      if (
        referenceImageUrl &&
        !isValidInputUrl(referenceImageUrl, targetBucket)
      ) {
        return { success: false, error: "Invalid ref URL" };
      }
      if (poseImageUrl && !isValidInputUrl(poseImageUrl, targetBucket)) {
        return { success: false, error: "Invalid pose URL" };
      }

      const styleObj = STYLE_MAPPING[style] || STYLE_MAPPING["애니"];
      const modelKey = styleObj.modelKey;

      const finalPrompt = buildPrompt(mode, styleObj, basePrompt, promptInput);

      // ✅✅✅ (2) 해상도/비율 고정은 여기서만 결정
      const { width, height } = fixedSizeByMode(mode);

      // ✅✅✅ 2) payload 최소화 모드(스키마 확인용)
      let payloadObj;
      if (MINIMAL_PAYLOAD) {
        payloadObj = {
          version: null,
          input: {
            prompt: finalPrompt,
            negative_prompt: styleObj.neg,
          },
        };
      } else {
        payloadObj = createPeachComfyPayload({
          prompt: finalPrompt,
          negative: styleObj.neg,
          width,
          height,
          seed,
          referenceImageUrl,
          poseImageUrl,
          mode,
          userIpScale: data.ipAdapterScale, // (있어도 clamp됨)
        });
      }

      const modelInfo = MODEL_REGISTRY[modelKey];
      if (!modelInfo) throw new Error(`Unknown Model Key: ${modelKey}`);

      let versionToUse = modelInfo.version;
      if (!versionToUse)
        versionToUse = await getModelVersionCached(CONFIG_API_KEY, modelInfo);
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
        if (isInvalidVersion422(reqErr) && modelInfo.owner && modelInfo.name) {
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
          seed,
          model: `${modelInfo.owner}/${modelInfo.name}`,
          pipeline: "PEACH_COMFY_ANIME",
        };
      } catch (e) {
        return {
          success: true,
          imageUrl: rawAiUrl,
          seed,
          model: `${modelInfo.owner}/${modelInfo.name}`,
          pipeline: "PEACH_COMFY_ANIME_STORAGE_FALLBACK",
        };
      }
    } catch (error) {
      console.error(
        "Replicate Error:",
        error?.message,
        error?.response?.status,
        JSON.stringify(error?.response?.data || {}),
      );
      return { success: false, error: error?.message || String(error) };
    }
  });
