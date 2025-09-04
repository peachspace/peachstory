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

Future<List<dynamic>> getCharacterHistoryAsJson(
    DocumentReference? chatRef) async {
  // 1. 입력값이 null이면 빈 리스트를 반환합니다.
  if (chatRef == null) {
    return [];
  }

  // 2. charactermessages 하위 컬렉션을 조회합니다.
  final messagesSnapshot = await chatRef
      .collection('charactermessages')
      .orderBy('timestamp')
      .limit(30) // 성능을 위해 최근 30개만 가져옵니다.
      .get();

  if (messagesSnapshot.docs.isEmpty) {
    return [];
  }

  // 3. AI가 원하는 형태로 데이터를 가공합니다.
  List<dynamic> formattedHistory = [];
  for (var doc in messagesSnapshot.docs) {
    final docData = doc.data() as Map<String, dynamic>;
    String role;
    String content = docData['text'] ?? '';

    // Firestore의 'type' 필드를 AI가 이해하는 'role'로 변환
    if (docData['type'] == 'user') {
      role = 'user';
    } else {
      // 'character', 'thought' 등 다른 모든 타입은 'assistant'로 취급
      role = 'assistant';
    }

    // 내용이 있는 경우에만, 그리고 필요한 필드만 골라서 추가합니다.
    if (content.isNotEmpty) {
      // ★핵심 수정★: timestamp 필드를 제외하고 새로운 Map을 만듭니다.
      formattedHistory.add({
        'role': role,
        'content': content,
      });
    }
  }
  return formattedHistory;
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
}
