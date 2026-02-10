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

final RegExp _forbiddenStyleRe = RegExp(
  r'(\bmasterpiece\b|\bbest quality\b|\bhigh quality\b|\banime\b|\bwebtoon\b|\bmanhwa\b|\blineart\b|\bcel shading\b|\bflat color\b|\b8k\b|\b4k\b|\bphotorealistic\b|\brealistic\b|\bcinematic\b|\brender\b|\bstyle\b|\bquality\b)',
  caseSensitive: false,
);

// ✅ ID/외모 태그가 다른 모드에 섞여 나오는 것 방지용(2차 방어)
final RegExp _identityLeakRe = RegExp(
  r'(\b(hair|eyes|skin|face|jaw|nose|lips|eyebrows|eyelids|freckles|beauty mark)\b)',
  caseSensitive: false,
);

// ✅ character 모드: 괄호/가중치/문장 제거를 더 강하게
String _postFilterByMode(String s, String mode) {
  var out = s;

  // 공통: 스타일/퀄리티 제거
  out = out.replaceAll(_forbiddenStyleRe, ' ');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (mode != "character") {
    // ✅ emotion/situation/main/background 등에서는
    // “외모/정체성(눈/머리/피부/얼굴형…)” 관련 태그가 새로 생성되지 않게 2차 차단
    out = out.replaceAll(_identityLeakRe, ' ');
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
  } else {
    // ✅ character에서는 "NO parentheses, NO weights"를 더 강제
    out = out.replaceAll(RegExp(r'[\(\)]'), ' ');
    out = out.replaceAll(RegExp(r':\s*\d+(\.\d+)?'), ' '); // :1.2 같은 가중치 제거
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  return out;
}

String _sanitizeTags(
  String raw, {
  required String mode,
  int maxTags = 20,
  int maxChars = 400,
}) {
  var s = raw.trim();
  s = s.replaceAll('\n', ',').replaceAll(';', ',');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // 2차 방어(모드별 후처리)
  s = _postFilterByMode(s, mode);

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

  if (joined.isEmpty) {
    // mode별 fallback
    if (mode == "emotion") return "neutral expression";
    if (mode == "background") return "simple background, clean composition";
    return "simple composition";
  }

  return joined;
}

/// mode: "character" | "emotion" | "situation" | "background" | "main"
Future<String> generateVisualTags(
  String mode,
  String contextInput,
  String? baseContext,
) async {
  final input = contextInput.trim().isEmpty
      ? (mode == "character"
          ? "Describe ONLY face & hair identity."
          : "Create a creative scene")
      : contextInput.trim();

  // ✅ baseRules: 기본적으로 Base Context(외모) 반영 규칙을 제거
  //    -> 외모는 “character에서만 생성/저장”하고,
  //       다른 모드에서는 서버가 basePrompt를 강제 주입하는 구조로 역할 분리
  const baseRules = """
You are an expert AI Art Prompt Engineer.
TASK: Convert the user input into a comma-separated list of English visual tags.
RULES:
1) Output ONLY English tags (comma-separated).
2) Translate Korean concepts into descriptive English tags.
3) Focus on visible elements.
4) DO NOT include quality tags (best quality, masterpiece).
5) DO NOT include style tags (anime style, webtoon).
""";

  late final String systemPrompt;

  if (mode == "background") {
    systemPrompt = """
$baseRules
6) Choose ONE coherent background scene only (no mixed locations).
7) No characters, no people, no silhouettes.
8) STRICTLY FORBIDDEN: any character identity tags (hair/eyes/skin/face), clothing/outfit.
9) Output 12~20 tags.
""";
  } else if (mode == "situation") {
    systemPrompt = """
$baseRules
6) Focus on action/pose + small scene cues.
7) Single subject only.
8) STRICTLY FORBIDDEN: any character identity tags (hair/eyes/skin/face). Do NOT describe appearance.
9) Output 12~18 tags.
10) Include EXACTLY ONE framing tag among:
- close-up
- upper body, waist up
- full body
Choose the best framing for the action.
""";
  } else if (mode == "character") {
    systemPrompt = """
$baseRules
6) Output ONLY immutable facial identity & hair identity tags.
7) STRICTLY FORBIDDEN: clothing/outfit, accessories, background/location, lighting, camera/framing, pose/action, emotion/expression, age words, style/quality words.
8) Output 10~14 tags only.

MANDATORY (must include):
A) Hair color + hair length + hair style (e.g., "black long hair", "wavy hair", "bangs")
B) Eye color (+ optional eye shape) (e.g., "brown eyes", "droopy eyes")
C) Skin tone (e.g., "fair skin")
D) Face shape / structure descriptors (choose 2~4):
   - "oval face" | "round face" | "sharp jawline" | "small nose" | "full lips" | "thin lips" | "high nose bridge" | "small mouth"
E) 1 signature facial detail (choose 1):
   - "beauty mark under eye" | "freckles" | "thick eyebrows" | "thin eyebrows" | "double eyelids"

OUTPUT FORMAT:
- comma-separated English tags only
- NO parentheses, NO weights, NO sentences
""";
  } else if (mode == "main") {
    systemPrompt = """
$baseRules
6) Focus on cover illustration composition.
7) Single character centered.
8) STRICTLY FORBIDDEN: any character identity tags (hair/eyes/skin/face). Do NOT describe appearance.
9) Output 18~26 tags.
""";
  } else if (mode == "emotion") {
    systemPrompt = """
$baseRules
6) Output ONLY facial expression and emotion tags.
7) Single subject only.
8) STRICTLY FORBIDDEN: any character identity tags (hair/eyes/skin/face). Do NOT describe appearance.
9) Output 5~10 tags.
""";
  } else {
    systemPrompt = """
$baseRules
6) Output 12 tags max.
""";
  }

  // ✅ userPrompt: character만 Base Context를 넣을지 말지 선택
  // - 원칙상 character는 “유저 입력으로 외모만 받는다”면 baseContext 자체가 필요 없고,
  //   혹시 이전 값이 있으면 ‘보정’ 정도로만 쓰고 싶을 때만 포함
  final includeBaseContext =
      (mode == "character" && (baseContext ?? "").trim().isNotEmpty);

  final userPrompt = includeBaseContext
      ? """
[Mode: ${mode}_tags]
[User Input]: $input
[Optional Base Context (identity)]: ${baseContext!.trim()}
Return ONLY the comma-separated English tags.
"""
      : """
[Mode: ${mode}_tags]
[User Input]: $input
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

    // 허용 문자만(기존 유지) — character는 괄호도 금지라 후처리에서 제거됨
    raw = raw.replaceAll(RegExp(r'[^a-zA-Z0-9, \-\.\(\):]'), '');

    int limit = 20;
    if (mode == "emotion") limit = 10;
    if (mode == "character") limit = 14;
    if (mode == "main") limit = 26;
    if (mode == "situation") limit = 18;

    return _sanitizeTags(raw, mode: mode, maxTags: limit, maxChars: 400).trim();
  } catch (_) {
    return "";
  }
}
