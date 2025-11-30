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
  if (storyChatRef == null) {
    return [];
  }

  try {
    // [핵심] 최근 20개 메시지만 가져오기 (orderBy desc + limit)
    final messagesSnapshot = await storyChatRef
        .collection('storymessages')
        .orderBy('timestamp', descending: true) // 최신순 정렬
        .limit(20) // 최근 20개만
        .get();

    if (messagesSnapshot.docs.isEmpty) {
      return [];
    }

    // 가져온 데이터를 다시 시간순(과거->미래)으로 뒤집어야 AI가 이해함
    final docs = messagesSnapshot.docs.toList().reversed;

    List<dynamic> formattedHistory = [];
    for (var doc in docs) {
      final data = doc.data();
      String role = (data['type'] == 'user') ? 'user' : 'assistant';
      String content = data['text'] ?? '';

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
