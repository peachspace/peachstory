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
  String? summary,
  List<SituationalImageStructStruct>? situationalImages, // 파라미터 타입 주의
) async {
  final functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('callAiProxy');

  // 1. 상황 이미지 목록을 텍스트로 변환 (프롬프트 조립)
  String situationRules = "";
  if (situationalImages != null && situationalImages.isNotEmpty) {
    situationRules = "\n[VISUAL DIRECTOR RULES]\n"
        "You have a list of 'Situational Images' that must be displayed when specific events occur.\n"
        "IF the user's action or the current story flow matches a 'Condition' below, you MUST insert the tag `[SHOW_IMAGE=\"Condition Text\"]` at the exact moment in your response.\n\n"
        "--- Condition List ---\n";

    for (var item in situationalImages) {
      // DataStruct 필드명(.condition)에 맞게 수정하세요
      situationRules += "- Condition: \"${item.condition}\"\n";
    }
    situationRules += "----------------------\n"
        "Example: \"As you open the door... [SHOW_IMAGE=\"Entering the dungeon\"] a cold wind blows.\"\n";
  }

  // 2. 시스템 프롬프트 강화 (기존 프롬프트 + 규칙 + 요약)
  String reinforcedSystemPrompt = """
${systemPrompt ?? "You are a professional story writer."}

$situationRules

[CRITICAL OUTPUT RULES]
1. Output MUST be a valid JSON array of scenes (e.g., [{"type": "narration", "content": "..."}]).
2. To show an image, use a scene object: {"type": "show_image", "condition": "EXACT_CONDITION_TEXT_FROM_LIST"}.
3. Do not change the condition text; copy it exactly.
""";

  if (summary != null && summary.isNotEmpty) {
    reinforcedSystemPrompt += "\n\n[STORY SUMMARY]\n$summary";
  }

  // 3. 메시지 병합
  List<dynamic> finalMessages = messages != null ? List.from(messages) : [];
  if (recentUserMessage != null && recentUserMessage.isNotEmpty) {
    finalMessages.add({
      'role': 'user',
      'content': recentUserMessage,
    });
  }

  // 4. 서버 호출
  try {
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'modelName': modelName,
      // 조립된 긴 프롬프트를 보냅니다. 서버는 내용이 뭔지 모르고 그냥 받아서 AI에게 넘깁니다.
      'systemPrompt': reinforcedSystemPrompt,
      'messages': finalMessages,
    });
    return result.data['fullText'];
  } on FirebaseFunctionsException catch (e) {
    return 'ERROR: ${e.message}';
  } catch (e) {
    return 'ERROR: 알 수 없는 오류 발생 ($e)';
  }
}
