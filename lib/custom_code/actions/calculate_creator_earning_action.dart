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

Future<int> calculateCreatorEarningAction(String? modelName) async {
  // 모델별 크리에이터 수익금 계산 로직을 여기에 직접 구현합니다.
  // (getPointCost 함수를 참고하여 포인트 차감액의 일정 비율이나 고정값을 설정하세요)

  if (modelName == null || modelName.isEmpty) {
    return 10; // 모델명이 없을 경우 기본 수익
  }

  switch (modelName) {
    // OpenAI
    case 'gpt-4o':
      return 50; // 예: gpt-4o 사용 시 크리에이터에게 50포인트 지급

    // Anthropic
    case 'claude-3-sonnet-20240229':
      return 80;
    case 'claude-3-haiku-20240307':
      return 10;

    // Google
    case 'gemini-2.5-pro':
      return 50;
    case 'gemini-2.5-flash':
      return 10;

    // Groq / Llama
    case 'gemma-2-9b-instruct':
      return 5;
    case 'llama3-70b-8192':
      return 5;

    default:
      return 10; // 목록에 없는 모델은 기본값
  }
}
// and then add the boilerplate code using the green button on the right!
