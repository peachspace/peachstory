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

import 'index.dart'; // Imports other custom actions

import 'package:cloud_functions/cloud_functions.dart';

Future<String?> callAiProxy(
  String? modelName,
  String? systemPrompt,
  List<dynamic>? messages,
  String? recentUserMessage,
  String? summary, // 이전에 추가한 summary 파라미터
) async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('callAiProxy');

  // [핵심] 시스템 프롬프트 강력 수정
  String reinforcedSystemPrompt = """
${systemPrompt ?? "You are a professional story writer."}

[CRITICAL RULES]
1. Output MUST be a valid JSON array only (e.g., [{"type": "dialogue", ...}]). 
2. DO NOT include any introductory or concluding text outside the JSON.
3. NO REPETITION: Do not repeat any dialogue or narration that has already occurred in the history or summary. Write the NEXT scene.
4. If a 'Summary' is provided, use it as context but do not rewrite it.
""";

  if (summary != null && summary.isNotEmpty) {
    reinforcedSystemPrompt += "\n\n[STORY SUMMARY]\n$summary";
  }

  // 메시지 리스트 구성
  List<dynamic> finalMessages = messages != null ? List.from(messages) : [];

  // 유저 메시지 추가
  if (recentUserMessage != null && recentUserMessage.isNotEmpty) {
    finalMessages.add({
      'role': 'user',
      'content': recentUserMessage,
    });
  }

  try {
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'modelName': modelName,
      'systemPrompt': reinforcedSystemPrompt,
      'messages': finalMessages,
    });
    return result.data['fullText'];
  } on FirebaseFunctionsException catch (e) {
    return 'ERROR: ${e.message}';
  } catch (e) {
    return 'ERROR: 알 수 없는 오류 발생';
  }
}
