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

import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<dynamic>> getPreviousChatHistory(
  DocumentReference chatRef,
  List<dynamic> currentHistory,
  int? limitCount,
) async {
  int limit = limitCount ?? 30;
  if (currentHistory.isEmpty) return [];

  try {
    // 1. 현재 리스트 중 가장 오래된(맨 처음) 메시지의 시간 찾기
    // (데이터가 Timestamp 타입인지 확인 후 변환)
    dynamic firstMsg = currentHistory.first;
    Timestamp? oldestTime;

    if (firstMsg['timestamp'] is Timestamp) {
      oldestTime = firstMsg['timestamp'];
    } else if (firstMsg['timestamp'] is String) {
      // 혹시 String으로 저장된 경우 처리 (DateTime parsing)
      oldestTime = Timestamp.fromDate(DateTime.parse(firstMsg['timestamp']));
    }

    if (oldestTime == null) return [];

    // 2. 그 시간보다 '더 이전(작은)' 메시지 쿼리
    QuerySnapshot querySnapshot = await chatRef
        .collection('storymessages')
        .where('timestamp', isLessThan: oldestTime)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    List<dynamic> messages = querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    // 3. 과거->현재 순으로 뒤집어서 반환 (이 리스트를 기존 리스트 앞에 붙일 예정)
    return messages.reversed.toList();
  } catch (e) {
    print('Error fetching previous history: $e');
    return [];
  }
}
