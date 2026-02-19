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

import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<dynamic>> getAndProcessHistory(
  DocumentReference? storyChatRef,
) async {
  String _sanitizeAttr(String raw) =>
      raw.replaceAll('"', '').replaceAll('\n', ' ').trim();

  String _buildAssistantTaggedContent(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().trim();
    final text = (data['text'] ?? '').toString().trim();
    final speaker = _sanitizeAttr((data['speakerName'] ?? '').toString());
    final action = _sanitizeAttr((data['actionText'] ?? '').toString());

    if (text.isEmpty || text == '생각 중') return '';

    if (type == 'dialogue') {
      final safeSpeaker = speaker.isEmpty ? '인물' : speaker;
      if (action.isNotEmpty) {
        return '[DIALOGUE SPEAKER="$safeSpeaker" ACTION="$action"]$text[/DIALOGUE]';
      }
      return '[DIALOGUE SPEAKER="$safeSpeaker"]$text[/DIALOGUE]';
    }

    return '[NARRATION]$text[/NARRATION]';
  }

  if (storyChatRef == null) {
    return [];
  }

  try {
    // [핵심] 최근 20개 메시지만 가져오기 (orderBy desc + limit)
    final messagesSnapshot = await storyChatRef
        .collection('storymessages')
        .orderBy('timestamp', descending: true) // 최신순 정렬
        .limit(30) // 최근 20개만
        .get();

    if (messagesSnapshot.docs.isEmpty) {
      return [];
    }

    // 가져온 데이터를 다시 시간순(과거->미래)으로 뒤집어야 AI가 이해함
    final docs = messagesSnapshot.docs.toList().reversed;

    final List<dynamic> formattedHistory = [];
    for (var doc in docs) {
      final data = doc.data();
      final type = (data['type'] ?? '').toString();
      final role = type == 'user' ? 'user' : 'assistant';
      final content = role == 'user'
          ? (data['text'] ?? '').toString().trim()
          : _buildAssistantTaggedContent(data);

      // 내용이 없거나 '생각 중' 같은 메시지는 제외
      if (content.isNotEmpty && content != '생각 중') {
        formattedHistory.add({
          'role': role,
          'content': content,
        });
      }
    }
    return formattedHistory;
  } catch (e) {
    print('History Error: $e');
    return [];
  }
}
