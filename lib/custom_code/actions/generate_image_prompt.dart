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

// [핵심] 태그 정리 함수 (중복 제거, 개수 제한, 길이 제한)
String sanitizeTags(
  String raw, {
  int maxTags = 25,
  int maxChars = 500,
}) {
  final parts =
      raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  final seen = <String>{};
  final cleaned = <String>[];

  for (final p in parts) {
    final key = p.toLowerCase();
    // 너무 긴 토큰(문장형) 제거
    if (p.length > 60) continue;
    // 중복 제거
    if (seen.contains(key)) continue;

    seen.add(key);
    cleaned.add(p);

    if (cleaned.length >= maxTags) break;
  }

  var out = cleaned.join(', ');

  if (out.length > maxChars) {
    out = out.substring(0, maxChars);
    final lastComma = out.lastIndexOf(',');
    if (lastComma > 0) out = out.substring(0, lastComma);
  }

  return out.trim();
}

Future<String> generateImagePrompt(
  String mode,
  String contextInput,
  String? baseContext,
) async {
  String systemPrompt = "";

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
      // [수정] 여러 장소가 입력되더라도 '가장 중요한 1곳'만 명사로 추출하도록 강제
      systemPrompt = """
You are a story narrator helper.
YOUR TASK: Extract ONLY ONE core 'Place Name' (Noun) from the user input.
CRITICAL RULES:
1. Output **ONLY ONE** place name in Korean. (Do NOT list multiple places)
2. If multiple places are mentioned, select the most important ONE.
3. NO sentences, NO conditions.
4. Example: "학교랑 병원이랑 공원" -> "공원"
""";
    } else if (mode == "situation_trigger") {
      systemPrompt = """
You are a story narrator helper.
YOUR TASK: Extract ONLY ONE core 'Action Keyword' (Noun or short Verb).
CRITICAL RULES:
1. Output **ONLY ONE** action keyword in Korean.
2. Keep it simple (1-2 words).
3. If multiple actions are mentioned, select the main ONE.
4. Example: "칼을 뽑아들고 소리쳤다" -> "칼뽑기"
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
3. Focus on visible elements.
4. DO NOT include quality tags like "best quality", "masterpiece".
5. DO NOT include style tags like "anime style", "webtoon".
6. Incorporate the 'Base Context' (Character appearance) if provided.
""";

    // [수정] 배경 모드에서 '단일 장소' 및 '인물 제외' 강력하게 지시
    if (mode.contains("background")) {
      systemPrompt = """
$baseRules
7. **CRITICAL: Choose ONE coherent background scene only.**
8. Do NOT mix multiple locations. Pick the most prominent one.
9. Output 12 to 20 tags max.
10. Ensure NO characters, NO people, NO silhouettes.
Example Output: modern cafe interior, sunlight through glass window, wooden table, cozy atmosphere, coffee cup, indoor plants
""";
    } else if (mode.contains("situation")) {
      systemPrompt = """
$baseRules
7. Output ONLY action/pose + small scene cues.
8. **CRITICAL: Single subject only.**
9. DO NOT include: character sheet, multiple views, collage.
10. Describe the action dynamically. Output 15-20 tags max.
Example Output: throwing a ball, arm extended, dynamic motion, action lines, sweating, athletic pose, focused expression
""";
    } else if (mode == "character") {
      systemPrompt = """
$baseRules
7. Output ONLY immutable character identity tags (appearance).
8. **CRITICAL: DO NOT include: facial expression, emotion, pose, background, "character design sheet", "front view".**
9. Use single character keywords. Output 10-15 tags max.
Example Output: 1woman, 20s, long black hair, blue eyes, white blouse, silver necklace, neutral expression
""";
    } else if (mode.contains("main")) {
      systemPrompt = """
$baseRules
7. Focus on 'Cover Illustration' composition.
8. **Single character centered.**
9. Output 20-30 tags max.
Example Output: 1boy, holding a glowing sword, standing on ruins, dark fantasy atmosphere, red moon, cinematic lighting, dynamic angle
""";
    } else if (mode.contains("emotion")) {
      systemPrompt = """
$baseRules
7. Output ONLY facial expression and emotion tags.
8. **Single subject only.**
9. Output 5-10 tags max.
Example Output: joyful smile, beaming, sparkling eyes, blushing, mouth open
""";
    } else {
      systemPrompt = """
$baseRules
7. Focus on Character Design. Output 15 tags max.
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

    // [후처리] 특수문자 제거 및 태그 정리 (sanitizeTags 적용)
    if (!mode.endsWith("_trigger")) {
      rawOutput = rawOutput.replaceAll(RegExp(r'[^a-zA-Z0-9, \-\.\(\)]'), '');

      // 모드별 제한 적용
      int limit = 20;
      if (mode == "emotion")
        limit = 10;
      else if (mode == "character") limit = 15;

      rawOutput = sanitizeTags(rawOutput, maxTags: limit, maxChars: 400);
    }

    return rawOutput.trim();
  } catch (e) {
    print("Error in generateImagePrompt: $e");
    return "";
  }
}
