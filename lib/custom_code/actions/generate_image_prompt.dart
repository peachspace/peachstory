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
  // [수정1] style 파라미터 삭제 (사용하지 않음)
) async {
  String systemPrompt = "";

  // [수정3] 트리거 모드인데 입력이 없으면 불필요한 호출 방지
  if (mode.endsWith("_trigger") && contextInput.trim().isEmpty) {
    return "";
  }

  String finalInput =
      contextInput.trim().isEmpty ? "Create a creative scene" : contextInput;

  // =========================================================
  // 1. [Trigger Mode] 조건문/단어 추출 (한국어)
  // =========================================================
  if (mode.endsWith("_trigger")) {
    if (mode == "background_trigger") {
      systemPrompt = """
You are a story narrator helper.
YOUR TASK: Extract ONLY the core 'Place Name' (Noun) from the user input.
RULES:
1. Output ONLY the place name in Korean.
2. NO sentences, NO conditions.
3. Example: "학교에 갔을 때" -> "학교"
""";
    } else if (mode == "situation_trigger") {
      systemPrompt = """
You are a story narrator helper.
YOUR TASK: Extract ONLY the core 'Action Keyword' (Noun or short Verb).
RULES:
1. Output ONLY the action keyword in Korean.
2. Keep it simple (1-2 words).
3. Example: "칼을 뽑아들었을 때" -> "칼뽑기"
""";
    }
  }
  // =========================================================
  // 2. [Image Mode] 이미지 프롬프트 생성 (영어)
  // =========================================================
  else {
    String baseRules = """
You are an expert AI Art Prompt Engineer.
YOUR TASK: Convert the user's input into a comma-separated list of English visual tags.
RULES:
1. Output ONLY English words.
2. Translate Korean concepts into descriptive English tags.
3. Focus on visible elements (clothing, hair, lighting, pose, background).
4. DO NOT include quality tags like "best quality", "masterpiece" (The system adds them).
5. DO NOT include style tags like "anime style", "webtoon" (The system adds them).
6. Incorporate the 'Base Context' (Character appearance) if provided.
""";

    // 모드별 세부 지침
    if (mode.contains("background")) {
      systemPrompt = """
$baseRules
7. Focus on Scenery, Architecture, Time of day, Weather.
8. Ensure NO characters are described (Scenery only).
Example Output: empty classroom, sunlight through window, wooden desks, blackboard, afternoon
""";
    } else if (mode.contains("situation")) {
      systemPrompt = """
$baseRules
7. Focus on Action, Dynamic Pose, Interaction, Camera Angle.
8. Describe the Character's features from 'Base Context'.
Example Output: 1girl, running fast, sweating, desperate expression, forest path, dynamic angle
""";
    } else if (mode == "character") {
      systemPrompt = """
$baseRules
7. Focus on 'Character Design Sheet' style.
8. Background should be simple or plain (white or solid color) to highlight the character.
9. Describe the character's facial features, hairstyle, and clothing in detail.
10. Pose should be standard standing or portrait pose.
Example Output: 1boy, black hair, blue eyes, wearing school uniform, simple white background, front view, character design
""";
    } else if (mode.contains("main")) {
      systemPrompt = """
$baseRules
7. Focus on 'High-Quality Webnovel Cover Illustration'.
8. COMBINE the 'Character Appearance' with the 'World View' (Base Context).
9. Create a dramatic atmosphere, lighting, and background that fits the World View.
10. The character should be placed in a scene from the World View.
Example Output: 1boy, holding a glowing sword, standing on a ruined castle, dark fantasy atmosphere, red moon background, cinematic lighting, epic composition
""";
    } else if (mode.contains("emotion")) {
      systemPrompt = """
$baseRules
7. Focus ONLY on Facial Expression and Emotion.
8. Keep it simple.
Example Output: crying, tears, sad eyes, mouth open
""";
    } else {
      // Fallback
      systemPrompt = """
$baseRules
7. Focus on Character Design.
""";
    }
  }

  String userPrompt = """
[Mode: $mode]
[User Input]: $finalInput
[Base Context]: ${baseContext ?? "None"}

Request: Generate the English tags list.
""";

  try {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('callAiProxy');
    final result = await callable.call(<String, dynamic>{
      'modelName': 'solar-mini',
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    });

    String rawOutput = result.data['fullText'] ?? '';

    // [수정2] 후처리 강화: 마침표(.)와 괄호()도 허용
    if (!mode.endsWith("_trigger")) {
      // 영어, 숫자, 쉼표, 공백, 하이픈, 마침표, 괄호 외 제거
      rawOutput = rawOutput.replaceAll(RegExp(r'[^a-zA-Z0-9, \-\.\(\)]'), '');
    }

    return rawOutput.trim();
  } catch (e) {
    print("Error in generateImagePrompt: $e");
    return "";
  }
}
