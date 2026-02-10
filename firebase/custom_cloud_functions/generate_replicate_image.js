const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// =====================================================
// ✅ 스키마 확인용: true면 최소(prompt/negative_prompt)만 전송
// =====================================================
const MINIMAL_PAYLOAD = false;

// =====================================================
// ✅ 파이프라인 토글
//  - "A_BASE"   : 기존 모델(SDXL)로 A해법 수행 (기본)
//  - "B_CUSTOM" : (나중에) 너의 Comfy 모델을 쓰는 B해법용
// =====================================================
const IMAGE_PIPELINE = process.env.IMAGE_PIPELINE || "A_BASE"; // 기본 A_BASE

// ===============================
// ✅ (1) 스타일/퀄리티 토큰 고정용: 유저 입력에서 제거할 키워드 (서버 강제)
// ===============================
const FORBIDDEN_STYLE_RE =
  /(\bmasterpiece\b|\bbest quality\b|\bhigh quality\b|\banime\b|\bwebtoon\b|\bmanhwa\b|\blineart\b|\bcel shading\b|\bflat color\b|\b8k\b|\b4k\b|\bphotorealistic\b|\brealistic\b|\bcinematic\b|\brender\b|\bstyle\b|\bquality\b)/gi;

// ===============================
// ✅ (2) 서버에서만 고정할 생성 파라미터 (클라 값 무시)
// - SDXL schema 기준: num_inference_steps, guidance_scale, scheduler
// ===============================
const GEN_PARAMS_SDXL = {
  num_inference_steps: 30, // 고정
  guidance_scale: 7.5, // 고정
  scheduler: "K_EULER", // 고정 (SDXL 기본값과 동일)   [oai_citation:1‡Replicate](https://replicate.com/stability-ai/sdxl/versions/7762fd07cf82c948538e41f63f77d685e02b063e37e496e96eefd46c929f9bdc/api?utm_source=chatgpt.com)
  apply_watermark: true, // 필요시 false 가능 (정책/운영 고려)
};

// ===============================
// ✅ (3) "IP-Adapter 스케일" 대신 SDXL img2img의 prompt_strength를 모드별 상한(clamp)
// - prompt_strength: 1.0 = 레퍼런스 거의 파괴, 0.x = 레퍼런스 보존
// - 동일성(아이덴티티) 유지가 목표면 일반적으로 "너무 높이면" 얼굴이 변함
// ===============================
const PROMPT_STRENGTH_CAP = {
  emotion: { base: 0.55, max: 0.65 }, // 표정 바꾸되 동일성 유지 최우선
  situation: { base: 0.65, max: 0.75 }, // 전신/동작은 조금 더 자유
  main: { base: 0.7, max: 0.8 }, // 커버는 연출 자유 조금 허용
  event: { base: 0.65, max: 0.75 },
  character: { base: null, max: null }, // txt2img
  background: { base: null, max: null }, // txt2img
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

// Replicate version 캐시(필요시만)
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

// ✅ 유저 입력에서 스타일/퀄리티 토큰 제거(서버 강제)
function stripStyleTokens(text) {
  if (!text) return "";
  return String(text)
    .replace(FORBIDDEN_STYLE_RE, " ")
    .replace(/\s+/g, " ")
    .trim();
}

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
  return `(${bp}:${w.toFixed(2)})`;
}

// ✅ 모드별 해상도/비율 고정 (서버 강제)
function fixedSizeByMode(mode) {
  const isWide = mode === "main" || mode === "background";
  const isProfileSquare = mode === "character";
  const width = isWide ? 1024 : isProfileSquare ? 1024 : 896;
  const height = isWide ? 768 : isProfileSquare ? 1024 : 1152;
  return { width, height };
}

// ✅ SDXL img2img prompt_strength clamp (서버 강제)
function clampPromptStrength(mode, maybeUserStrength) {
  const cap = PROMPT_STRENGTH_CAP[mode] || PROMPT_STRENGTH_CAP.situation;
  if (cap.base == null) return undefined;

  let v = cap.base;
  if (maybeUserStrength !== undefined && maybeUserStrength !== null) {
    const n = Number(maybeUserStrength);
    if (!Number.isNaN(n) && n > 0) v = n;
  }
  if (v > cap.max) v = cap.max;
  if (v < 0.05) v = 0.05;
  return v;
}

/** ---------------------------------------------------------
 * ✅ 스타일 프리셋(앱에서 바꾸지 못하게 “서버에서만” 사용)
 * - A해법(기존모델)에서도 스타일 흔들림 방지에 필요
 * --------------------------------------------------------- */
const STYLE_MAPPING = {
  애니: {
    prefix:
      "masterpiece, best quality, high quality anime illustration, light novel illustration, soft shading, clean lineart, smooth gradients, glossy eyes, detailed hair, delicate highlights",
    neg: "lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, jpeg artifacts, signature, watermark, username, blurry, character sheet, reference sheet, turnaround, multiple views, collage, panel, split view, multiple characters, 2girls, 2people, crowd, chibi",
  },
  웹툰: {
    prefix:
      "masterpiece, best quality, webtoon style, manhwa, bold outlines, flat color, vivid colors",
    neg: "lowres, bad anatomy, bad hands, speech bubble, caption, text, dialog box, typeset, panel borders, split view, multiple views, multiple characters, crowd",
  },
};

/** ---------------------------------------------------------
 * ✅ Replicate 모델 레지스트리
 * - A_BASE: stability-ai/sdxl (공식 API 스키마)  [oai_citation:2‡Replicate](https://replicate.com/stability-ai/sdxl/versions/7762fd07cf82c948538e41f63f77d685e02b063e37e496e96eefd46c929f9bdc/api?utm_source=chatgpt.com)
 * - B_CUSTOM: (나중에) 너의 comfy 모델
 * --------------------------------------------------------- */
const MODEL_REGISTRY = {
  A_BASE_SDXL: {
    owner: "stability-ai",
    name: "sdxl",
    version: "7762fd07cf82c948538e41f63f77d685e02b063e37e496e96eefd46c929f9bdc",
    schema: "SDXL",
  },
  B_CUSTOM_PEACH_COMFY: {
    owner: "peachspace",
    name: "peach-comfy-anime",
    version: "205534767bb5412bfeccb2e8f2af1042ef2a5473e17eec9bf59248acc2beef2c",
    schema: "COMFY", // (나중에 켤 용도)
  },
};

function buildPrompt(mode, styleObj, basePromptRaw, scenePromptRaw) {
  // ✅ 서버에서 스타일토큰 제거(유저 입력에 섞여 들어오면 제거)
  const basePrompt = stripStyleTokens(basePromptRaw);
  let scenePrompt = stripStyleTokens(scenePromptRaw);

  const gender = pickGenderToken(basePrompt);
  const single = gender
    ? `solo, ${gender}, single character, centered composition`
    : "solo, single character, centered composition";

  let finalScene = String(scenePrompt || "").trim();

  // emotion: 첫 단어 감정키 매핑
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

  // ✅ 해법 A: 불변 속성 태그(가중치) 강제
  const identityTags = buildIdentityTags(mode, basePrompt);

  const parts = [];

  if (mode === "background") {
    parts.push("scenery, no humans");
    parts.push(styleObj.prefix);
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
    parts.push(styleObj.prefix);
    if (identityTags) parts.push(identityTags);
    parts.push("neutral expression");
    parts.push("not a close-up, subject not too large in frame");
    if (finalScene) parts.push(finalScene); // character에서도 입력을 허용하되, 서버 strip 적용됨
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
    parts.push(styleObj.prefix);
    if (identityTags) parts.push(identityTags);
    if (finalScene) parts.push(finalScene);
    return parts.filter(Boolean).join(", ");
  }

  if (mode === "situation") {
    parts.push(single);
    parts.push("full body, dynamic action pose");
    parts.push(styleObj.prefix);
    if (identityTags) parts.push(identityTags);
    if (finalScene) parts.push(`(${finalScene}:1.2)`);
    return parts.filter(Boolean).join(", ");
  }

  if (mode === "main") {
    parts.push(single);
    parts.push("cover art, cinematic composition");
    parts.push(styleObj.prefix);
    if (identityTags) parts.push(identityTags);
    if (finalScene) parts.push(finalScene);
    parts.push("dramatic lighting, detailed background");
    return parts.filter(Boolean).join(", ");
  }

  parts.push(single);
  parts.push(styleObj.prefix);
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

/** ---------------------------------------------------------
 * ✅ A_BASE(SDXL) payload 생성
 * - character/background: txt2img (image 없음)
 * - emotion/situation/main/event: img2img (image=referenceImageUrl)
 * - prompt_strength를 모드별 clamp로 "레퍼런스 영향 상한" 구현
 * --------------------------------------------------------- */
function createSdxlPayload({
  prompt,
  negative,
  width,
  height,
  seed,
  mode,
  referenceImageUrl,
  userPromptStrength,
}) {
  const input = {
    prompt,
    negative_prompt: negative,
    width,
    height,
    seed,

    // ✅ 서버 고정 파라미터
    num_inference_steps: GEN_PARAMS_SDXL.num_inference_steps,
    guidance_scale: GEN_PARAMS_SDXL.guidance_scale,
    scheduler: GEN_PARAMS_SDXL.scheduler,
    apply_watermark: GEN_PARAMS_SDXL.apply_watermark,
  };

  // img2img일 때만 image + prompt_strength 추가   [oai_citation:3‡Replicate](https://replicate.com/stability-ai/sdxl/versions/7762fd07cf82c948538e41f63f77d685e02b063e37e496e96eefd46c929f9bdc/api?utm_source=chatgpt.com)
  if (referenceImageUrl) {
    input.image = referenceImageUrl;
    const ps = clampPromptStrength(mode, userPromptStrength);
    if (ps !== undefined) input.prompt_strength = ps;
  }

  return { version: null, input };
}

/** ---------------------------------------------------------
 * ✅ (나중에) B_CUSTOM(Comfy)용 payload는 여기서 분기 구현 가능
 * - 지금은 A해법만 쓰므로, 호출 분기만 남겨둠
 * --------------------------------------------------------- */
function createComfyPayloadPlaceholder() {
  throw new Error(
    "B_CUSTOM pipeline is disabled in this deployment. Use IMAGE_PIPELINE=A_BASE.",
  );
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

      // 유저 입력
      const promptInputRaw = String(data.prompt || "").trim();
      const basePromptRaw = String(data.basePrompt || "").trim();

      const referenceImageUrl = String(data.referenceImageUrl || "").trim();
      const poseImageUrl = String(data.poseImageUrl || "").trim(); // A_BASE에서는 사용 안 함(검증만)
      const seed = safeSeed(data.seed);

      // reference 필수(너 로직 유지): character만 예외
      if (mode !== "character" && mode !== "background" && !referenceImageUrl) {
        return { success: false, error: "referenceImageUrl required." };
      }

      // 버킷 검증
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

      // ✅ 최종 프롬프트(서버에서 스타일토큰 제거 + 불변속성 가중치 강제)
      const finalPrompt = buildPrompt(
        mode,
        styleObj,
        basePromptRaw,
        promptInputRaw,
      );

      // ✅ 서버에서만 해상도/비율 고정
      const { width, height } = fixedSizeByMode(mode);

      // ✅ 파이프라인별 모델 선택
      const modelInfo =
        IMAGE_PIPELINE === "B_CUSTOM"
          ? MODEL_REGISTRY.B_CUSTOM_PEACH_COMFY
          : MODEL_REGISTRY.A_BASE_SDXL;

      if (!modelInfo) throw new Error("Model registry missing.");

      // ✅ payload 구성
      let payloadObj;
      if (MINIMAL_PAYLOAD) {
        // 최소 스키마 확인용
        payloadObj = {
          version: null,
          input: {
            prompt: finalPrompt,
            negative_prompt: styleObj.neg,
          },
        };
      } else {
        if (modelInfo.schema === "SDXL") {
          // SDXL: img2img는 image + prompt_strength 사용   [oai_citation:4‡Replicate](https://replicate.com/stability-ai/sdxl/versions/7762fd07cf82c948538e41f63f77d685e02b063e37e496e96eefd46c929f9bdc/api?utm_source=chatgpt.com)
          const useImg2Img =
            mode !== "character" &&
            mode !== "background" &&
            !!referenceImageUrl;

          payloadObj = createSdxlPayload({
            prompt: finalPrompt,
            negative: styleObj.neg,
            width,
            height,
            seed,
            mode,
            referenceImageUrl: useImg2Img ? referenceImageUrl : null,
            userPromptStrength: data.promptStrength, // 있어도 clamp됨
          });
        } else if (modelInfo.schema === "COMFY") {
          payloadObj = createComfyPayloadPlaceholder(); // 지금은 A해법만
        } else {
          throw new Error(`Unknown schema: ${modelInfo.schema}`);
        }
      }

      // version (핀을 기본으로 쓰되, 필요하면 캐시로 최신도 가능)
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
        // version 문제면 최신으로 재시도(보험)
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
          pipeline: IMAGE_PIPELINE,
        };
      } catch (e) {
        return {
          success: true,
          imageUrl: rawAiUrl,
          seed,
          model: `${modelInfo.owner}/${modelInfo.name}`,
          pipeline: `${IMAGE_PIPELINE}_STORAGE_FALLBACK`,
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
