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

// ... imports ...
import 'package:cloud_functions/cloud_functions.dart';

Future<String> generateImagePrompt(
  String mode,
  String contextInput,
  String? baseContext,
) async {
  String systemPrompt = "";
  // 사용자가 아무것도 입력하지 않았을 때 처리
  String finalInput = contextInput.trim().isEmpty
      ? "Create a random, unique, and attractive anime character."
      : contextInput;

  // 1. 모드별 시스템 프롬프트
  if (mode == "background") {
    systemPrompt = """
You are an expert AI Art Prompt Engineer for Anime Backgrounds.
Convert the user's "Situation" and "World Setting" into a high-quality, comma-separated English prompt.
Start with: "masterpiece, best quality, anime style, scenery, no humans".
Combine the 'World Setting' context with the specific 'Situation'.
""";
  } else if (mode == "situation") {
    systemPrompt = """
You are an expert AI Art Prompt Engineer for Anime Characters.
Convert the "Action" into a dynamic English prompt describing the pose and action.
Focus purely on the dynamic movement.
Style: "masterpiece, best quality, anime style".
""";
  } else {
    // [Character Mode] 무작위 생성 지원
    systemPrompt = """
You are an expert AI Art Prompt Engineer for Anime Characters.
If the input is "Random" or empty, create a detailed description for a unique anime character (hair, eyes, clothes).
If the user provides a description, convert it into English prompt keys.
Start with: "masterpiece, best quality, anime style, solo, portrait".
""";
  }

  String userPrompt = """
[Mode: $mode]
[User Input]: $finalInput
[Base Context]: ${baseContext ?? "None"}

Request: Create a detailed, high-quality English prompt.
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
    return result.data['fullText'] ?? '';
  } catch (e) {
    return "Error: $e";
  }
}
