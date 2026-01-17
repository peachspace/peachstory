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

Future<String> generateImagePrompt(
  String mode,
  String contextInput,
  String? baseContext,
) async {
  String systemPrompt = "";
  // 사용자가 아무것도 입력하지 않았을 때 처리
  String finalInput = contextInput.trim().isEmpty ? "Random" : contextInput;

  // =========================================================
  // 1. [Trigger Mode] 조건문 생성
  // =========================================================
  if (mode.endsWith("_trigger")) {
    if (mode == "background_trigger") {
      systemPrompt = """
You are a story narrator helper.
YOUR TASK: Convert the user's location keyword into a natural 'Time/Place Condition' phrase for a story.
RULES:
1. Output ONLY the condition phrase in Korean.
2. Example Input: "학교" -> Output: "학교에 도착했을 때"
3. Example Input: "숲" -> Output: "깊은 숲속으로 들어갔을 때"
4. Keep it short and natural.
""";
    } else if (mode == "situation_trigger") {
      systemPrompt = """
You are a story narrator helper.
YOUR TASK: Convert the user's action keyword into a natural 'Action Condition' phrase.
RULES:
1. Output ONLY the condition phrase in Korean.
2. Example Input: "달리기" -> Output: "전력으로 달릴 때"
3. Example Input: "공격" -> Output: "적을 향해 무기를 휘두를 때"
""";
    }
  }
  // =========================================================
  // 2. [Image Mode] 시각적 태그 생성
  // =========================================================
  else {
    // 공통 규칙: 시각적 태그만 출력
    String baseRules = """
You are an expert AI Art Prompt Engineer.
YOUR TASK: Create a comma-separated list of visual tags based on the input.
RULES:
1. Output ONLY English visual tags. NO sentences.
2. Incorporate the 'Base Context' (World View or Character Appearance) to enrich the visual details.
""";

    if (mode == "background_image") {
      systemPrompt = """
$baseRules
3. Focus on Scenery, Architecture, Weather, Lighting based on the 'User Input' condition.
4. Start with: "masterpiece, best quality, anime style, scenery, no humans".
""";
    } else if (mode == "situation_image") {
      systemPrompt = """
$baseRules
3. Focus on Character Pose, Action, Camera Angle based on the 'User Input' action.
4. IMPORTANT: Describe the Character's looks from 'Base Context'.
5. Start with: "masterpiece, best quality, anime style, solo".
""";
    } else if (mode == "main_image") {
      // [★ 추가된 부분] 메인 이미지 (표지/대표 이미지) 생성 로직
      systemPrompt = """
$baseRules
3. Focus on a High-Quality PORTRAIT or Key Visual for a novel cover.
4. 'Base Context' contains the Main Character's appearance. USE IT.
5. 'User Input' contains the Background/Atmosphere or Theme.
6. Start with: "masterpiece, best quality, anime style, solo, cinematic lighting, looking at viewer".
""";
    } else if (mode == "emotion") {
      // [★ 추가 추천] 감정 표현 극대화 모드
      systemPrompt = """
$baseRules
3. Focus ONLY on the Character's Facial Expression and Emotion.
4. IMPORTANT: Describe the Character's looks from 'Base Context'.
5. Start with: "masterpiece, best quality, anime style, solo, extreme close-up, expressive face".
""";
    } else {
      // Character Mode (기존 유지)
      systemPrompt = """
$baseRules
3. Focus on Character Design (Hair, Eyes, Clothes).
4. Start with: "masterpiece, best quality, anime style, solo, portrait".
""";
    }
  }

  String userPrompt = """
[Mode: $mode]
[User Input]: $finalInput
[Base Context]: ${baseContext ?? "None"}

Request: Generate the output according to the system rules.
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
