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

/// mode: "background" | "situation" | "event"
Future<String> generateTriggerKeyword(
  String mode,
  String contextInput,
) async {
  final input = contextInput.trim();
  if (input.isEmpty) return "";

  final m = mode.trim().toLowerCase();

  late final String systemPrompt;

  if (m == "background") {
    systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core 'Place Name' from the user input.
CRITICAL RULES:
- Output ONLY ONE place name in Korean.
- No sentence, no explanation, no punctuation.
- Do not output quotes.
""";
  } else if (m == "situation") {
    systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core 'Situation Tag' from the user input.
CRITICAL RULES:
- Output ONLY ONE short tag in Korean.
- Keep it simple (1~4 words).
- No sentence, no explanation, no quotes.
""";
  } else if (m == "event") {
    systemPrompt = """
You are a story narrator helper.
TASK: Create ONLY ONE 'Event Tag' that represents a single crucial story moment.
CRITICAL RULES:
- Output ONLY ONE tag in Korean.
- It should sound like a moment trigger (examples: "~때", "~순간", "~직전").
- Keep proper names if present (예: 지민, 지우).
- No sentence, no explanation, no quotes, no punctuation.
- Do NOT include ":" or brackets.
""";
  } else {
    // 알 수 없는 모드면 situation처럼 처리
    systemPrompt = """
You are a story narrator helper.
TASK: Extract ONLY ONE core 'Tag' from the user input.
CRITICAL RULES:
- Output ONLY ONE short tag in Korean.
- No sentence, no explanation, no quotes.
""";
  }

  final options = HttpsCallableOptions(timeout: const Duration(seconds: 120));
  final callable =
      FirebaseFunctions.instance.httpsCallable('callAiProxy', options: options);

  final result = await callable.call(<String, dynamic>{
    'modelName': 'solar-mini',
    'systemPrompt': systemPrompt,
    'messages': [
      {'role': 'user', 'content': input}
    ],
  });

  String out = (result.data['fullText'] ?? '').toString().trim();

  // ---- 후처리(안전) ----
  out = out.replaceAll('\r\n', '\n').trim();
  out = out.replaceAll('```', '').replaceAll('```json', '').trim();
  out = out.replaceAll('"', '').replaceAll("'", '').trim();

  // 한 줄만
  if (out.contains('\n')) {
    out = out
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList()
        .first;
  }

  // 금지 문자 제거
  out = out.replaceAll(RegExp(r'[\[\]\(\)\{\}]'), '');
  out = out.replaceAll(':', '');
  out = out.replaceAll(RegExp(r'[•\u2022]'), '');
  out = out.replaceAll(RegExp(r'\s{2,}'), ' ').trim();

  // 길이 제한(이벤트는 좀 더 길게 허용)
  final maxLen = (m == "event") ? 32 : 18;
  if (out.length > maxLen) out = out.substring(0, maxLen).trim();

  return out;
}
