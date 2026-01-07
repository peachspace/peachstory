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
  List<SituationalImageStructStruct>? situationalImages,
) async {
  final functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('callAiProxy');

  // 1. 상황 이미지 규칙 생성
  String situationRules = "";
  if (situationalImages != null && situationalImages.isNotEmpty) {
    situationRules = "\n[VISUAL DIRECTOR RULES]\n"
        "You have a list of 'Situational Images' that must be displayed when specific events occur.\n"
        "IF the user's action or the current story flow matches a 'Condition' below, you MUST insert the tag `[SHOW_IMAGE=\"Condition Text\"]` at the exact moment in your response.\n\n"
        "--- Condition List ---\n";

    for (var item in situationalImages) {
      situationRules += "- Condition: \"${item.condition}\"\n";
    }
    situationRules += "----------------------\n"
        "Example: \"As you open the door... [SHOW_IMAGE=\"Entering the dungeon\"] a cold wind blows.\"\n";
  }

  // ★ [추가] 2. 감정 연기 규칙 (Emotion Acting Rules)
  // AI가 대사 칠 때 감정을 자동으로 인식해서 ACTION 태그에 넣도록 지시합니다.
  String emotionRules = """
[EMOTION ACTING RULES]
When a character speaks, you MUST infer their emotion from the context and include it in the `ACTION` attribute of the `[DIALOGUE]` tag.
- Available Emotions: "무감정" (neutral/default), "기쁨" (joy), "슬픔" (sadness), "화남" (anger), "놀람" (surprise), "두려움" (fear), "혐오" (disgust), "설렘" (excited), "사랑" (love), "부끄러움" (shy), "당황" (flustered).
- If the character is calm or has no specific emotion, use "무감정".
- Example: [DIALOGUE SPEAKER="Hero" ACTION="화남"]Don't you dare touch that![/DIALOGUE]
- Example: [DIALOGUE SPEAKER="Heroine" ACTION="무감정"]The weather is nice today.[/DIALOGUE]
""";

  // 3. 시스템 프롬프트 강화 (기존 + 상황 규칙 + 감정 규칙 + 출력 형식)
  String reinforcedSystemPrompt = """
${systemPrompt ?? "You are a professional story writer."}

$situationRules

$emotionRules

[CRITICAL OUTPUT RULES]
1. Output MUST be a valid JSON array of scenes (e.g., [{"type": "narration", "content": "..."}]).
2. To show an image, use a scene object: {"type": "show_image", "condition": "EXACT_CONDITION_TEXT_FROM_LIST"}.
3. For dialogues, use: {"type": "dialogue", "speaker": "Name", "action": "Emotion_Keyword", "content": "Speech"}.
4. Do not change the condition text; copy it exactly.
""";

  if (summary != null && summary.isNotEmpty) {
    reinforcedSystemPrompt += "\n\n[STORY SUMMARY]\n$summary";
  }

  // 4. 메시지 병합
  List<dynamic> finalMessages = messages != null ? List.from(messages) : [];
  if (recentUserMessage != null && recentUserMessage.isNotEmpty) {
    finalMessages.add({
      'role': 'user',
      'content': recentUserMessage,
    });
  }

  // 5. 서버 호출
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
    return 'ERROR: 알 수 없는 오류 발생 ($e)';
  }
}
