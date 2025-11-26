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
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> callAiSummaryAction(
  DocumentReference? storyChatRef,
) async {
  if (storyChatRef == null) return '오류: 채팅방 참조 없음';

  // 1. [수정] 기존 요약본 가져오기 (누적을 위해)
  String previousSummary = '';
  try {
    final chatDoc = await storyChatRef.get();
    if (chatDoc.exists) {
      // 'summary' 필드명을 실제 DB 필드명과 일치시켜야 합니다.
      final data = chatDoc.data() as Map<String, dynamic>;
      previousSummary = data['summary'] ?? '';
    }
  } catch (e) {
    print('기존 요약 불러오기 실패: $e');
  }

  // 2. 최근 채팅 내역 조회 (기존 코드 유지)
  final messagesSnapshot = await storyChatRef
      .collection('storymessages')
      .orderBy('timestamp', descending: true)
      .limit(20) // 20개 정도가 적당
      .get();

  if (messagesSnapshot.docs.isEmpty) return previousSummary; // 새 대화 없으면 기존꺼 반환

  final buffer = StringBuffer();
  for (var doc in messagesSnapshot.docs.reversed) {
    final data = doc.data() as Map<String, dynamic>;
    String role = (data['type'] == 'user') ? 'User' : 'AI';
    String content = data['text'] ?? '';
    if (content.isNotEmpty) {
      buffer.writeln('$role: $content');
    }
  }

  String newConversation = buffer.toString();

  // 3. [수정] 프롬프트에 '기존 요약' + '새 대화'를 같이 줍니다.
  String systemPrompt = '''
You are a professional story summarizer.
Your task is to update the "Current Story Summary" by incorporating the "Recent Conversation".

[Current Story Summary]:
$previousSummary

[Recent Conversation]:
$newConversation

[Instructions]
1. Combine the past context with new events.
2. Keep it concise but retain key plot points, user decisions, and character relationship changes.
3. Write in Korean.
4. Output ONLY the updated summary text.
''';

  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('callAiSummary');

  try {
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'summaryPrompt': systemPrompt,
    });

    if (result.data != null &&
        result.data['choices'] != null &&
        result.data['choices'].isNotEmpty) {
      return result.data['choices'][0]['message']['content'];
    }
    return previousSummary; // 실패시 기존 요약 유지
  } catch (e) {
    print('요약 에러: $e');
    return previousSummary;
  }
}
