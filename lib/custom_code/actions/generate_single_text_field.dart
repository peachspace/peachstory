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
  String? storyId,
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

  String cleanBasic(String s) {
    var out = s.trim();
    out = out.replaceAll('**', '').replaceAll('__', '').replaceAll('```', '');
    out = out.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');
    out = out.replaceAll(RegExp(r'^\s*[-*•]\s+', multiLine: true), '');
    // 숫자 리스트 제거 (1. 2. 등)
    out = out.replaceAll(RegExp(r'^\s*\d+[\.\)]\s*', multiLine: true), '');
    out = out
        .replaceAll('"', '')
        .replaceAll("'", "")
        .replaceAll("후보:", "")
        .replaceAll("후보", "")
        .replaceAll("Option", "")
        .replaceAll("옵션", "")
        .replaceAll("대안", "");
    return out.trim();
  }

  String firstNonEmptyLine(String s) {
    final lines = s
        .split('\n')
        .map((e) => cleanBasic(e))
        .map((e) => e.replaceAll(RegExp(r'^(제목|타이틀|이름)\s*[:\-]\s*'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return lines.isEmpty ? "" : lines.first;
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
  // 2) 글로벌 모듈 뱅크 (톤별 공통 강화)
  // =========================================================
  final Map<String, Map<String, List<String>>> globalByTone = {
    "low": {
      CAT_TONE: [
        "저자극·따뜻한 변화(관계/루틴 중심)",
        "작은 목표 달성의 만족(현실적)",
        "공간이 주는 안정감(동네/집/작업실)",
        "회복과 재정비(상처/번아웃/관계 회복)",
      ],
      CAT_TROPE: [
        "사소한 사건이 ‘관계의 방향’을 바꾸는 구조",
        "좋은 의도가 오해로 비틀리며 성장하는 흐름",
        "루틴 붕괴 → 재정렬 → 더 단단한 일상",
      ],
      CAT_REL: [
        "대화가 부족한 두 사람이 ‘행동’으로 증명",
        "배려가 과해 부담이 되는 관계",
      ],
      CAT_SYSTEM: [
        "생활비/시간/건강 같은 현실 압박",
        "동네 커뮤니티/가족/직장 내 소문",
      ],
      CAT_CONFLICT: [
        "사소한 오해가 커지기 전에 ‘대화/선택’이 필요한 상황",
        "일정/루틴/생활리듬 충돌",
        "선의가 부담이 되어 관계가 삐걱",
      ],
      CAT_TWIST: [
        "누군가의 숨겨진 사정이 드러나며 관계가 바뀜",
        "작은 목표의 진짜 이유가 공개됨",
      ],
      CAT_SETPIECE: [
        "주요 공간에서 작은 운영·일정 문제가 터짐",
        "날씨/계절 이벤트가 감정선을 흔드는 하루",
        "부탁/의뢰/선물/실수로 관계가 움직이는 하루",
      ],
    },
    "mid": {
      CAT_TROPE: [
        "계약/평가/룰 때문에 관계가 밀당 구조로 변형",
        "공개 사건(소문/스캔들)으로 갈등이 가속",
        "승부(시험/경쟁/성과)가 감정선을 찢어놓음",
      ],
      CAT_REL: [
        "혐관→존중→감정 역전",
        "상호이용→의존→진심 새어 나옴",
      ],
      CAT_SYSTEM: [
        "평가/승진/시험/프로젝트 룰",
        "평판/소문/커뮤니티 여론",
        "계약 조항/위약금/약속",
      ],
      CAT_CONFLICT: [
        "계약/규칙/평가가 선택을 강제",
        "소문/평판/공개 사건이 관계를 흔듦",
        "자원(돈/권한/시간)이 부족해 갈등이 커짐",
        "데드라인(마감/시험/발표)이 사건을 가속",
      ],
      CAT_TWIST: [
        "계약의 진짜 목적이 따로 있음",
        "상대의 신분/역할이 드러나 판이 바뀜",
        "과거/비밀이 현재 사건과 연결",
      ],
      CAT_SETPIECE: [
        "공개 이벤트 직전 사고(발표/시험/경쟁)",
        "오해/폭로가 퍼져 수습해야 하는 날",
        "마감 직전 팀 붕괴 위기",
      ],
    },
    "high": {
      CAT_TROPE: [
        "룰/대가가 즉시 현실을 찢는 구조(계약/서약/금기)",
        "세력전에서 한 선택이 전쟁의 불씨가 됨",
        "능력/각성의 조건이 인물을 벼랑 끝으로",
      ],
      CAT_REL: [
        "동맹(상호 담보)→신뢰→배신의 가능성",
        "구원과 통제의 경계가 무너지는 관계",
      ],
      CAT_SYSTEM: [
        "길드/문파/제국/의회/교단 같은 조직 룰",
        "헌터 등급/랭킹/세금/정산 같은 전장 규칙",
        "마법/주술/기술의 대가(부작용/시간/정신)",
      ],
      CAT_CONFLICT: [
        "권력/세력 다툼이 사건을 조종",
        "계약/서약/금기가 함정이 되어 대가 발생",
        "시한 제한(붕괴/봉쇄/폭주)이 가속",
        "인질/담보/약점 노출로 선택 강요",
      ],
      CAT_TWIST: [
        "배후 세력이 뒤집히며 적/아군이 바뀜",
        "누명/증거조작으로 궁지",
        "정체/혈통/각성 조건 반전",
      ],
      CAT_SETPIECE: [
        "습격/암살/급습 시도",
        "징계/추방/재판 통보로 벼랑 끝",
        "미확인 재난(게이트/괴이/역병) 발생",
        "결전 전야의 선택",
      ],
    },
  };

  // =========================================================
  // 3) 장르별 모듈 뱅크 (전 장르 추가/강화)
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
        "비밀연애(평판 리스크)",
        "질투/오해(증거는 애매, 감정은 확실)",
        "구원/보호(위기에서 손 내밀기)",
      ],
      CAT_SYSTEM: [
        "평가/인사/승진/성과/장학 시스템",
        "사내정치/소문망/커뮤니티 여론",
        "주거·돈 압박(대출/보증/위약금)",
        "가족/친척 간섭(체면/결혼/상속)",
      ],
      CAT_CONFLICT: [
        "성과/책임 공방으로 팀이 갈라짐",
        "스캔들/폭로로 관계가 공개 위기",
        "계약 조항이 발동되어 선택이 강제됨",
      ],
      CAT_TWIST: [
        "과거 사건의 가해/피해 역할이 뒤바뀜",
        "상대가 숨긴 진짜 목표(승진/복수/보호)",
      ],
      CAT_SETPIECE: [
        "공개 발표/피치/경쟁 PT 직전 사고",
        "회식/행사에서의 실수와 오해 확산",
      ],
    },
    "로맨스판타지": {
      CAT_TROPE: [
        "정략결혼/약혼 파기/황실 스캔들이 사랑으로 번짐",
        "빙의/회귀로 ‘살기 위한’ 선택이 로맨스를 만든다",
        "저주/계약/마도구로 운명이 묶인 관계",
        "귀족 사회의 평판전/후계 구도로 감정이 압박받음",
      ],
      CAT_REL: [
        "냉혈 공작/황태자 ↔ 생존형 주인공(거래에서 진심으로)",
        "후원자-피후원자(보호와 통제의 줄다리기)",
        "라이벌 귀족과 ‘공적 동맹’에서 감정 폭발",
      ],
      CAT_SYSTEM: [
        "귀족 작위/상속/후계 법",
        "마력/계약/저주의 대가",
        "사교계(파티/소문/후원) 룰",
      ],
      CAT_CONFLICT: [
        "암살/음모로 ‘결혼/약속’이 생존 장치가 됨",
        "후계 경쟁에서 선택이 전쟁이 됨",
      ],
      CAT_TWIST: [
        "저주 해제 조건이 ‘사랑/희생’이 아닌 반전 조건",
        "진짜 흑막이 보호자/가문 내부",
      ],
      CAT_SETPIECE: [
        "무도회/연회에서 공개 망신 또는 역전 선언",
        "황실 재판/공개 심문으로 명예가 걸림",
      ],
    },
    "현대판타지": {
      CAT_TROPE: [
        "일상 속 비밀 능력 각성으로 ‘현실 규칙’이 깨짐",
        "기업/국가기관이 능력을 관리·통제",
        "도시 괴이/도시전설이 실체화",
      ],
      CAT_REL: [
        "감시자-피감시자(협력/의심)",
        "동료이자 경쟁자(능력 성장 레이스)",
      ],
      CAT_SYSTEM: [
        "능력 등급/등록/면허/위반 처벌",
        "특수부대/기관의 프로토콜",
        "도시 괴이 발생 규칙",
      ],
      CAT_CONFLICT: [
        "능력 노출로 사회적 매장/격리 위기",
        "기관과 범죄조직 사이에서 선택 강요",
      ],
      CAT_TWIST: [
        "능력의 기원이 ‘실험/조작’이었다",
        "주인공이 사건의 트리거였음",
      ],
      CAT_SETPIECE: [
        "도심 한복판 괴이 발생 → 은폐/구출",
        "기관 브리핑 중 기습/배신",
      ],
    },
    "헌터/던전/게이트": {
      CAT_TROPE: [
        "약자/무명 헌터가 ‘특이 능력’으로 급성장",
        "레이드 정산/독점/세금이 전쟁을 부른다",
        "게이트 붕괴/대재난을 막는 선택",
      ],
      CAT_REL: [
        "길드 스카우트(영입전)로 관계가 얽힘",
        "파트너 레이드에서 신뢰가 생존",
      ],
      CAT_SYSTEM: [
        "등급/랭킹/정산/세금/독점권 룰",
        "던전 공략 조건/페널티/타임리밋",
      ],
      CAT_CONFLICT: [
        "정산 조작/배신으로 파티 붕괴",
        "게이트 이상징후로 도시 봉쇄",
      ],
      CAT_TWIST: [
        "주인공 능력이 ‘대가/부작용’을 숨김",
        "흑막 길드가 재난을 유도",
      ],
      CAT_SETPIECE: [
        "첫 레이드에서 예상 밖 보스/변칙 룰",
        "정산장/길드 본부에서 공개 충돌",
      ],
    },
    "무협": {
      CAT_TROPE: [
        "사사(師事)·파문·복수로 시작하는 강호 입문",
        "절학/비전/내공을 둘러싼 쟁탈전",
        "문파 전쟁 속 의리와 배신",
      ],
      CAT_REL: [
        "사제/동문 관계의 균열",
        "원수의 제자와 동행(불신→공존)",
      ],
      CAT_SYSTEM: [
        "문파 규율/파문/비무대회 룰",
        "내공/심법/주화입마의 대가",
      ],
      CAT_CONFLICT: [
        "비무/암투로 명분이 피로 바뀜",
        "문파 내부 권력 다툼",
      ],
      CAT_TWIST: [
        "사부의 죄/숨겨진 혈통",
        "비전의 진짜 조건(희생/봉인)",
      ],
      CAT_SETPIECE: [
        "비무대회에서의 공개 역전/파문",
        "암살 습격으로 도망/추격전",
      ],
    },
    "회귀/빙의/환생": {
      CAT_TROPE: [
        "미래 지식으로 ‘파멸 루트’를 갈아엎기",
        "전생의 죄/상처를 이번 생에서 청산",
        "빙의한 몸의 원주인 비밀이 사건을 부름",
      ],
      CAT_REL: [
        "과거엔 적, 지금은 동맹(서로의 약점 공유)",
        "구원하려다 집착을 부르는 관계",
      ],
      CAT_SYSTEM: [
        "회귀 조건/횟수 제한/기억의 대가",
        "빙의 세계의 규칙(신분/가문/계약)",
      ],
      CAT_CONFLICT: [
        "미래를 바꾸면 더 큰 재앙이 이동",
        "살기 위해 누군가를 ‘버려야’ 하는 선택",
      ],
      CAT_TWIST: [
        "회귀의 원인이 주인공 본인",
        "전생 기억이 조작/가짜였다",
      ],
      CAT_SETPIECE: [
        "첫날부터 파멸 이벤트 재현 → 강제 개입",
        "원래 죽어야 할 인물이 살아남음",
      ],
    },
    "아카데미/학원": {
      CAT_TROPE: [
        "성적/랭킹/기숙 규칙이 사건을 만든다",
        "교수/조교/선배 라인의 권력전",
        "대회/실습/팀플에서 재능이 폭발",
      ],
      CAT_REL: [
        "라이벌과 공동 과제(경쟁→협력)",
        "선배/멘토와 성장, 그러나 숨은 의도",
      ],
      CAT_SYSTEM: [
        "랭킹/장학/징계/규율 시스템",
        "기숙사/동아리/학년별 권력",
      ],
      CAT_CONFLICT: [
        "부정행위 누명/조작으로 퇴학 위기",
        "팀플 붕괴로 공개 망신",
      ],
      CAT_TWIST: [
        "학교가 실험/선발 시스템이었다",
        "최상위가 숨긴 시험의 진짜 목적",
      ],
      CAT_SETPIECE: [
        "실습/시합 중 사고 → 책임 공방",
        "시험지 유출/폭로로 전교 흔들림",
      ],
    },
    "SF": {
      CAT_TROPE: [
        "근미래 도시에서 기술이 윤리를 찢는다",
        "AI/복제/기억 편집이 정체성을 흔든다",
        "기업 국가·감시 사회에서 탈출/반란",
      ],
      CAT_REL: [
        "동료지만 서로 감시(스파이 가능성)",
        "구출자-피구출자(빚과 통제)",
      ],
      CAT_SYSTEM: [
        "크레딧/등급/접속권 같은 사회 룰",
        "감시/검열/드론 치안",
        "사이버네틱 부작용/업그레이드 비용",
      ],
      CAT_CONFLICT: [
        "기술 유출/증거 확보를 둘러싼 추격전",
        "기억 조작으로 진실이 붕괴",
      ],
      CAT_TWIST: [
        "주인공의 기억이 덮어씌워진 것",
        "반란군 내부의 배신/통제",
      ],
      CAT_SETPIECE: [
        "도시 봉쇄/검문 돌파",
        "데이터 센터 침투/탈출",
      ],
    },
    "미스터리/추리": {
      CAT_TROPE: [
        "사건(실종/살인/협박) → 단서 퍼즐 → 반전",
        "닫힌 공간(학교/저택/섬)에서 의심이 증폭",
        "주인공의 전문성(프로파일/법의/기자)으로 추적",
      ],
      CAT_REL: [
        "협력자이자 용의자(불신 동행)",
        "진실을 숨기는 보호자(선의의 거짓말)",
      ],
      CAT_SYSTEM: [
        "수사 절차/증거 능력/언론 플레이",
        "지역 권력/커뮤니티 카르텔",
      ],
      CAT_CONFLICT: [
        "증거 조작/알리바이 붕괴",
        "시간 제한(다음 피해자 예고)",
      ],
      CAT_TWIST: [
        "가장 가까운 사람이 범인/공범",
        "단서의 전제가 뒤집힘(가짜 피해자)",
      ],
      CAT_SETPIECE: [
        "첫 단서 확보 직후 누군가가 죽음",
        "공개 추리/기자회견에서 역전",
      ],
    },
    "스릴러/범죄": {
      CAT_TROPE: [
        "추격전(쫓는 자/쫓기는 자)이 매 장면을 당김",
        "조직/경찰/브로커 사이 거래의 배신",
        "증거를 쥔 채 생존해야 하는 구조",
      ],
      CAT_REL: [
        "파트너십(서로 약점 공유)→배신 가능성",
        "정보원-수사자(거래 관계)",
      ],
      CAT_SYSTEM: [
        "조직 룰/상납/영역",
        "수사망/감청/압수수색",
      ],
      CAT_CONFLICT: [
        "목격자/증거인멸로 살해 위협",
        "내부 첩자/배신으로 함정",
      ],
      CAT_TWIST: [
        "범인이 수사팀 내부",
        "피해자가 먼저 판을 짰다",
      ],
      CAT_SETPIECE: [
        "야간 추격전/거래 현장 급습",
        "증거 전달 직전 납치",
      ],
    },
    "공포/오컬트": {
      CAT_TROPE: [
        "금기/의식/저주로 ‘규칙’을 어기면 바로 대가",
        "장소(학교/병원/저택)가 괴이를 만든다",
        "목격/기록이 감염처럼 퍼진다",
      ],
      CAT_REL: [
        "살기 위해 협력하지만 의심이 해소되지 않음",
        "구원하려다 함께 끌려가는 관계",
      ],
      CAT_SYSTEM: [
        "괴이 규칙(하지 말 것/시간/공간 제약)",
        "의식/부적/계약의 대가",
      ],
      CAT_CONFLICT: [
        "규칙을 모르면 죽고, 알면 더 괴롭다",
        "누군가가 일부러 규칙을 깨뜨림",
      ],
      CAT_TWIST: [
        "괴이는 ‘희생을 요구하는 시스템’이었다",
        "주인공이 원인/매개체",
      ],
      CAT_SETPIECE: [
        "첫 규칙 위반으로 즉시 처벌",
        "의식 중 배신/실패로 봉인 해제",
      ],
    },
    "힐링/일상": {
      CAT_TROPE: [
        "작은 목표(가게/공방/공부)가 사람을 모은다",
        "회복(번아웃/이별/상실)에서 다시 일어선다",
        "공간(동네/집/작업실)이 주인공",
      ],
      CAT_REL: [
        "조용히 곁을 지키는 관계",
        "서로의 결핍을 채우는 동행",
      ],
      CAT_SYSTEM: [
        "생활비/임대료/가족 문제",
        "동네 커뮤니티의 소문/관계망",
      ],
      CAT_CONFLICT: [
        "일상 압박이 마음을 갉아먹음",
        "관계 오해가 작은 위기로 확장",
      ],
      CAT_TWIST: [
        "따뜻한 비밀(숨겨온 사정)이 관계를 바꿈",
      ],
      CAT_SETPIECE: [
        "가게/공방/집에서 문제가 터지는 날",
        "계절 행사 준비 중 충돌과 화해",
      ],
      CAT_TONE: [
        "따뜻하고 담백, 작은 사건으로 큰 감정",
        "느린 전개지만 인과는 선명",
      ],
    },
    "판타지": {
      CAT_TROPE: [
        "왕국/제국의 균열 속에서 영웅이 만들어짐",
        "고대 유물/봉인/예언이 전쟁을 부른다",
        "파티 결성 → 여정 → 배신/각성",
      ],
      CAT_REL: [
        "동료 파티의 신뢰(생존 계약)",
        "적과의 동맹(더 큰 적을 위해)",
      ],
      CAT_SYSTEM: [
        "마법/성물/룬의 규칙과 대가",
        "길드/기사단/교단의 권력 구조",
      ],
      CAT_CONFLICT: [
        "세력전/전쟁으로 선택이 피를 부름",
        "봉인 붕괴/재난 확산",
      ],
      CAT_TWIST: [
        "예언이 거짓/조작이었다",
        "주인공이 봉인의 열쇠",
      ],
      CAT_SETPIECE: [
        "첫 던전/유적에서 변칙 룰",
        "성벽 붕괴/침공 전야",
      ],
    },
    "기본": {
      CAT_TROPE: ["핵심 훅 1개 중심", "목표와 갈등 충돌", "룰/대가가 있는 세계"],
      CAT_REL: ["갈등에서 신뢰로", "상호이용에서 감정 변화"],
      CAT_SYSTEM: ["돈/권력/평판/법", "규정/계약/서약"],
      CAT_CONFLICT: ["선택을 강요받는 구조", "비밀이 드러나 관계가 흔들림"],
      CAT_SETPIECE: ["첫 사건이 터지는 날", "폭로/오해/사고"],
      CAT_TWIST: ["배후가 뒤집힘", "과거가 현재를 찌름"],
    }
  };

  // =========================================================
  // 4) 모듈팩 선택
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

  String makeStoryKey() {
    final sid = storyId?.trim() ?? "";
    if (sid.isNotEmpty) {
      return "sid_${stableHash("$safeGenre|$sid")}";
    }
    final normalized = _normWhitespace(ctx);
    if (normalized.isNotEmpty) {
      return "k_${stableHash("$safeGenre|$normalized")}";
    }
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

    // ✅ 풍부하게: 트로프/관계/시스템/갈등을 조금 더 뽑음(복사 금지 규칙은 그대로)
    final pack = <String, List<String>>{};
    pack[CAT_TROPE] = pickN(r, mergedPool(CAT_TROPE), 3);
    pack[CAT_REL] = pickN(r, mergedPool(CAT_REL), 2);
    pack[CAT_SYSTEM] = pickN(r, mergedPool(CAT_SYSTEM), 2);
    pack[CAT_CONFLICT] = pickN(r, mergedPool(CAT_CONFLICT), 2);
    pack[CAT_SETPIECE] = pickN(r, mergedPool(CAT_SETPIECE), 1);

    final twistChance =
        (toneGroup == "low") ? 0.35 : (toneGroup == "mid" ? 0.60 : 0.75);
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
[참고 시드(복사/나열 금지, 치환/변형하여 사용)]
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
(비밀/반전)
${joinBullets(modulePack[CAT_TWIST] ?? [])}
$toneLine
"""
        .trim();
  }

  // =========================================================
  // 5) 필드별 프롬프트 분기 (✅ “1개만 출력” 강제)
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

  // ✅ “후보/옵션/대안” 금지 공통 문구
  const String noAlternatives = """
[절대 금지]
- 후보/옵션/대안/A안/B안/여러 버전 제시
- 번호 매기기, 리스트 나열
- 메타 설명(왜 좋은지/해설)
""";

  if (isTitle) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

$noAlternatives

[요청]
- 제목은 **오직 1개만**.
- 한 줄에 제목만 출력(따옴표/접두어/줄바꿈 금지).
- 훅이 보이게(갈등/목표/리스크 암시).
- 10~18자 권장.
""";
  } else if (isWorld) {
    selectedModel = 'solar-pro';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

$noAlternatives

[출력 형식] (라벨명 변경 금지, **단 1개 세계관**만)
핵심 갈등:
세계 규칙/대가(선택):
압박 축(1~2):
세력 구도(최소 2):
고유명사 묶음(3~7):
1화 점화 사건:
전개 레일(1~3화 필연 충돌 3줄):
씬 패키지(장소 2~5 + 감각 디테일 + 소문/계약/리스크 2개):

[분량] 900~1400자
""";
  } else if (isCharName) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

$noAlternatives

[요청]
- 캐릭터 이름은 **오직 1개만**.
- 한 줄에 이름만(설명/괄호/직함/수식 금지).
- 장르/세계관 톤에 어울리는 이름(현실/판타지 맞춤).
""";
  } else if (isCharSet) {
    // ✅ 단일 캐릭터 + 라벨 엄격 (⚠️ 수정: 이름 라벨 제거)
    selectedModel = 'solar-pro';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

$noAlternatives

[요청]
- **반드시 단 1명의 캐릭터만** 설정하세요. (2명 이상/다른 후보 금지)
- 현재 맥락의 주인공 또는 핵심 인물 1인에 집중.
- 출력은 아래 라벨을 엄격히 준수(라벨명 변경/추가 금지).
- 감정/말투/행동은 ‘사건에서 드러나는 형태’로 구체화.
- ⚠️ 이름은 이미 별도 필드에 있으므로, **이름/이름: 라벨은 절대 출력하지 마세요.**

[출력 형식] (한 줄에 하나)
나이:
성별:
직업/신분:

핵심 욕망(장기목표):
단기 목표(1~3화):
공포/핵심 불안:
문제해결 전략(습관 등):
레버리지(무기/자원/인맥 등):

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

[분량] 650~1000자 (1명 분량)
""";
  } else if (isIntro) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[장르] $safeGenre
[현재 맥락]
${ctx.isEmpty ? "(없음)" : ctx}

${modulesBlock()}

$noAlternatives

[요청]
- 소개는 **단 1개 문단**.
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

$noAlternatives

[요청]
- **단 1개 버전**.
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

$noAlternatives

[요청]
- 프롤로그는 **단 1개 버전**.
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

$noAlternatives

[요청]
- '$targetFieldName'에 들어갈 내용을 설정 문서 톤으로 작성.
- 추상어 대신 고유명사/구체명사 중심.
- 단 1개 버전.
""";
  }

  // =========================================================
  // 6) 시스템 프롬프트
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
- 장르 톤 유지
- 출력은 사용자가 요청한 형식만. 메타설명/해설 금지
- 제공된 ‘참고 시드’ 문장을 출력에 그대로 복사하지 말고 맥락에 맞게 변형
- “후보/옵션/대안/여러 버전” 금지
""";

  // =========================================================
  // 7) 호출 및 결과 반환
  // =========================================================
  String output;
  try {
    output = await callAi(selectedModel, systemPrompt, specificInstruction);
  } catch (e) {
    return "생성 오류: $e";
  }

  output = cleanBasic(output);

  // ✅ (추가) 캐릭터설정란에서는 '이름:' 라인/변형 강제 제거
  if (isCharSet) {
    final lines = output.split('\n');
    final filtered = lines.where((line) {
      final t = line.trim();
      if (t.startsWith("이름:")) return false;
      if (t.startsWith("이름 -")) return false;
      if (t.startsWith("이름-")) return false;
      if (t.startsWith("이름 ")) return false; // "이름 홍길동" 방지
      return true;
    }).toList();
    output = filtered.join('\n').trim();
  }

  // ✅ 제목/이름은 무조건 1줄만 (모델이 리스트로 뱉어도 첫 줄 강제)
  if (isTitle || isCharName) {
    final one = firstNonEmptyLine(output);
    return one.isEmpty ? output.trim() : one.trim();
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
- 후보/옵션/대안/여러 버전 금지.
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
        "세계 규칙/대가",
        "압박 축",
        "세력 구도",
        "고유명사",
        "1화 점화 사건",
        "전개 레일",
        "씬 패키지",
      ],
      minChars: 900,
      maxChars: 1400,
    );
  }

  if (isCharSet) {
    output = await repairOnce(
      original: output,
      mustKeys: [
        // ⚠️ 수정: "이름:" 제거
        "나이:",
        "성별:",
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
      minChars: 650,
      maxChars: 1000,
    );

    // ✅ repair 이후에도 한 번 더 제거(모델이 다시 끼워 넣는 경우 방지)
    final lines = output.split('\n');
    final filtered = lines.where((line) {
      final t = line.trim();
      if (t.startsWith("이름:")) return false;
      if (t.startsWith("이름 -")) return false;
      if (t.startsWith("이름-")) return false;
      if (t.startsWith("이름 ")) return false;
      return true;
    }).toList();
    output = filtered.join('\n').trim();
  }

  return output.trim();
}
