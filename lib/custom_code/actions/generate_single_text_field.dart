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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:cloud_functions/cloud_functions.dart';

Future<String> generateSingleTextField(
  String targetFieldName,
  String currentStoryContext,
  String genre,
) async {
  // -----------------------------
  // 0) 유틸 & 장르 정규화
  // -----------------------------
  String rawGenre = genre.trim().isEmpty ? "기본" : genre.trim();

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

  String safeGenre = normalizeGenre(rawGenre);

  // -----------------------------
  // 1) System Prompt (공통)
  // -----------------------------
  String systemPrompt = """
당신은 베스트셀러 웹소설 작가이자 전문 기획자입니다.
목표: 독자가 몰입할 수 있는 구체적이고 풍부한 설정 데이터를 작성합니다.

[원칙]
1. 추상적인 설명보다 구체적인 명사(제도, 지명, 물건)를 사용하세요.
2. 문체는 설정집의 서술형 문체를 사용하세요.
""";

  // -----------------------------
  // 2) 세계관 라벨형 프롬프트 (번호 X, 라벨 O)
  // -----------------------------
  final Map<String, String> worldPromptByGenre = {
    "현대로맨스": """
[세계관 생성 - 현대로맨스]
[금지] 비현실 요소

출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 설렘+갈등 한 줄.
시간/장소: 도시/동네/주요 공간 4곳 + 감각 디테일.
사회의 룰: 직장/학교/가족/친구/커뮤니티 중 3개.
돈과 현실 압박: 월급/집/빚/평가/계약 등 3개.
관계의 룰: 소문/평판/비밀연애 리스크 3개.
주요 집단: 팀/가문/친구무리/동아리 3개 + 목표.
관습/제도: 독창적인 문화 2개.
금기와 결과: 금기 2개 + 현실적 결과.
1화 사건: 설렘/갈등/위기 톤 사건 3개.
""",
    "로맨스판타지": """
[세계관 생성 - 로맨스판타지]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 정치/소문/감정선 훅.
시대/영지/궁정: 분위기 및 감각 디테일.
사회의 룰: 계급/예법/교단 중 3개.
돈과 권력: 작위/영지 수입/후원 구조.
마법 규칙: 유무 및 대가 (없으면 정치 강화).
세력: 황실/교단/귀족파벌 3개 + 목표.
관습: 연회/혼약 등 독창적 2개.
금기와 결과: 파문/추방 등 결과 2개.
1화 사건: 위기/로맨틱/폭로 사건 3개.
""",
    "현대판타지": """
[세계관 생성 - 현대판타지]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 현실이 깨지는 한 방.
시간/장소: 현대 도시 + 이질적 분위기.
사회 시스템: 정부/기업이 초자연을 다루는 방식.
돈과 생계: 각성자/비각성자 수입 구조.
능력 규칙: 사용 가능/불가/대가.
조직/세력: 협회/길드/기업 3개 + 목표.
고유 제도: 면허/보험 등 현실 결합 2개.
금기와 결과: 법적/사회적 결과 2개.
1화 사건: 각성/침입/거래 사건 3개.
""",
    "헌터/던전/게이트": """
[세계관 생성 - 헌터/던전/게이트]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 던전+성장+위험.
게이트 규칙: 발생 주기/등급/특성.
사회 시스템: 정부/길드/민간사업 구조.
보상 구조: 분배/계약/정산 방식.
스킬/아이템: 사용 규칙 및 대가.
길드/세력: 주요 3개 세력의 목표.
관습: 헌터 문화 등 독창적 2개.
금기와 결과: 계약 파기/블랙리스트 등 결과 2개.
1화 사건: 사고/배신/신규 게이트 사건 3개.
""",
    "무협": """
[세계관 생성 - 무협]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 은원/명분/성장.
강호 분위기: 시대상 및 감각 디테일.
강호의 룰: 서열/명분/관아 관계 3개.
돈과 생계: 표국/객잔/암시장 구조.
무공 규칙: 내공/무공의 수련 및 대가.
세력: 정파/사파/관 3개 + 목표.
관습: 비무/서약 등 독창적 2개.
금기와 결과: 파문/추살 등 결과 2개.
1화 사건: 비무/호송/원한 사건 3개.
""",
    "회귀/빙의/환생": """
[세계관 생성 - 회귀/빙의/환생]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 두 번째 기회 훅.
시작 상황: 돌아온 시점 및 이유.
사회/권력 룰: 현실적 제도 3개.
돈과 생계: 주인공의 현실적 수단.
회귀/빙의 규칙: 기억 범위/제약/대가 (필수).
세력: 방해/이용할 3개 세력.
관습/제도: 인과/운명 관련 규칙 2개.
금기와 결과: 현실적/초자연적 결과 2개.
1화 사건: 계획 실행/위기 사건 3개.
""",
    "아카데미/학원": """
[세계관 생성 - 아카데미/학원]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 입학/시험/비밀.
학교 분위기: 주요 공간 4곳 + 디테일.
교칙/평가: 성적/징계/특권 규칙 3개.
생계: 장학금/생활비 현실 요소.
능력/마법: 대가 또는 평판/성적 룰.
파벌/세력: 학생회/동아리 3개 + 목표.
관습: 축제/대련 등 독창적 2개.
금기와 결과: 정학/퇴학 등 결과 2개.
1화 사건: 시험/사건/소문 관련 3개.
""",
    "SF": """
[세계관 생성 - SF]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 기술+갈등.
시간/장소: 도시/시설 4곳 + 디테일.
사회 시스템: 감시/규정/계급 3개.
경제/생계: 크레딧/배급/직업.
기술 규칙: 효과/제약/부작용 (필수).
세력: 정부/기업/저항군 3개 + 목표.
고유 제도: 등급제/인증 등 2개.
금기와 결과: 처벌/삭제 등 결과 2개.
1화 사건: 사고/폭로/추적 사건 3개.
""",
    "미스터리/추리": """
[세계관 생성 - 미스터리/추리]
[금지] 초능력, 우연

출력: 900~1300자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 사건+주인공 역할.
배경: 사건 현장/주요 장소 4곳.
사회 룰: 치안/언론/소문망 2개.
생계/직업: 수사비용/돈의 흐름.
사건 규칙: 증거/알리바이 현실적 제약.
관련 집단: 경찰/기자/용의자 3개.
관습: 지역적 특색 2개.
금기와 결과: 증거 조작 등 결과 2개.
1화 사건: 발견/의뢰/위협 사건 3개.
""",
    "스릴러/범죄": """
[세계관 생성 - 스릴러/범죄]
[금지] 범죄 미화

출력: 900~1300자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 위협+시한.
배경: 위험 공간 4곳 + 디테일.
사회 룰: 수사/조직범죄 규칙 3개.
돈의 흐름: 수익/세탁/빚 구조.
위협 규칙: 추적/인질 등 실패 시 결과.
세력: 경찰/범죄조직/제3자 3개.
관습/제도: 암시장/로컬 권력 2개.
금기와 결과: 생명 위협 선 2개.
1화 사건: 추적/함정/배신 사건 3개.
""",
    "공포/오컬트": """
[세계관 생성 - 공포/오컬트]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 금기+대가.
장소/분위기: 소리/냄새/온도 + 공간 4곳.
사회 룰: 소문/지역 반응 2개.
생계/일상: 장소 이용의 현실 이유.
저주/괴이 규칙: 발동 조건/대가 (필수).
관련 집단: 무당/병원 등 3개.
의식/관습: 독창적 의식 2개.
금기와 결과: 금기 2개 + 결과.
1화 사건: 목격/실종/의뢰 사건 3개.
""",
    "힐링/일상": """
[세계관 생성 - 힐링/일상]
[금지] 억지 대사건

출력: 900~1300자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 따뜻한 변화.
배경: 동네/가게/집 + 디테일.
일상 룰: 단골/이웃 규칙 3개.
생계: 가게/알바 등 현실 요소.
관계의 룰: 친밀해지는 규칙 3개.
인물/집단: 단골/가족 3개 + 목표.
관습: 작은 행사/루틴 2개.
금기와 결과: 관계 깨지는 선 2개.
1화 사건: 소소한 사건 3개.
""",
    "판타지": """
[세계관 생성 - 판타지]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 위기/전쟁/예언.
대륙/왕국/도시: 지명 4개 + 분위기.
사회 룰: 왕권/기사단/길드 3개.
돈과 생계: 화폐/무역 + 직업 3개.
마법/종족 규칙: 가능/불가/대가.
세력: 왕국/교단 등 3개 + 목표.
관습/제도: 서약/계약 등 2개.
금기와 결과: 현실적/초자연적 결과 2개.
1화 사건: 조짐/침공/발견 사건 3개.
""",
    "기본": """
[세계관 생성 - 기본]
출력: 900~1400자. 아래 항목을 포함하여 설정집 형태로 서술.
로그라인: 핵심 훅.
시간/장소: 주요 공간 4곳 + 분위기.
사회 룰: 권력/계층 2개.
돈과 생계: 화폐/직업 3개.
초자연/기술 규칙: 대가 명시.
세력: 3개 + 목표.
관습: 독창적 2개.
금기와 결과: 금기 2개 + 결과.
1화 사건: 사건 3개.
""",
  };

  // -----------------------------
  // 3) 필드별 프롬프트 선택
  // -----------------------------
  String specificInstruction = "";
  String selectedModel = 'solar-mini';

  // [1] 제목: 깔끔한 후보 나열
  if (targetFieldName.contains('제목') || targetFieldName.contains('타이틀')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[제목 생성]
- 번호(1., 2.)나 접두어(후보:) 없이 제목만 적어.
- 예시:
나 혼자만 레벨업
전지적 독자 시점
재벌집 막내아들
""";
  }

  // [2] 세계관: 라벨형 포맷 적용
  else if (targetFieldName.contains('세계관')) {
    selectedModel = 'solar-mini';
    specificInstruction =
        worldPromptByGenre[safeGenre] ?? worldPromptByGenre["기본"]!;
  }

  // [3] 캐릭터 이름: 깔끔한 후보 나열
  else if (targetFieldName.contains('캐릭터 이름')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[캐릭터 이름 생성]
- 번호나 설명 없이 이름만 적어.
""";
  }

  // [4] 캐릭터 설정 (대폭 수정): 항목별 강제
  else if (targetFieldName.contains('캐릭터 설정') ||
      targetFieldName.contains('성격')) {
    selectedModel = 'solar-mini'; // 캐릭터 설정은 중요하므로 pro 사용 권장
    specificInstruction = """
[캐릭터 설정 생성]
- 반드시 아래 '라벨: 내용' 형식으로만 출력하세요. (라벨명 변경/추가 금지)
- 각 라벨은 한 줄에 하나씩 작성하고, 내용은 구체적으로 채우세요.
- 말투와 예시 대사는 규칙적으로 작성하여 바로 사용할 수 있게 하세요.
- 전체 분량 900~1400자.

[출력 형식]
이름: 
나이: 
성별: 
직업/신분: 

외형1(머리): 
외형2(눈): 
외형3(피부/인상): 
외형4(특징/흉터/소품): 
의상(대표 1벌): 

성격-장점: 
성격-단점: 
성격-트리거(버튼): 

말투-규칙1: 
말투-규칙2: 
말투-규칙3: 
자주쓰는표현1: 
자주쓰는표현2: 
예시대사1(15~28자): 
예시대사2(15~28자): 
예시대사3(15~28자): 

가치관: 
비밀: 
트라우마: 
능력/기술(규칙/대가 포함): 
약점1: 
약점2: 
관계/갈등포인트: 
첫등장장면(3문장): 
""";
  }

  // [5] 캐릭터 소개
  else if (targetFieldName.contains('캐릭터 소개') ||
      targetFieldName.contains('소개')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[캐릭터 소개 생성]
- 2~3문장. 평가 대신 사건/결핍/위험으로 매력 보여주기.
""";
  } else if (targetFieldName.contains('프로필') &&
      targetFieldName.contains('이미지')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[프로필 이미지 프롬프트]
- 머리/눈/표정/의상/특징 포함.
- 조명/분위기 + 카메라 구도. 2~4문장.
""";
  } else if (targetFieldName.contains('감정') &&
      targetFieldName.contains('이미지')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[감정 이미지 프롬프트]
- 감정을 행동+표정으로. 신체 디테일 2개 이상. 2~4문장.
""";
  } else if (targetFieldName.contains('상황') &&
      targetFieldName.contains('이미지')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[상황 이미지 프롬프트]
- Action+대상+결과가 보이게. 구도/배경/감각 디테일. 2~4문장.
""";
  } else if (targetFieldName.contains('유저역할') ||
      targetFieldName.contains('유저 역할')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[유저 역할 생성]
- '당신은'으로 시작. 5~7문장.
- 신분, 목표, 금기, 자원, 즉시 사건 포함.
""";
  } else if (targetFieldName.contains('프롤로그')) {
    selectedModel = 'solar-pro';
    specificInstruction = """
[프롤로그 생성]
- 900~1500자. 3단 구성 지켜줘.
[Image: 태그명]
[Dialogue] (이름|대사)
[Narration] (지문)
- 마지막은 다음 턴을 부르는 한 줄.
""";
  } else if (targetFieldName.contains('메인') &&
      targetFieldName.contains('이미지')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[표지/메인 이미지 프롬프트]
- 주인공 + 핵심 배경 + 상징 오브젝트.
- 분위기(조명/톤) + 구도. 2~5문장.
""";
  } else if (targetFieldName.contains('이야기 소개') ||
      targetFieldName.contains('스토리 소개')) {
    selectedModel = 'solar-mini';
    specificInstruction = """
[스토리 소개 생성]
- 3~5문장. 사건 폭발 + 성장/보상 훅.
""";
  } else {
    selectedModel = 'solar-mini';
    specificInstruction = """
[설정 데이터 생성]
- '$targetFieldName' 내용을 설정 문서 형태로 작성.
- 장르: $safeGenre
""";
  }

  // -----------------------------
  // 4) 최종 호출
  // -----------------------------
  String userPrompt = """
[장르] $safeGenre
[현재 맥락]
$currentStoryContext

[요청]
$specificInstruction
""";

  try {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('callAiProxy');
    final result = await callable.call(<String, dynamic>{
      'modelName': selectedModel,
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    });

    String output = (result.data['fullText'] ?? '').toString().trim();

    // [후처리] 불필요한 기호 제거
    if (targetFieldName.contains('제목') || targetFieldName.contains('이름')) {
      output = output
          .replaceAll('"', '')
          .replaceAll("'", "")
          .replaceAll("후보", "")
          .replaceAll(":", "")
          .replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '');
    }

    // 마크다운 헤더(#) 제거
    output = output.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');

    return output.trim();
  } catch (e) {
    return "생성 오류: $e";
  }
}
