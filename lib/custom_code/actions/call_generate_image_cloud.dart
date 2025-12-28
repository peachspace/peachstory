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

import 'index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:cloud_functions/cloud_functions.dart';

Future<String?> callGenerateImageCloud(
  String mode, // "character" 또는 "situation" (새로 추가됨)
  String prompt,
  String? characterImageUrl,
) async {
  try {
    // 1. 리전 설정 (필수)
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable = functions.httpsCallable('generateReplicateImage');

    print('DEBUG: 호출 시작 Mode=$mode');

    // 2. 서버 호출 (mode 전달)
    final results = await callable.call(<String, dynamic>{
      'mode': mode,
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    final rawData = results.data;
    print('DEBUG: 서버 응답 $rawData');

    // 3. 응답 파싱 (안전하게 URL 추출)
    if (rawData is Map) {
      if (rawData['imageUrl'] != null) {
        return rawData['imageUrl'].toString();
      }
    }

    return null; // 실패 시 null 반환 (앱 멈춤 방지)
  } catch (e) {
    print('DEBUG: 에러 발생 $e');
    return null; // 에러 시 null 반환
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
