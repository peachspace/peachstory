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

// 함수 이름 앞에 async, 반환 타입에 Future<>가 자동으로 붙습니다.
Future<List<dynamic>> getAndProcessHistory(
  DocumentReference? storyChatRef,
) async {
  // 1. 함수 안에서 직접 데이터를 조회합니다.
  if (storyChatRef == null) {
    return [];
  }
  final messagesSnapshot = await storyChatRef
      .collection('storymessages')
      .orderBy('timestamp') // 시간 순으로 정렬
      .limit(30) // 최근 30개만 가져오기 (성능 최적화)
      .get();

  if (messagesSnapshot.docs.isEmpty) {
    return [];
  }

  // 2. AI가 원하는 형태로 데이터를 즉시 가공합니다.
  List<dynamic> formattedHistory = [];
  for (var doc in messagesSnapshot.docs) {
    final docData = doc.data() as Map<String, dynamic>;
    String role;
    String content = docData['text'] ?? '';

    if (docData['type'] == 'user') {
      role = 'user';
    } else {
      role = 'assistant';
    }

    if (content.isNotEmpty) {
      formattedHistory.add({'role': role, 'content': content});
    }
  }
  return formattedHistory;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
