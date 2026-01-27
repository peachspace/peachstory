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

import 'package:cloud_functions/cloud_functions.dart' as cf;

// ------------------------------------------------------------
// (A) Trigger 결과 sanitize (첫 줄/따옴표 제거/한글만/길이 제한/fallback)
// ------------------------------------------------------------
String sanitizeTriggerResult(
  String raw,
  String fallbackSource, {
  required String mode,
  int maxLen = 12,
}) {
  String s = raw.trim();

  // 1) 첫 줄만
  if (s.contains('\n')) s = s.split('\n').first.trim();

  // 2) 따옴표 제거
  s = s.replaceAll('"', '').replaceAll("'", "").trim();

  // 3) 혹시 쉼표/설명 붙었으면 첫 토큰만
  if (s.contains(',')) s = s.split(',').first.trim();
  if (s.contains('|')) s = s.split('|').first.trim();

  // 4) situation_trigger면 "한글/숫자/공백"만 남기기 (영문 제거)
  if (mode == "situation_trigger") {
    s = s.replaceAll(RegExp(r'[^0-9\u3131-\uD79D ]'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // 5) 너무 길면 잘라내기
  if (s.length > maxLen) s = s.substring(0, maxLen).trim();

  // 6) 비었으면 fallback
  if (s.isEmpty) {
    final src = fallbackSource.trim();
    final m = RegExp(r'[\u3131-\uD79D]{2,}').firstMatch(src);
    if (m != null) {
      s = m.group(0) ?? '';
    } else {
      s = src.split(RegExp(r'\s+')).first.trim();
    }
  }

  // 7) 최종 길이 제한
  if (s.length > maxLen) s = s.substring(0, maxLen).trim();

  return s;
}

// ------------------------------------------------------------
// (B) 이미지 태그 sanitize (없어서 컴파일 에러 나던 함수)
// ------------------------------------------------------------
String sanitizeTags(
  String raw, {
  int maxTags = 20,
  int maxChars = 400,
}) {
  var s = raw.trim();

  // 통일
  s = s.replaceAll('\n', ',').replaceAll(';', ',');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // 콤마 기준 분리
  final parts =
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  // 중복 제거(대소문자 무시)
  final seen = <String>{};
  final out = <String>[];
  for (final p in parts) {
    final key = p.toLowerCase();
    if (seen.add(key)) out.add(p);
    if (out.length >= maxTags) break;
  }

  var joined = out.join(', ');
  if (joined.length > maxChars) {
    joined = joined.substring(0, maxChars).trim();
    joined = joined.replaceAll(RegExp(r'[, ]+$'), '');
  }

  // 완전 비면 fallback
  if (joined.isEmpty) return 'simple background, clean composition';

  return joined;
}

// ------------------------------------------------------------
// (C) 메인 액션
// ------------------------------------------------------------
Future<String> generateImagePrompt(
  String mode,
  String contextInput,
  String? baseContext,
) async {
  // trigger인데 입력이 빈 경우: 아무것도 생성 안 함
  if (mode.endsWith("_trigger") && contextInput.trim().isEmpty) {
    return "";
  }

  final String finalInput =
      contextInput.trim().isEmpty ? "Create a creative scene" : contextInput;

  String systemPrompt = "";

  // =========================================================
  // 1) Trigger Mode
  // =========================================================
  if (mode.endsWith("_trigger")) {
    if (mode == "background_trigger") {
      systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core 'Place Name' from the user input.

CRITICAL RULES:
- Output ONLY ONE place name in Korean.
- Do NOT output multiple candidates.
- No sentences, no explanation, no punctuation.
Example: "학교랑 병원이랑 공원" -> "공원"
""";
    } else if (mode == "situation_trigger") {
      systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core 'Action Keyword' from the user input.

CRITICAL RULES:
- Output ONLY ONE keyword in Korean.
- Keep it simple (1~2 words).
- No sentences, no explanation.
Example: "칼을 뽑아들고 소리쳤다" -> "칼뽑기"
""";
    } else {
      // 혹시 다른 trigger가 들어오면 기본 처리
      systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core keyword in Korean.
No explanations.
""";
    }
  }

  // =========================================================
  // 2) Image Mode (영문 태그)
  // =========================================================
  else {
    const String baseRules = """
You are an expert AI Art Prompt Engineer.
TASK: Convert the user input into a comma-separated list of English visual tags.

RULES:
1) Output ONLY English tags (comma-separated).
2) Translate Korean concepts into descriptive English tags.
3) Focus on visible elements.
4) DO NOT include quality tags (best quality, masterpiece).
5) DO NOT include style tags (anime style, webtoon).
6) Incorporate the 'Base Context' (character appearance) if provided.
""";

    if (mode.contains("background")) {
      systemPrompt = """
$baseRules
7) Choose ONE coherent background scene only (no mixed locations).
8) No characters, no people, no silhouettes.
9) Output 12~20 tags.
""";
    } else if (mode.contains("situation")) {
      systemPrompt = """
$baseRules
7) Focus on action/pose + small scene cues.
8) Single subject only.
9) Output 15~20 tags.
""";
    } else if (mode == "character") {
      systemPrompt = """
$baseRules
7) Output ONLY immutable character identity tags (appearance).
8) DO NOT include facial expression, emotion, pose, background.
9) Output 10~15 tags.
""";
    } else if (mode.contains("main")) {
      systemPrompt = """
$baseRules
7) Focus on cover illustration composition.
8) Single character centered.
9) Output 20~30 tags.
""";
    } else if (mode.contains("emotion")) {
      systemPrompt = """
$baseRules
7) Output ONLY facial expression and emotion tags.
8) Single subject only.
9) Output 5~10 tags.
""";
    } else {
      systemPrompt = """
$baseRules
7) Output 15 tags max.
""";
    }
  }

  // ✅ userPrompt도 trigger / image 모드에 맞게 분리 (충돌 방지)
  final String userPrompt = mode.endsWith("_trigger")
      ? """
[Mode: $mode]
[User Input]: $finalInput

Return ONLY the final Korean keyword.
"""
      : """
[Mode: $mode]
[User Input]: $finalInput
[Base Context]: ${baseContext ?? "None"}

Return ONLY the comma-separated English tags.
""";

  try {
    final callable = cf.FirebaseFunctions.instance.httpsCallable(
      'callAiProxy',
      options: cf.HttpsCallableOptions(timeout: const Duration(seconds: 120)),
    );

    final result = await callable.call(<String, dynamic>{
      'modelName': 'solar-mini',
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    String rawOutput = (data['fullText'] ?? '').toString();

    // ✅ trigger 모드는 여기서 sanitize해서 바로 return
    if (mode.endsWith("_trigger")) {
      final fixed = sanitizeTriggerResult(
        rawOutput,
        contextInput,
        mode: mode,
        maxLen: (mode == "background_trigger") ? 18 : 12,
      );
      return fixed.trim();
    }

    // ---- 이미지 태그 sanitize ----
    // 허용 문자만 남기기
    rawOutput = rawOutput.replaceAll(RegExp(r'[^a-zA-Z0-9, \-\.\(\)]'), '');

    int limit = 20;
    if (mode == "emotion") {
      limit = 10;
    } else if (mode == "character") {
      limit = 15;
    }

    rawOutput = sanitizeTags(rawOutput, maxTags: limit, maxChars: 400);
    return rawOutput.trim();
  } catch (e) {
    print("Error in generateImagePrompt: $e");
    return "";
  }
}
