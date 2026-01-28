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

import 'package:cloud_functions/cloud_functions.dart' as cf;

String _sanitizeTags(String raw, {int maxTags = 20, int maxChars = 400}) {
  var s = raw.trim();
  s = s.replaceAll('\n', ',').replaceAll(';', ',');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // 콤마 분리
  final parts =
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  // 중복 제거
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
  if (joined.isEmpty) return 'simple background, clean composition';
  return joined;
}

/// mode: "character" | "emotion" | "situation" | "background" | "main"
Future<String> generateVisualTags(
  String mode,
  String contextInput,
  String? baseContext,
) async {
  final input = contextInput.trim().isEmpty
      ? "Create a creative scene"
      : contextInput.trim();

  const baseRules = """
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

  late final String systemPrompt;
  if (mode == "background") {
    systemPrompt = """
$baseRules
7) Choose ONE coherent background scene only (no mixed locations).
8) No characters, no people, no silhouettes.
9) Output 12~20 tags.
""";
  } else if (mode == "situation") {
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
  } else if (mode == "main") {
    systemPrompt = """
$baseRules
7) Focus on cover illustration composition.
8) Single character centered.
9) Output 20~30 tags.
""";
  } else if (mode == "emotion") {
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

  final userPrompt = """
[Mode: ${mode}_tags]
[User Input]: $input
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
    var raw = (data['fullText'] ?? '').toString();

    // 허용 문자만
    raw = raw.replaceAll(RegExp(r'[^a-zA-Z0-9, \-\.\(\)]'), '');

    int limit = 20;
    if (mode == "emotion") limit = 10;
    if (mode == "character") limit = 15;

    return _sanitizeTags(raw, maxTags: limit, maxChars: 400).trim();
  } catch (_) {
    return "";
  }
}
