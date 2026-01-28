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

String _sanitizeTrigger(String raw,
    {required String fallback, int maxLen = 18}) {
  var s = raw.trim();
  if (s.contains('\n')) s = s.split('\n').first.trim();
  s = s.replaceAll('"', '').replaceAll("'", '').trim();
  if (s.contains(',')) s = s.split(',').first.trim();
  if (s.contains('|')) s = s.split('|').first.trim();
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (s.length > maxLen) s = s.substring(0, maxLen).trim();
  if (s.isEmpty) {
    final src = fallback.trim();
    final m = RegExp(r'[\u3131-\uD79D]{2,}').firstMatch(src);
    s = (m?.group(0) ?? src.split(RegExp(r'\s+')).first).trim();
  }
  if (s.length > maxLen) s = s.substring(0, maxLen).trim();
  return s;
}

/// mode: "background" | "situation"
Future<String> generateTriggerKeyword(
  String mode,
  String contextInput,
) async {
  final input = contextInput.trim();
  if (input.isEmpty) return "";

  late final String systemPrompt;
  if (mode == "background") {
    systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core 'Place Name' from the user input.
CRITICAL RULES:
- Output ONLY ONE place name in Korean.
- No sentence, no explanation, no punctuation.
""";
  } else if (mode == "situation") {
    systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core 'Action Keyword' from the user input.
CRITICAL RULES:
- Output ONLY ONE keyword in Korean.
- Keep it simple (1~2 words).
- No sentence, no explanation.
Example: "칼을 뽑아들고 소리쳤다" -> "칼뽑기"
""";
  } else {
    systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core keyword in Korean.
No explanations.
""";
  }

  final userPrompt = """
[Mode: ${mode}_trigger]
[User Input]: $input
Return ONLY the final Korean keyword.
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
    final raw = (data['fullText'] ?? '').toString();
    return _sanitizeTrigger(raw,
        fallback: input, maxLen: mode == "background" ? 18 : 12);
  } catch (_) {
    return "";
  }
}
