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

Future<List<dynamic>> getRecentHistoryAsJson(
  DocumentReference chatRef,
  int? limitCount,
) async {
  // 1. 기본값 설정 (입력 안 하면 30개)
  int limit = limitCount ?? 30;

  try {
    // 2. 쿼리 실행: 'timestamp' 기준 내림차순(최신순)으로 N개만 가져오기
    QuerySnapshot querySnapshot = await chatRef
        .collection('storymessages') // 서브컬렉션 이름 확인 필요 (보통 storymessages)
        .orderBy('timestamp', descending: true) // 최신순 정렬
        .limit(limit) // 개수 제한
        .get();

    // 3. 데이터 변환
    List<dynamic> messages = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // 필요하다면 여기서 doc.id를 데이터에 추가할 수도 있음
      return data;
    }).toList();

    // 4. 순서 뒤집기 (중요!)
    // DB에서는 '최신순'으로 가져왔지만, 채팅창에는 '과거 -> 현재' 순서로 쌓여야 함
    // 따라서 리스트를 다시 뒤집어서 반환합니다.
    return messages.reversed.toList();
  } catch (e) {
    print('Error fetching recent history: $e');
    return [];
  }
}
