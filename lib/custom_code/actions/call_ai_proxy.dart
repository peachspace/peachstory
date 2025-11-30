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

Future<String?> callAiProxy(
  String? modelName,
  String? systemPrompt,
  List<dynamic>? messages,
  String? recentUserMessage,
  String? summary, // [Step A에서 추가한 Argument 이름과 똑같아야 합니다]
) async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('callAiProxy');

  // 1. 시스템 프롬프트 강화
  // 요약이 존재하면 AI에게 "이 요약을 기억하라"고 지시합니다.
  String finalSystemPrompt =
      systemPrompt ?? "You are a helpful story assistant.";

  if (summary != null && summary.isNotEmpty) {
    finalSystemPrompt +=
        "\n\n[STORY SUMMARY]\n$summary\n\n[INSTRUCTION]\nUse the summary above to maintain continuity. Do NOT repeat events from the summary.";
  }

  // 2. 메시지 리스트 구성
  List<dynamic> finalMessages = messages != null ? List.from(messages) : [];

  // (선택 사항) 시스템 메시지를 메시지 리스트의 첫 번째로 넣거나,
  // 클라우드 함수의 systemPrompt 인자로 별도로 보냅니다.
  // 여기서는 클라우드 함수가 systemPrompt를 처리한다고 가정하고 그대로 둡니다.

  // 유저의 최신 메시지 추가
  if (recentUserMessage != null && recentUserMessage.isNotEmpty) {
    finalMessages.add({
      'role': 'user',
      'content': recentUserMessage,
    });
  }

  try {
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'modelName': modelName,
      'systemPrompt': finalSystemPrompt, // 강화된 프롬프트 전달
      'messages': finalMessages,
    });
    return result.data['fullText'];
  } on FirebaseFunctionsException catch (e) {
    print('Cloud Function Error: ${e.code} - ${e.message}');
    return 'ERROR: ${e.message}';
  } catch (e) {
    print('Generic Error: $e');
    return 'ERROR: 알 수 없는 오류 발생';
  }
}
