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
  String systemPrompt = """
당신은 한국 웹소설 전문 AI 어시스턴트입니다.
사용자가 제공하는 스토리 문맥(Context)을 바탕으로 '$targetFieldName' 항목에 들어갈 텍스트를 작성해야 합니다.

[필수 규칙]
1. 반드시 '한국어(Korean)'로 작성하세요.
2. 문체는 장르에 어울리는 자연스러운 한국 웹소설 스타일을 사용하세요.
3. '세계관'이나 '캐릭터' 같은 제목 라벨을 붙이지 말고, 바로 본문 내용만 출력하세요.
""";

  String userPrompt = """
[현재 스토리 문맥]
$currentStoryContext

[지시 사항]
위 문맥과 설정을 바탕으로 '$targetFieldName' 부분을 상세하고 창의적으로 작성해 주세요.
""";

  // 3. Cloud Function 호출 (기존 callAiProxy 재사용)
  try {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('callAiProxy');
    final result = await callable.call(<String, dynamic>{
      'modelName': 'gpt-4o-mini', // 또는 선호하는 모델
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    });
    return result.data['fullText'] ?? '';
  } catch (e) {
    return "Error generating text: $e";
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
