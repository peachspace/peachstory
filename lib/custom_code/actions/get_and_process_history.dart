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

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<dynamic>> getAndProcessHistory(
  DocumentReference? storyChatRef,
) async {
  if (storyChatRef == null) {
    return [];
  }

  try {
    // 1. 쿼리 수정: 최신순(descending)으로 정렬 후 상위 20개 가져오기
    // 이렇게 해야 대화가 100개가 넘어도 '가장 최근 대화'를 가져옵니다.
    final messagesSnapshot = await storyChatRef
        .collection('storymessages')
        .orderBy('timestamp', descending: true) // [중요] 최신순 정렬
        .limit(20) // [중요] 최근 20개만 (토큰 절약)
        .get();

    if (messagesSnapshot.docs.isEmpty) {
      return [];
    }

    // 2. 가져온 데이터는 '최신 -> 과거' 순서이므로, '과거 -> 최신'으로 뒤집어야 AI가 이해합니다.
    final docs = messagesSnapshot.docs.toList().reversed;

    List<dynamic> formattedHistory = [];

    for (var doc in docs) {
      final docData = doc.data() as Map<String, dynamic>;

      String role;
      // 데이터 필드 안전하게 접근
      String content = docData['text']?.toString() ?? '';
      String type = docData['type']?.toString() ?? '';

      // 역할 매핑
      if (type == 'user') {
        role = 'user';
      } else {
        role = 'assistant'; // AI나 캐릭터의 대사는 assistant로 처리
      }

      // 내용이 있는 경우에만 추가
      if (content.isNotEmpty) {
        // AI 모델에 따라 'name' 필드를 지원하기도 하지만,
        // 기본적으로 role과 content가 가장 중요합니다.
        // 필요하다면 content 안에 "Speaker: 대사" 형태로 넣는 것도 방법입니다.
        formattedHistory.add({'role': role, 'content': content});
      }
    }

    return formattedHistory;
  } catch (e) {
    print('History Fetch Error: $e');
    return [];
  }
}
