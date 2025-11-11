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

// 3가지 핵심 라이브러리를 import 합니다.
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/backend.dart'; // StorymessagesRecord를 사용하기 위해

Future<String?> callAiSummaryAction(
  DocumentReference? storyChatRef, // 1. 이제 채팅방 참조를 직접 받습니다.
) async {
  // 1. 채팅방 참조가 없으면 오류
  if (storyChatRef == null) {
    print('callAiSummaryAction Error: storyChatRef is null');
    return '오류: 채팅방 참조가 없습니다.';
  }

  // 2. 채팅 내역(storymessages)을 직접 조회합니다.
  final messagesSnapshot = await storyChatRef
      .collection('storymessages')
      .orderBy('timestamp', descending: true) // 최신순으로
      .limit(30) // 최근 30개만
      .get();

  if (messagesSnapshot.docs.isEmpty) {
    return null; // 요약할 내용이 없음
  }

  // 3. 채팅 내역을 AI가 알아볼 수 있는 하나의 문자열로 변환합니다.
  final buffer = StringBuffer();
  // (최신순으로 가져왔으므로, 시간 순서를 맞추기 위해 .reversed 사용)
  for (var doc in messagesSnapshot.docs.reversed) {
    final data = doc.data() as Map<String, dynamic>;
    String role;
    String content = data['text'] ?? '';

    if (data['type'] == 'user') {
      role = 'User';
    } else {
      role = 'Assistant'; // narration, dialogue 등 모두 Assistant로 처리
    }

    if (content.isNotEmpty) {
      buffer.writeln('$role: $content');
    }
  }

  String formattedHistoryString = buffer.toString();

  // 4. 님이 사용하던 '요약 지시 프롬프트'와 '채팅 내역'을 합칩니다.
  const String systemPrompt = '''
You are a helpful text summarization assistant. The following conversation must be summarized into a single, concise paragraph from the character's point of view. This summary will serve as a memory for the character to continue the conversation later. Just provide the summary text itself, without any introductory phrases.

Here is the conversation to summarize:
''';

  final String finalPrompt = systemPrompt + formattedHistoryString;

  // 5. Cloud Function('callAiSummary')을 호출합니다.
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('callAiSummary');
  try {
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'summaryPrompt': finalPrompt,
    });

    // 6. Cloud Function이 Groq의 원본 응답(Map)을 반환하므로,
    //    여기서 채팅 요약 텍스트만 추출합니다.
    if (result.data != null &&
        result.data['choices'] != null &&
        result.data['choices'].isNotEmpty) {
      return result.data['choices'][0]['message']['content'];
    }
    return null; // 응답이 비어있을 경우
  } on FirebaseFunctionsException catch (e) {
    print('Cloud Function Error: ${e.code} - ${e.message}');
    return '오류: 요약에 실패했습니다. (${e.message})';
  } catch (e) {
    print('Generic Error: $e');
    return '알 수 없는 오류가 발생했습니다.';
  }
}
