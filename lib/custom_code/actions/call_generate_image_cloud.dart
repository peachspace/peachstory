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
    // 1. 리전 확인 (본인의 Firebase 리전과 일치해야 함!)
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable = functions.httpsCallable('generateReplicateImage');

    print('DEBUG: 호출 시작 Mode=$mode');

    final results = await callable.call(<String, dynamic>{
      'mode': mode,
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    final rawData = results.data;
    print('DEBUG: 서버 응답 $rawData');

    if (rawData is Map && rawData['imageUrl'] != null) {
      return rawData['imageUrl'].toString();
    }

    // 서버가 에러 메시지를 보낸 경우 확인
    if (rawData is Map && rawData['error'] != null) {
      print('DEBUG: 서버 로직 에러: ${rawData['error']}');
    }

    return null;
  } on FirebaseFunctionsException catch (e) {
    // ★ 여기서 404인지 확실히 알 수 있습니다.
    print('DEBUG: Firebase 함수 에러 (Code: ${e.code}): ${e.message}');
    return null;
  } catch (e) {
    print('DEBUG: 알 수 없는 에러 $e');
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
