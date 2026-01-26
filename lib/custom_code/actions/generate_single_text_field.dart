// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';

/// ==============================
/// 같은 스토리에서 모듈팩 일관성 유지용(세션 메모리 캐시)
/// ==============================
class _StoryPack {
  final Map<String, List<String>> modulesByCat;
  final int createdAtMs;
  _StoryPack(this.modulesByCat, this.createdAtMs);
}

// 전역 캐시
final Map<String, _StoryPack> _packCache = {};
String? _activeDraftKey;
int _activeDraftKeyCreatedAtMs = 0;

Future<String> generateSingleTextField(
  String targetFieldName,
  String currentStoryContext,
  String genre,
  String? storyId, // [추가] 스토리 고유 ID (일관성 유지용 seed)
) async {
  // =========================================================
  // 0) 유틸 & 장르 정규화
  // =========================================================
  final String rawGenre = genre.trim().isEmpty ? "기본" : genre.trim();

  final Map<String, List<String>> genreAliases = {
    "현대로맨스": ["현대로맨스", "오피스", "캠퍼스", "로코", "현로"],
    "로맨스판타지": ["로맨스판타지", "로판"],
    "현대판타지": ["현대판타지", "현판"],
    "헌터/던전/게이트": ["헌터", "던전", "게이트"],
    "무협": ["무협"],
    "회귀/빙의/환생": ["회귀", "빙의", "환생", "회빙환"],
    "아카데미/학원": ["아카데미", "학원"],
    "SF": ["SF", "사이파이", "근미래", "디스토피아"],
    "미스터리/추리": ["미스터리", "추리"],
    "스릴러/범죄": ["스릴러", "범죄", "느와르"],
    "공포/오컬트": ["공포", "오컬트", "호러"],
    "힐링/일상": ["힐링", "일상", "드라마"],
    "판타지": ["판타지", "정통판타지"],
  };

  String normalizeGenre(String input) {
    for (final entry in genreAliases.entries) {
      if (input == entry.key) return entry.key;
      for (final a in entry.value) {
        if (input.contains(a)) return entry.key;
      }
    }
    return input.isEmpty ? "기본" : input;
  }

  final String safeGenre = normalizeGenre(rawGenre);
  final String ctx = currentStoryContext.trim();

  String _normWhitespace(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // [수정] cleanBasic 강화 (볼드, 이탤릭, 코드블록 제거)
  String cleanBasic(String s) {
    var out = s.trim();
    // 마크다운 문법 제거
    out = out.replaceAll('**', '').replaceAll('__', '').replaceAll('```', '');
    // 헤더, 리스트, 번호 제거
    out = out.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');
    out = out.replaceAll(RegExp(r'^\s*[-*•]\s+', multiLine: true), '');
    out = out.replaceAll(RegExp(r'^\s*\d+[\.\)]\s*', multiLine: true), '');
    // 따옴표 및 잡다한 접두어 제거
    out = out
        .replaceAll('"', '')
        .replaceAll("'", "")
        .replaceAll("후보:", "")
        .replaceAll("후보", "");
    return out.trim();
  }

  bool containsAll(String text, List<String> keys) {
    for (final k in keys) {
      if (!text.contains(k)) return false;
    }
    return true;
  }

  Future<String> callAi(
    String modelName,
    String systemPrompt,
    String userPrompt,
  ) async {
    // ⚠️ 서버(Cloud Functions)의 타임아웃 설정도 120초 이상으로 늘려야 이 설정이 유효합니다.
    final options = HttpsCallableOptions(timeout: const Duration(seconds: 120));
    final HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('callAiProxy', options: options);

    final result = await callable.call(<String, dynamic>{
      'modelName': modelName,
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    });

    return (result.data['fullText'] ?? '').toString().trim();
  }

  int stableHash(String s) {
    int h = 0;
    for (int i = 0; i < s.length; i++) {
      h = 31 * h + s.codeUnitAt(i);
      h &= 0x7fffffff;
    }
    return h;
  }

  // =========================================================
  // 1) 모듈 카테고리 정의
  // =========================================================
  const String CAT_TROPE = "핵심트로프";
  const String CAT_REL = "관계다이내믹";
  const String CAT_SYSTEM = "시스템/룰";
  const String CAT_CONFLICT = "갈등장치";
  const String CAT_SETPIECE = "1화세트피스";
  const String CAT_TWIST = "비밀/반전";
  const String CAT_TONE = "톤/무드";

  // =========================================================
  // 2) 장르별 톤 그룹
  // =========================================================
  String toneGroupForGenre(String g) {
    if (g == "힐링/일상") return "low";
    if (g == "현대로맨스") return "mid";
    if (g == "미스터리/추리" || g == "스릴러/범죄" || g == "공포/오컬트") return "high";
    if (g == "헌터/던전/게이트" ||
        g == "무협" ||
        g == "판타지" ||
        g == "로맨스판타지" ||
        g == "현대판타지") return "high";
    if (g == "아카데미/학원" || g == "SF" || g == "회귀/빙의/환생") return "mid";
    return "mid";
  }

  final String toneGroup = toneGroupForGenre(safeGenre);

  // =========================================================
  // 3) 글로벌 모듈 뱅크
  // =========================================================
  final Map<String, Map<String, List<String>>> globalByTone = {
    "low": {
      CAT_TONE: [
        "저자극·따뜻한 변화(관계/루틴 중심)",
        "작은 목표 달성의 만족(현실적)",
        "공간이 주는 안정감(동네/집/작업실 등)",
        "회복과 재정비(상처/번아웃/관계 회복)",
      ],
      CAT_CONFLICT: [
        "사소한 오해가 커지기 전에 ‘대화/선택’이 필요한 상황",
        "일정/루틴/생활리듬 충돌로 생기는 갈등",
        "현실 문제(비용/건강/가족)로 작은 위기가 생김",
        "선의가 부담이 되어 관계가 삐걱대는 순간",
      ],
      CAT_TWIST: [
        "누군가의 숨겨진 사정이 드러나며 관계가 바뀜",
        "겉모습과 다른 따뜻한 면이 밝혀짐",
        "작은 목표의 진짜 이유가 공개됨",
      ],
      CAT_SETPIECE: [
        "주요 공간(집/직장/학교/동네)에서 작은 운영·일정 문제가 터짐",
        "부탁/의뢰/선물/실수로 관계가 움직이는 하루",
        "날씨/계절 이벤트가 감정선을 흔드는 하루",
        "소소한 모임/행사 준비 중 작은 충돌과 화해",
      ],
    },
    "mid": {
      CAT_CONFLICT: [
        "계약/규칙/평가가 선택을 강제하는 구도",
        "소문/평판/공개 사건이 관계를 흔듦",
        "자원(돈/점수/권한/시간)이 부족해 갈등이 커짐",
        "마감/시험/발표 같은 데드라인이 사건을 가속",
      ],
      CAT_TWIST: [
        "주인공의 과거/비밀이 현재 사건과 연결됨",
        "상대의 신분/역할이 드러나 판이 바뀜",
        "계약의 진짜 목적이 따로 있음",
        "능력/재능/기술에 대가가 있어 선택이 어려워짐",
      ],
      CAT_SETPIECE: [
        "공개 이벤트 직전 사고(발표/시험/경쟁)",
        "오해/폭로가 퍼져 수습해야 하는 날",
        "마감 직전 팀 붕괴 위기 또는 책임 공방",
        "돌발 재회/방문/통보로 계획이 깨짐",
      ],
    },
    "high": {
      CAT_CONFLICT: [
        "권력/세력 다툼이 배후에서 사건을 조종",
        "계약/서약/금기가 함정이 되어 대가가 즉시 발생",
        "정산/독점/세금/입찰 같은 ‘룰’이 전쟁을 부름",
        "인질/담보/약점 노출로 선택을 강요받음",
        "시한 제한(폭주/추살/붕괴/봉쇄)이 가속",
      ],
      CAT_TWIST: [
        "배후 세력이 뒤집히며 적/아군이 바뀜",
        "증거 조작/누명으로 궁지에 몰림",
        "정체/혈통/각성 조건이 반전",
        "능력의 대가가 커져 더 큰 선택을 요구",
      ],
      CAT_SETPIECE: [
        "습격/암살/급습 시도",
        "배신/계약 파기로 판이 뒤집힘",
        "징계/추방/재판 통보로 벼랑 끝",
        "미확인 재난(게이트/괴이/역병) 발생",
        "결전(비무/레이드/추적) 전야의 선택",
      ],
    },
  };

  // =========================================================
  // 4) 장르별 모듈 뱅크
  // =========================================================
  final Map<String, Map<String, List<String>>> genreModules = {
    "현대로맨스": {
      CAT_TROPE: [
        "오피스/프로젝트 공조에서 혐관→존중→감정 역전",
        "계약 관계(위장/동거/프로젝트)에서 진심이 새어 나옴",
        "재회(오해/사건 후유증)로 재점화되는 감정선",
        "평가/승진/입시 같은 경쟁이 사랑을 방해",
        "갑을 구조(상사-부하/교수-조교)에서 역전",
        "친구→연인(타이밍 전쟁)",
      ],
      CAT_REL: [
        "혐관(말이 날카롭고 경계가 빡빡)",
        "상호이용(감정 없는 척하지만 의존)",
        "구원/보호(위기에서 손 내밀기)",
        "질투/오해(증거는 애매, 감정은 확실)",
        "비밀연애(평판 리스크)",
      ],
      CAT_SYSTEM: [
        "평가/인사/승진/성과/장학 시스템",
        "사내정치/소문망/커뮤니티 여론",
        "주거·돈 압박(대출/보증/위약금)",
        "가족/친척 간섭(체면/결혼/상속)",
      ],
      CAT_SETPIECE: [
        "공개 발표/피치/경쟁 PT 직전 사고",
        "모임/회식/행사에서의 실수와 오해 확산",
        "책임 전가/평가 조작 의혹",
        "계약 조항 발동(위약금/동거 파기)",
      ],
    },
    // ... (다른 장르들은 기존 코드의 genreModules 내용 그대로 사용하면 됩니다.
    // 내용이 너무 길어 생략된 부분은 기존 코드를 그대로 유지하세요.)
    // 예시: "로맨스판타지", "현대판타지", "무협" 등...
    "기본": {
      CAT_TROPE: ["핵심 훅 1개 중심", "목표와 갈등 충돌", "룰/대가가 있는 세계"],
      CAT_REL: ["갈등에서 신뢰로", "상호이용에서 감정 변화"],
      CAT_SYSTEM: ["돈/권력/평판/법", "규정/계약/서약"],
      CAT_SETPIECE: ["첫 사건이 터지는 날", "폭로/오해/사고"],
    }
  };

  // =========================================================
  // 5) 모듈팩 선택 (storyId 적용)
  // =========================================================
  List<String> pickN(Random r, List<String> pool, int n) {
    if (pool.isEmpty || n <= 0) return [];
    final copy = List<String>.from(pool);
    copy.shuffle(r);
    return copy.take(min(n, copy.length)).toList();
  }

  List<String> mergedPool(String cat) {
    final List<String> pool = [];
    final g = genreModules[safeGenre] ?? genreModules["기본"]!;
    if (g.containsKey(cat)) pool.addAll(g[cat]!);

    final toneGlobals = globalByTone[toneGroup];
    if (toneGlobals != null && toneGlobals.containsKey(cat)) {
      pool.addAll(toneGlobals[cat]!);
    }
    return pool;
  }

  // [수정] storyId(seed)를 최우선으로 사용하여 키 생성
  String makeStoryKey() {
    // 1. storyId가 있으면 이걸로 고정 (앱 재시작해도 일관성 유지됨)
    final sid = storyId?.trim() ?? "";
    if (sid.isNotEmpty) {
      return "sid_${stableHash("$safeGenre|$sid")}";
    }

    // 2. 없으면 context 기반 (기존 방식)
    final normalized = _normWhitespace(ctx);
    if (normalized.isNotEmpty) {
      return "k_${stableHash("$safeGenre|$normalized")}";
    }

    // 3. 둘 다 없으면 시간 기반 임시 키 (메모리 캐시용)
    final now = DateTime.now().millisecondsSinceEpoch;
    const ttlMs = 3 * 60 * 1000;
    if (_activeDraftKey != null && (now - _activeDraftKeyCreatedAtMs) < ttlMs) {
      return _activeDraftKey!;
    }
    _activeDraftKey = "draft_$now";
    _activeDraftKeyCreatedAtMs = now;
    return _activeDraftKey!;
  }

  Map<String, List<String>> getOrCreateModulePack() {
    final String key = makeStoryKey();
    final now = DateTime.now().millisecondsSinceEpoch;

    const cacheTtlMs = 10 * 60 * 1000;
    final cached = _packCache[key];
    if (cached != null && (now - cached.createdAtMs) < cacheTtlMs) {
      return cached.modulesByCat;
    }

    final seed = stableHash(key);
    final r = Random(seed);

    final pack = <String, List<String>>{};
    pack[CAT_TROPE] = pickN(r, mergedPool(CAT_TROPE), 2);
    pack[CAT_REL] = pickN(r, mergedPool(CAT_REL), 1);
    pack[CAT_SYSTEM] = pickN(r, mergedPool(CAT_SYSTEM), 1);
    pack[CAT_CONFLICT] = pickN(r, mergedPool(CAT_CONFLICT), 1);
    pack[CAT_SETPIECE] = pickN(r, mergedPool(CAT_SETPIECE), 1);

    final twistChance =
        (toneGroup == "low") ? 0.30 : (toneGroup == "mid" ? 0.55 : 0.70);
    pack[CAT_TWIST] = (r.nextDouble() < twistChance)
        ? pickN(r, mergedPool(CAT_TWIST), 1)
        : [];

    if (safeGenre == "힐링/일상") {
      pack[CAT_TONE] = pickN(r, mergedPool(CAT_TONE), 1);
    }

    _packCache[key] = _StoryPack(pack, now);
    return pack;
  }

  final modulePack = getOrCreateModulePack();

  String joinBullets(List<String> xs) {
    final filtered = xs.where((e) => e.trim().isNotEmpty).toList();
    if (filtered.isEmpty) return "- (선택 없음)";
    return filtered.map((e) => "- $e").join("\n");
  }

  String modulesBlock() {
    final toneLine = modulePack.containsKey(CAT_TONE)
        ? "\n(톤/무드)\n${joinBullets(modulePack[CAT_TONE] ?? [])}\n"
        : "";
    return """
[참고 시드(그대로 복사/나열 금지)]
- 아래 문장을 출력에 그대로 옮기지 말고, 맥락에 맞게 ‘치환/변형’해서 사용.
- 특정 소재가 맞지 않으면 같은 기능의 다른 요소로 교체.

(핵심트로프)
${joinBullets(modulePack[CAT_TROPE] ?? [])}

(관계다이내믹)
${joinBullets(modulePack[CAT_REL] ?? [])}

(시스템/룰)
${joinBullets(modulePack[CAT_SYSTEM] ?? [])}

(갈등장치)
${joinBullets(modulePack[CAT_CONFLICT] ?? [])}

(1화세트피스)
${joinBullets(modulePack[CAT_SETPIECE] ?? [])}

(비밀/반전 - 선택)
${joinBullets(modulePack[CAT_TWIST] ?? [])}
$toneLine
"""
        .trim();
  }

  // =========================================================
  // 6) 필드별 프롬프트 분기
  // =========================================================
  String selectedModel = 'solar-mini';
  String specificInstruction = '';

  final bool isTitle =
      targetFieldName.contains('제목') || targetFieldName.contains('타이틀');
  final bool isWorld = targetFieldName.contains('세계관');
  final bool isCharName = targetFieldName.contains('캐릭터 이름');
  final bool isCharSet =
      targetFieldName.contains('캐릭터 설정') || targetFieldName.contains('성격');
  final bool isIntro =
      targetFieldName.contains('캐릭터 소개') || targetFieldName.contains('소개');
  final bool isUserRole =
      targetFieldName.contains('유저역할') || targetFieldName.contains('유저 역할');
  final bool isPrologue = targetFieldName.contains('프롤로그');

  if (isTitle) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[요청]
- 웹소설 제목 후보 12개.
- 각 줄에 제목만 1개씩(번호/따옴표/접두어 금지).
- 훅이 보이게(갈등/목표/리스크 암시).
""";
  } else if (isWorld) {
    selectedModel = 'solar-pro';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[출력 형식] (라벨명 변경 금지)
핵심 갈등:
세계 규칙/대가(선택):
압박 축(1~2):
세력 구도(최소 2):
고유명사 묶음(3~7):
1화 점화 사건:
전개 레일(1~3화 필연 충돌 3줄):
씬 패키지(장소 2~5 + 감각 디테일 + 소문/계약/리스크 2개):

[분량] 800~1200자
""";
  } else if (isCharName) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[요청]
- 캐릭터 이름 후보 10개.
- 각 줄에 이름만(번호/설명 금지).
""";
  } else if (isCharSet) {
    selectedModel = 'solar-pro';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[출력 형식] (라벨명 변경/추가 금지, 한 줄에 하나)
이름:
나이:
성별:
직업/신분:

핵심 욕망(장기목표):
단기 목표(1~3화):
공포/핵심 불안:
문제해결 전략(습관):
레버리지(무기/자원/인맥):

외형(핵심3):
시그니처(소품/흉터/버릇):
대표 의상:

성격-장점:
성격-단점:
성격-트리거(버튼):

말투-규칙1:
말투-규칙2:
자주쓰는표현1:
자주쓰는표현2:
예시대사1(15~28자):
예시대사2(15~28자):
예시대사3(15~28자):

비밀(들키면 끝):
약점1:
약점2:
관계/갈등포인트:
세계관 연결:
1화 행동(점화 사건에서 선택):
첫등장장면(3문장): 행동→대사→결과

[분량] 900~1400자
""";
  } else if (isIntro) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[요청]
- 2~3문장.
- 평가 대신 사건/결핍/위험으로 매력 보여주기.
- 마지막 문장에 선택을 강요하는 리스크 1개 심기.
""";
  } else if (isUserRole) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[요청]
- '당신은'으로 시작. 5~7문장.
- 신분, 목표, 금기, 자원, 즉시 사건 포함.
""";
  } else if (isPrologue) {
    selectedModel = 'solar-pro';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[요청]
- 900~1500자. 도입→확대→절벽.
- 아래 포맷 필수:
[Image: 태그명]
[Dialogue] (이름|대사)
[Narration] (지문)
- 마지막은 다음 턴을 부르는 한 줄.
""";
  } else {
    selectedModel = 'solar-mini';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[요청]
- '$targetFieldName'에 들어갈 내용을 설정 문서 톤으로 작성.
- 추상어 대신 고유명사/구체명사 중심.
""";
  }

  // =========================================================
  // 7) 호출 및 결과 반환
  // =========================================================
  final String systemPrompt = """
당신은 웹소설 시장의 전개 패턴(트로프/관계/시스템)을 폭넓게 이해한 기획자입니다.
목표: 사용자가 버튼을 누르면, 장르에 맞는 ‘알차고 훌륭한 설정’을 자동으로 작성합니다.

[필수 최소]
- 핵심 갈등 1개는 반드시 존재
- 1화 점화 사건 1개는 반드시 존재
- 고유명사(지명/제도/조직/물건) 최소 3개는 반드시 포함

[출력 규칙]
- 체크리스트처럼 ‘나열’하지 말고, 사건→선택→결과로 인과 연결
- 장르 톤을 유지(힐링/일상은 저자극, 미스터리는 초능력/우연 금지 등 상식선 준수)
- 출력은 사용자가 요청한 형식만. 메타설명/해설 금지

[시드 사용 규칙]
- 제공된 ‘참고 시드’ 문장을 출력에 그대로 복사/나열하지 말 것
- 맞지 않는 소재는 같은 기능의 다른 요소로 반드시 치환/변형
""";

  String output;
  try {
    output = await callAi(selectedModel, systemPrompt, specificInstruction);
  } catch (e) {
    return "생성 오류: $e";
  }

  output = cleanBasic(output);

  // 제목/이름 리스트 정리
  if (isTitle || isCharName) {
    final lines = output
        .split('\n')
        .map((e) => cleanBasic(e))
        .where((e) => e.isNotEmpty)
        .toList();

    final uniq = <String>{};
    final cleaned = <String>[];
    for (final l in lines) {
      if (!uniq.contains(l)) {
        uniq.add(l);
        cleaned.add(l);
      }
    }
    return cleaned.join('\n').trim();
  }

  // =========================================================
  // 8) 라벨 누락 시 자가 수리 (Repair)
  // =========================================================
  Future<String> repairOnce({
    required String original,
    required List<String> mustKeys,
    required int minChars,
    required int maxChars,
  }) async {
    if (containsAll(original, mustKeys)) return original.trim();

    final fixPrompt = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

[요청]
- 아래 출력은 필수 라벨이 누락되었습니다.
- 라벨명을 정확히 지켜 누락 항목을 보완한 '완성본'만 출력하세요.
- 분량은 대략 ${minChars}~${maxChars}자.
- 기존 내용의 방향/톤/고유명사는 유지.

[기존 출력]
$original
""";
    try {
      final fixed = await callAi(selectedModel, systemPrompt, fixPrompt);
      return cleanBasic(fixed);
    } catch (_) {
      return original.trim();
    }
  }

  if (isWorld) {
    output = await repairOnce(
      original: output,
      mustKeys: [
        "핵심 갈등:",
        "압박 축",
        "세력 구도",
        "고유명사",
        "1화 점화 사건",
        "전개 레일",
        "씬 패키지",
      ],
      minChars: 800,
      maxChars: 1200,
    );
  }

  if (isCharSet) {
    output = await repairOnce(
      original: output,
      mustKeys: [
        "이름:",
        "나이:",
        "직업/신분:",
        "핵심 욕망",
        "단기 목표",
        "공포",
        "문제해결",
        "레버리지",
        "외형",
        "성격-장점",
        "성격-단점",
        "성격-트리거",
        "말투-규칙1",
        "첫등장장면",
      ],
      minChars: 900,
      maxChars: 1400,
    );
  }

  return output.trim();
}
