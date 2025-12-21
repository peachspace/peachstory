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

Future<String> translateToEnglish(String inputString) async {
  // 한글 -> 영어 (Stable Diffusion용 키워드) 변환
  String systemPrompt = """
Translate the following Korean description into a descriptive English prompt for Stable Diffusion AI.
- Use comma-separated keywords and phrases.
- Focus on visual elements.
- Output ONLY the English text.
""";

  try {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('callAiProxyV2');
    final result = await callable.call(<String, dynamic>{
      'modelName': 'gpt-4o-mini',
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': inputString}
      ],
    });
    return result.data['fullText'] ?? '';
  } catch (e) {
    return inputString; // 에러 시 원문 반환
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
