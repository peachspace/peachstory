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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:cloud_functions/cloud_functions.dart';

Future<String> generateImagePrompt(
  String mode,
  String contextInput,
  String? baseContext,
  String style,
) async {
  String systemPrompt = "";
  String finalInput = contextInput.trim().isEmpty ? "Random" : contextInput;

  // =========================================================
  // 1. [Trigger Mode] 조건문/단어 추출 (기존 로직 유지 - 한국어 처리)
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
  // 2. [Image Mode] 이미지 생성용 프롬프트 (영어 변환 필수!)
  // =========================================================
  else {
    // [중요] 서버(Cloud Functions)가 스타일과 화질 태그를 담당하므로,
    // 여기서는 "시각적 묘사(Visual Description)"를 영어로 번역하는 데 집중합니다.

    String baseRules = """
You are an expert AI Art Prompt Engineer for Stable Diffusion.
YOUR TASK: Convert the user's input into a comma-separated list of English visual tags.
RULES:
1. Output ONLY English words.
2. Translate Korean concepts into descriptive English tags.
3. Focus on visible elements (clothing, hair, lighting, pose, background).
4. DO NOT include quality tags like "best quality", "masterpiece" (The system adds them).
5. DO NOT include style tags like "anime style", "webtoon" (The system adds them).
6. Incorporate the 'Base Context' (Character appearance) if provided.
""";

    if (mode == "background_image") {
      systemPrompt = """
$baseRules
7. Focus on Scenery, Architecture, Time of day, Weather.
8. Ensure NO characters are described (Scenery only).
Example Output: empty classroom, sunlight through window, wooden desks, blackboard, afternoon
""";
    } else if (mode == "situation_image") {
      systemPrompt = """
$baseRules
7. Focus on Action, Dynamic Pose, Interaction, Camera Angle.
8. Describe the Character's features from 'Base Context'.
Example Output: 1girl, running fast, sweating, desperate expression, forest path, dynamic angle
""";
    } else if (mode == "main_image") {
      systemPrompt = """
$baseRules
7. Focus on a High-Quality Portrait Composition.
8. Describe the Character's features in detail from 'Base Context'.
Example Output: 1boy, black hair, blue eyes, wearing suit, looking at viewer, city night background, rim lighting
""";
    } else if (mode == "emotion") {
      systemPrompt = """
$baseRules
7. Focus ONLY on Facial Expression and Emotion.
8. Keep it simple.
Example Output: crying, tears, sad eyes, mouth open
""";
    } else {
      // Default (Character)
      systemPrompt = """
$baseRules
7. Focus on Character Design and Appearance.
Example Output: 1girl, pink hair, school uniform, white background, simple pose
""";
    }
  }

  // 사용자 프롬프트 구성
  String userPrompt = """
[Mode: $mode]
[User Input (Korean)]: $finalInput
[Base Context (Character Info)]: ${baseContext ?? "None"}

Request: Generate the English tags list.
""";

  try {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('callAiProxy');
    final result = await callable.call(<String, dynamic>{
      'modelName': 'solar-mini', // 빠르고 저렴한 모델 추천
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
