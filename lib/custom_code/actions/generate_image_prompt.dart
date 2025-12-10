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

import 'package:cloud_functions/cloud_functions.dart'; // 필수

Future<String> generateImagePrompt(
  String contextInput,
) async {
  // [수정] 시스템 프롬프트: 한글 묘사 생성
  String systemPrompt = """
당신은 AI 이미지 생성을 위한 프롬프트 전문가입니다.
사용자의 스토리 내용을 바탕으로, 그림으로 그리기 좋은 **'시각적 묘사'를 한국어로** 작성해 주세요.
- 인물, 행동, 배경, 조명, 분위기 위주로 구체적으로 묘사하세요.
- 예시: "어두운 동굴 속에서 빛나는 검을 든 기사, 긴장감 넘치는 분위기, 푸른색 조명"
- 영어로 번역하지 말고 **한국어**로만 출력하세요.
""";

  String userPrompt = """
[스토리 내용]
$contextInput

[요청]
위 내용을 바탕으로 이미지 생성용 묘사 텍스트를 작성해 주세요.
""";

  // 3. Cloud Function 호출 (기존 callAiProxy 재사용)
  try {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('callAiProxy');
    final result = await callable.call(<String, dynamic>{
      'modelName': 'gpt-4o-mini', // 빠르고 저렴한 모델 추천
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    });
    return result.data['fullText'] ?? '';
  } catch (e) {
    return "Error: $e";
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
