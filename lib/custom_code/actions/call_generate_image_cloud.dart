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

import 'package:cloud_functions/cloud_functions.dart';

Future<String?> callGenerateImageCloud(
  String prompt,
  String? characterImageUrl,
) async {
  try {
    final functions = FirebaseFunctions.instance;
    // 함수 이름이 정확한지 확인하세요
    final callable = functions.httpsCallable('generateReplicateImage');

    final results = await callable.call(<String, dynamic>{
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    // ★ [핵심 수정] 어떤 데이터가 와도 뻗지 않도록 타입 체크를 합니다. ★
    final rawData = results.data;

    // 디버깅용: 콘솔에 뭐가 왔는지 찍어봅니다.
    print('Cloud Function Returned: $rawData');

    // Case 1: 새로운 방식 (Map으로 온 경우) - { success: true, imageUrl: "..." }
    if (rawData is Map) {
      if (rawData['imageUrl'] != null) {
        return rawData['imageUrl'].toString();
      }
    }
    // Case 2: 예전 방식 (String으로 온 경우) - "https://..."
    else if (rawData is String) {
      return rawData;
    }

    // 데이터가 없거나 이상하면 null 반환 (앱이 죽는 대신 조용히 넘어감)
    print('Warning: Unexpected data format');
    return null;
  } catch (e) {
    // 에러 발생 시 로그 출력
    print('Cloud Function Error: $e');
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
