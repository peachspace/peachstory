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
  String? recentUserMessage, // 1. [추가됨] 방금 보낸 메시지 인자
) async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('callAiProxy');

  // 2. [수정됨] 과거 내역(messages)에 방금 보낸 메시지(recentUserMessage)를 합칩니다.
  List<dynamic> finalMessages = messages != null ? List.from(messages) : [];

  if (recentUserMessage != null && recentUserMessage.isNotEmpty) {
    finalMessages.add({
      'role': 'user',
      'content': recentUserMessage,
    });
  }

  try {
    // 3. Cloud Function에 합쳐진 메시지(finalMessages)를 전달합니다.
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'modelName': modelName,
      'systemPrompt': systemPrompt,
      'messages': finalMessages, // 합쳐진 메시지 전송
    });
    return result.data['fullText'];
  } on FirebaseFunctionsException catch (e) {
    print('Cloud Function Error: ${e.code} - ${e.message}');
    return '오류: AI 응답을 받아오지 못했습니다. (${e.message})';
  } catch (e) {
    print('Generic Error: $e');
    return '알 수 없는 오류가 발생했습니다.';
  }
}
