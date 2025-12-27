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

Future<String> callGenerateImageCloud(
  String prompt,
  String? characterImageUrl,
) async {
  try {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('generateReplicateImage');

    // 서버 호출
    final results = await callable.call(<String, dynamic>{
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    final rawData = results.data;

    // ★ [핵심 수정] 서버가 Map(상자)을 주든 String(글자)을 주든 알아서 처리하는 코드
    // 이 부분이 없어서 그동안 앱이 멈췄던 것입니다.

    // 1. 서버가 { "success": true, "imageUrl": "..." } 형태(Map)로 보낸 경우
    if (rawData is Map) {
      if (rawData['imageUrl'] != null) {
        return rawData['imageUrl'].toString(); // 성공: URL만 쏙 빼서 반환
      } else {
        return "ERROR: ${rawData['error'] ?? '서버 에러(내용 없음)'}"; // 실패: 에러 내용 반환
      }
    }
    // 2. 서버가 "https://..." (String)으로 보낸 경우 (구버전 호환)
    else if (rawData is String) {
      return rawData;
    }

    return "ERROR: 데이터 형식이 올바르지 않습니다. (${rawData.runtimeType})";
  } catch (e) {
    // 앱이 죽지 않고 에러 내용을 화면에 표시하도록 함
    return "ERROR: $e";
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
