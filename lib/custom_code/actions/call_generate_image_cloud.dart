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

import 'package:cloud_functions/cloud_functions.dart'; // 패키지 확인 필요

Future<String?> callGenerateImageCloud(
  String mode,
  String prompt,
  String? characterImageUrl,
) async {
  try {
    // 1. 타임아웃을 120초(2분)로 설정하는 옵션 추가
    final options = HttpsCallableOptions(timeout: const Duration(seconds: 120));

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

    // 2. 옵션을 적용해서 함수 호출 객체 생성
    final callable =
        functions.httpsCallable('generateReplicateImage', options: options);

    print('DEBUG: 호출 시작 Mode=$mode');

    final results = await callable.call(<String, dynamic>{
      'mode': mode,
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    final rawData = results.data;
    // ... (나머지 코드는 기존과 동일)
    if (rawData is Map && rawData['imageUrl'] != null) {
      return rawData['imageUrl'].toString();
    }
    return null;
  } catch (e) {
    print('DEBUG: 에러 발생 $e');
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
