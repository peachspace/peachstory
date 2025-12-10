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
당신은 AI 이미지 생성을 위한 '프롬프트 번역 및 요약 전문가'입니다.
사용자가 제공하는 스토리 정보(제목, 세계관, 캐릭터 등)를 바탕으로, 그림을 그리기 위한 **핵심 시각 묘사**만 추출하여 **한국어**로 작성하세요.

[절대 금지 사항]
1. 'Title:', 'Setting:', 'Character:' 같은 **영어 라벨이나 분류 형식을 절대 사용하지 마세요.**
2. 영어를 출력하지 마세요. 무조건 한국어로만 작성하세요.
3. 문장 형태보다는 쉼표(,)로 구분된 구체적인 묘사 키워드 위주로 작성하세요.

[작성 예시]
(X) Title: Dragon, Setting: Cave...
(O) 어두운 동굴 안, 거대한 붉은 용, 빛나는 비늘, 긴장감 넘치는 분위기, 판타지 스타일, 웅장한 조명
""";

  String userPrompt = """
[스토리 정보]
$contextInput

[요청]
위 내용을 바탕으로 이미지 생성에 필요한 시각적 묘사만 한국어로 작성해 주세요.
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
