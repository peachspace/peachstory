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

import 'package:cloud_functions/cloud_functions.dart';

Future<String> generateSingleTextField(
  String targetFieldName,
  String currentStoryContext,
) async {
  // 1. 기본 시스템 페르소나 (전체 공통 설정)
  String systemPrompt = """
당신은 베스트셀러 웹소설 작가이자 전문 에디터입니다.
주어진 설정과 문맥을 완벽히 파악하여, 독자가 즉시 몰입할 수 있는 텍스트를 창작해야 합니다.
모든 결과물은 자연스럽고 매끄러운 '한국어(Korean)'로 작성되어야 합니다.
사용자의 요청에 따라 특정 설정 부분만 작성해야 합니다.
**절대 소설의 본문이나, 제목, 프롤로그 형식을 갖추지 마세요.**
오직 요청받은 '설정 데이터'만 텍스트로 출력하세요.
""";

  // 2. 필드별 최적화된 지시사항 (Prompt Engineering 적용)
  String specificInstruction = "";

  if (targetFieldName.contains('이야기 소개') ||
      targetFieldName.contains('스토리 소개') ||
      targetFieldName.contains('인트로')) {
    specificInstruction = """
- 작품 전체를 관통하는 로그라인(Logline)이나 흥미로운 줄거리를 작성하세요.
- 독자를 유혹하는 마케팅 문구처럼 매력적으로 작성하세요.
- 캐릭터 이름이나 설정을 나열하지 말고, 주인공에게 닥친 시련과 사건 위주로 서술하세요.
""";
  } else if (targetFieldName.contains('제목') ||
      targetFieldName.contains('타이틀')) {
    // [제목]: 클릭을 유도하는 임팩트
    specificInstruction = """
- 장르의 특성을 살려 독자의 호기심을 강하게 자극하는 임팩트 있는 제목을 지어주세요.
- 너무 길지 않게(20자 이내 권장), 부제(Sub-title)가 있다면 포함해도 좋습니다.
- **[주의]** 부연 설명이나 따옴표("") 없이 오직 '제목 텍스트'만 출력하세요.
- **[절대 금지]** 결과물 앞에 '제목:', 'Title:' 같은 접두사를 절대 붙이지 마세요. 그냥 제목만 출력하세요.
""";
  } else if (targetFieldName.contains('세계관')) {
    // [세계관]: 몰입감을 주는 디테일
    specificInstruction = """
- 이 소설의 무대가 되는 세계를 구체적이고 감각적으로 묘사하세요.
- 지리적 특성, 사회 구조, 마법이나 기술 체계, 혹은 이 세계만의 독특한 규칙을 포함하세요.
- 해당 설정을 구체적으로 묘사하되, 소설 본문 형식이 아닌 '설정집' 느낌의 서술형으로 작성하세요.
- **[금지]** '제목:', '프롤로그:', '제 1장' 같은 헤더나 소설 도입부를 절대 쓰지 마세요.
- **[금지]** 등장인물의 대화나 구체적인 사건 진행을 쓰지 마세요.
""";
  } else if (targetFieldName.contains('프롤로그')) {
    // [프롤로그]: 사건 중심의 훅(Hook)
    specificInstruction = """
- 사건이 시작되는 이야기 형식(Narrative style)으로 서술하시오. 배경 묘사와 인물의 행동 위주로 작성하시오.
- 독자가 "다음 내용이 궁금해서 미치겠는" 상태가 되도록 끝맺으세요.
- **[절대 금지]** 캐릭터의 이름과 설정을 리스트 형태로 나열하지 마시오. 

""";
  } else if (targetFieldName.contains('캐릭터 이름') ||
      targetFieldName.contains('이름')) {
    // [캐릭터 이름]: 장르에 맞는 네이밍
    specificInstruction = """
- 작품의 분위기와 장르에 어울리는 자연스러운 이름을 하나 지어주세요.
- 창의적이고 장르에 어울리는 **이름 단어 하나만** 출력하세요.
- **[절대 금지]** 설명, 묘사, 수식어, 마침표, 괄호, '이름:' 같은 라벨을 절대 붙이지 마세요
""";
  } else if (targetFieldName.contains('캐릭터 설정') ||
      targetFieldName.contains('성격')) {
    // [캐릭터 설정]: 입체적인 캐릭터 빌딩
    specificInstruction = """

- 다음 형식에 맞춰 캐릭터 설정을 생성하세요. 

1. 아래 항목들은 반드시 포함하세요.
외모: 얼굴, 체형 등에 관하여 상세하게 묘사
성격: 성격 키워드 및 행동 양식 등 상세하게 묘사
말투: 말투 설명, 반드시 대화 예시 3개 포함
 # 대화 예시 1: "캐릭터 성격에 맞는 대사"
 # 대화 예시 2: "캐릭터 성격에 맞는 대사"
 # 대화 예시 3: "캐릭터 성격에 맞는 대사"

2. 아래 항목 중 필요한 항목이 있다면 포함하세요.
가치관:
비밀:
트라우마:
좋아하는 것:
싫어하는 것:
결핍:
습관:
능력:

- 캐릭터의 이름은 서술하지 마세요.
- 단순한 정보 나열이 아니라, 이 캐릭터가 살아서 움직이는 듯한 '입체감'과 '매력 포인트'를 강조하세요.
""";
  } else if (targetFieldName.contains('캐릭터 소개') ||
      targetFieldName.contains('소개')) {
    // [캐릭터 소개]: 요약된 정보
    specificInstruction = """
- 이 캐릭터를 유저에게 소개하는 **3문장 이내의 짧고 매력적인 요약글**을 작성하세요.
- 외모나 설정의 단순 나열을 금지합니다. (이미 다른 항목에 있습니다)
- 캐릭터의 가장 큰 매력 포인트나, 현재 처한 상황, 또는 유저와의 관계성을 중심으로 '훅(Hook)'이 되는 문장만 남기세요.
- 예시: "냉철한 이성의 소유자지만, 당신에게만은 곁을 내어주는 제국의 황태자. 과거의 상처로 인해 타인을 불신하지만, 당신의 능력만은 믿고 있다."
""";
  } else if (targetFieldName.contains('유저역할') ||
      targetFieldName.contains('유저 역할')) {
    // [유저 역할]: 사용자의 개입 동기 부여
    specificInstruction = """
- 이 인터랙티브 스토리에서 '사용자(플레이어)'가 맡게 될 역할과 위치를 정의하세요.
- 주인공의 조력자인지, 전지적 관찰자인지, 혹은 또 다른 주인공인지 명확히 설정하세요.
- 사용자가 이야기에 개입해야 할 '동기'와 '목표'를 부여하세요.
- 유저의 이름을 짓지 마세요. 문장은 '당신은...'으로 시작하세요.
""";
  } else if (targetFieldName.contains('상황') || targetFieldName.contains('조건')) {
    // [상황]: 이미지 생성 및 전개 조건
    specificInstruction = """
- 이 이미지가 화면에 출력되어야 할 **'특정한 시점'이나 '조건'을 한 문장으로 요약**하세요.
- 소설 본문을 절대 쓰지 마세요. 대화문도 쓰지 마세요.
- **예시:** "주인공이 처음으로 전설의 검을 뽑았을 때", "비 오는 날 밤, 골목길에서 적과 마주친 상황"
""";
  } else {
    // [그 외]: 기본 문맥 생성
    specificInstruction = """
- 위 문맥을 바탕으로 '$targetFieldName' 항목에 들어갈 적절한 내용을 창작해 주세요.
- 웹소설의 재미와 몰입도를 높이는 방향으로 작성하세요.
""";
  }

  // 3. 최종 유저 프롬프트 조합
  String userPrompt = """
[현재 스토리 데이터]
$currentStoryContext

[당신의 임무]
$specificInstruction
""";

  // 4. API 호출
  try {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('callAiProxy');
    final result = await callable.call(<String, dynamic>{
      'modelName': 'gpt-4o-mini',
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    });

    String output = result.data['fullText']?.toString().trim() ?? '';
    // 불필요한 기호 제거
    output = output.replaceAll(RegExp(r'^#+\s+.*$', multiLine: true), '');
    output = output.replaceAll('**', '');
    output = output.replaceAll('---', '');
    return output.trim();
  } catch (e) {
    return "생성 오류: $e";
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
