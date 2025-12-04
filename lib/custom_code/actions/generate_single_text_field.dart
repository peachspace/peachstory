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
  // 1. 시스템 프롬프트 설정 (역할 부여)
  String systemPrompt = """
You are a professional novel assistant.
Your task is to generate content for the '$targetFieldName' section of a story.
Maintain consistency with the provided story context.
Output ONLY the generated text for the section, no introductory notes.
""";

  // 2. 사용자 프롬프트 설정 (문맥 제공)
  String userPrompt = """
[Current Story Context]
$currentStoryContext

[Instruction]
Generate a detailed and creative '$targetFieldName' based on the context above.
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
