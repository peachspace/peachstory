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

Future<String> callGenerateImageCloud(
  // String? 이 아니라 String으로 변경 (강제)
  String prompt,
  String? characterImageUrl,
) async {
  try {
    print('>>> [DEBUG] 클라우드 펑션 호출 시작');

    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('generateReplicateImage');

    final results = await callable.call(<String, dynamic>{
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    final rawData = results.data;
    print('>>> [DEBUG] 서버 응답: $rawData');

    // 1. 서버가 { "success": true, "imageUrl": "..." } (Map)을 보낸 경우
    if (rawData is Map) {
      if (rawData['imageUrl'] != null) {
        return rawData['imageUrl'].toString(); // 성공 주소 반환
      } else {
        return "ERROR: imageUrl missing in response"; // 에러 메시지 반환
      }
    }
    // 2. 서버가 "https://..." (String)을 보낸 경우
    else if (rawData is String) {
      return rawData;
    }

    return "ERROR: Unknown Data Type (${rawData.runtimeType})";
  } catch (e) {
    print('>>> [DEBUG] 에러 발생: $e');
    // 앱이 죽지 않게 에러 내용을 글자로 반환합니다.
    return "ERROR: $e";
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
