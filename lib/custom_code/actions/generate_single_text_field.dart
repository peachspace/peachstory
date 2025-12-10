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
""";

  // 2. 필드별 최적화된 지시사항 (Prompt Engineering 적용)
  String specificInstruction = "";

  if (targetFieldName.contains('제목') || targetFieldName.contains('타이틀')) {
    // [제목]: 클릭을 유도하는 임팩트
    specificInstruction = """
- 장르의 특성을 살려 독자의 호기심을 강하게 자극하는 임팩트 있는 제목을 지어주세요.
- 너무 길지 않게(20자 이내 권장), 부제(Sub-title)가 있다면 포함해도 좋습니다.
- **[주의]** 부연 설명이나 따옴표("") 없이 오직 '제목 텍스트'만 출력하세요.
""";
  } else if (targetFieldName.contains('세계관')) {
    // [세계관]: 몰입감을 주는 디테일
    specificInstruction = """
- 이 소설의 무대가 되는 세계를 구체적이고 감각적으로 묘사하세요.
- 지리적 특성, 사회 구조, 마법이나 기술 체계, 혹은 이 세계만의 독특한 규칙을 포함하세요.
- 건조한 설명보다는, 그 세계의 '분위기'와 '위험 요소'가 느껴지도록 서술하세요.
""";
  } else if (targetFieldName.contains('프롤로그')) {
    // [프롤로그]: 사건 중심의 훅(Hook)
    specificInstruction = """
- 이야기의 시작을 알리는 강렬한 도입부를 작성하세요.
- 지루한 배경 설명으로 시작하지 말고, **주인공이 겪는 긴박한 사건, 위기, 혹은 미스터리한 상황**을 바로 보여주세요.
- 독자가 "다음 내용이 궁금해서 미치겠는" 상태가 되도록 끝맺으세요.
""";
  } else if (targetFieldName.contains('캐릭터 이름') ||
      targetFieldName.contains('이름')) {
    // [캐릭터 이름]: 장르에 맞는 네이밍
    specificInstruction = """
- 작품의 분위기와 장르에 어울리는 자연스러운 이름을 하나 지어주세요.
- (판타지라면 판타지식, 현대물이라면 한국식 이름 등 문맥에 맞게)
- **[절대 규칙]** 설명이나 수식어, 기호 없이 **오직 이름 단어 하나만** 출력하세요.
""";
  } else if (targetFieldName.contains('캐릭터 설정') ||
      targetFieldName.contains('성격')) {
    // [캐릭터 설정]: 입체적인 캐릭터 빌딩
    specificInstruction = """
- 이 캐릭터의 외모 묘사, 성격(MBTI 등), 특징적인 말투, 독특한 버릇, 숨겨진 과거 등을 상세히 서술하세요.
- 캐릭터의 이름은 서술하지 마세요.
- 단순한 정보 나열이 아니라, 이 캐릭터가 살아서 움직이는 듯한 '입체감'과 '매력 포인트'를 강조하세요.
""";
  } else if (targetFieldName.contains('캐릭터 소개') ||
      targetFieldName.contains('소개')) {
    // [캐릭터 소개]: 요약된 정보
    specificInstruction = """
- 독자들이 캐릭터 창에서 한눈에 파악할 수 있도록, 위 설정을 바탕으로 3~4줄 내외로 요약하여 소개하세요.
- 캐릭터의 핵심 정체성과 역할을 명확하게 드러내세요.
""";
  } else if (targetFieldName.contains('유저역할') ||
      targetFieldName.contains('유저 역할')) {
    // [유저 역할]: 사용자의 개입 동기 부여
    specificInstruction = """
- 이 인터랙티브 스토리에서 '사용자(플레이어)'가 맡게 될 역할과 위치를 정의하세요.
- 주인공의 조력자인지, 전지적 관찰자인지, 혹은 또 다른 주인공인지 명확히 설정하세요.
- 사용자가 이야기에 개입해야 할 '동기'와 '목표'를 부여하세요.
""";
  } else if (targetFieldName.contains('상황') || targetFieldName.contains('조건')) {
    // [상황]: 이미지 생성 및 전개 조건
    specificInstruction = """
- 특정 사건이 벌어지는 구체적인 '장면(Scene)'이나 '상황'을 묘사하세요.
- 누가, 어디서, 무엇을 하고 있는지, 시간대와 날씨는 어떠한지 시각적으로 그려지듯 서술하세요.
- 이 내용은 주로 삽화(이미지) 생성의 프롬프트로 활용될 수 있음을 고려하세요.
""";
  } else if (targetFieldName.contains('이야기 소개') ||
      targetFieldName.contains('스토리 소개') ||
      targetFieldName.contains('인트로')) {
    // [이야기 소개]: 뒷면 줄거리(Blurb) 스타일
    specificInstruction = """
- 작품 전체를 관통하는 로그라인(Logline)이나 흥미로운 줄거리를 작성하세요.
- 독자를 유혹하는 마케팅 문구처럼 매력적으로 작성하세요.
- 주인공에게 닥친 시련과 그것을 극복해야 하는 이유를 포함하여 기대감을 높이세요.
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

    // 결과값의 앞뒤 공백 제거 후 반환
    return result.data['fullText']?.toString().trim() ?? '';
  } catch (e) {
    return "생성 중 오류 발생: $e";
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
