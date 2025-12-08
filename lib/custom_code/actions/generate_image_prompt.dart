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
  // 1. 시스템 프롬프트: 번역가 역할 부여
  String systemPrompt = """
You are an expert prompt engineer for AI image generation (Stable Diffusion).
Your task is to translate the user's Korean description into a descriptive English prompt.
- Focus on visual elements (appearance, atmosphere, lighting, style).
- Use comma-separated keywords or short phrases.
- Do NOT include conversational filler like "Here is the prompt". Just output the English text.
""";

  // 2. 사용자 프롬프트: 한글 내용 전달
  String userPrompt = """
[Translate to English Image Prompt]
$contextInput
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
