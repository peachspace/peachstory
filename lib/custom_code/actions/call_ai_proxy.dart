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
  String? systemPrompt, // buildStoryPrompt의 결과물 (여기에 모든 규칙과 요약이 포함됨)
  List<dynamic>? messages, // 과거 대화 기록 (JSON List)
  String? recentUserMessage, // 방금 유저가 입력한 말 (또는 getNextPhaseCommand)
) async {
  final functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('callAiProxy');

  // 1. 메시지 리스트 준비
  // messages가 null이면 빈 리스트로 시작
  List<dynamic> finalMessages = messages != null ? List.from(messages) : [];

  // 2. 최근 유저 메시지 병합
  // (recentUserMessage가 있으면 messages 리스트의 맨 끝에 'user' 역할로 추가)
  // 이 부분이 '현재' 시점의 대화를 담당합니다.
  if (recentUserMessage != null && recentUserMessage.isNotEmpty) {
    finalMessages.add({
      'role': 'user',
      'content': recentUserMessage,
    });
  }

  // 3. 서버(Cloud Function) 호출
  // 복잡한 규칙 조립 로직은 모두 제거했습니다. buildStoryPrompt를 믿고 그대로 보냅니다.
  try {
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'modelName': modelName ?? 'gpt-4o', // 모델명이 없으면 기본값 (필요시 수정)
      'systemPrompt': systemPrompt, // 완성된 프롬프트 전달
      'messages': finalMessages, // 과거+현재 대화 전달
    });

    // Cloud Function에서 return { fullText: "..." } 형태로 준다고 가정
    return result.data['fullText'];
  } on FirebaseFunctionsException catch (e) {
    return 'ERROR: Firebase Functions 오류 - ${e.message}';
  } catch (e) {
    return 'ERROR: 알 수 없는 오류 발생 ($e)';
  }
}
