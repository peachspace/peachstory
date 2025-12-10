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

import 'index.dart'; // Imports other custom actions

import 'package:cloud_functions/cloud_functions.dart';

Future<String?> callAiProxy(
  String? modelName,
  String? systemPrompt,
  List<dynamic>? messages,
  String? recentUserMessage,
  String? summary,
  List<SituationalImageStructStruct>? situationalImages, // [추가됨] 상황 이미지 리스트
) async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('callAiProxy');

  // 1. 상황 이미지 목록을 텍스트로 변환
  String situationRules = "";
  if (situationalImages != null && situationalImages.isNotEmpty) {
    situationRules = "\n[VISUAL DIRECTOR RULES]\n"
        "You have a list of 'Situational Images' that must be displayed when specific events occur.\n"
        "IF the user's action or the current story flow matches a 'Condition' below, you MUST insert the tag `[SHOW_IMAGE=\"Condition Text\"]` at the exact moment in your response.\n\n"
        "--- Condition List ---\n";

    for (var item in situationalImages) {
      // 조건 텍스트를 정확히 매칭하기 위해 리스트를 제공
      situationRules += "- Condition: \"${item.condition}\"\n";
    }
    situationRules += "----------------------\n"
        "Example: \"As you open the door... [SHOW_IMAGE=\"Entering the dungeon\"] a cold wind blows.\"\n";
  }

  // 2. 시스템 프롬프트 강화
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

  // ... (이하 메시지 병합 및 호출 로직은 기존과 동일)
  List<dynamic> finalMessages = messages != null ? List.from(messages) : [];
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
