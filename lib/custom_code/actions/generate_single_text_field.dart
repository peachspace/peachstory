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
  // 1. 기본 시스템 프롬프트 (페르소나 설정)
  String systemPrompt = """
당신은 한국 웹소설 전문 AI 어시스턴트입니다.
사용자가 제공하는 스토리 문맥(Context)을 바탕으로 '$targetFieldName' 항목을 작성해야 합니다.
반드시 '한국어(Korean)'로 작성하세요.
""";

  // 2. 타겟 필드에 따라 '지시 사항'을 다르게 설정 (핵심 수정 부분)
  String specificInstruction = "";

  // '이름', '제목', '타이틀' 같은 단어가 포함되면 "단답형"으로 지시
  if (targetFieldName.contains('이름') ||
      targetFieldName.contains('제목') ||
      targetFieldName.contains('타이틀') ||
      targetFieldName.contains('호칭')) {
    specificInstruction = """
위 문맥에 가장 잘 어울리는 '$targetFieldName'을(를) 창작해 주세요.
[절대 규칙]
- 부연 설명, 따옴표, 수식어, 마침표를 절대 붙이지 마세요.
- 오직 생성된 **단어 하나만** 출력하세요.
(예시: "주인공 이름은 강철수입니다" (X) -> "강철수" (O))
""";
  } else {
    // 그 외(세계관, 프롤로그, 소개 등)는 "상세하고 창의적"으로 지시
    specificInstruction = """
위 문맥과 설정을 바탕으로 '$targetFieldName' 부분을 상세하고 창의적으로 작성해 주세요.
문체는 웹소설 독자들이 몰입할 수 있는 매력적인 어조를 사용하세요.
""";
  }

  // 3. 최종 유저 프롬프트 조합
  String userPrompt = """
[현재 스토리 문맥]
$currentStoryContext

[지시 사항]
$specificInstruction
""";

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
    // 혹시라도 공백이나 줄바꿈이 포함될 수 있으니 trim() 처리
    return result.data['fullText']?.toString().trim() ?? '';
  } catch (e) {
    return "Error: $e";
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
