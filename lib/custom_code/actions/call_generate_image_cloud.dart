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

import 'package:cloud_functions/cloud_functions.dart';

// ★ 수정됨: 인자값(Arguments)에 characterImageUrl 추가 필요!
Future<String?> callGenerateImageCloud(
  String prompt,
  String? characterImageUrl, // [새로 추가된 부분] 캐릭터 사진 URL을 받습니다.
) async {
  try {
    final functions = FirebaseFunctions.instance;

    // Cloud Function 이름 호출
    final callable = functions.httpsCallable('generateReplicateImage');

    // ★ 수정됨: prompt뿐만 아니라 characterImageUrl도 같이 보냅니다.
    final results = await callable.call(<String, dynamic>{
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    // 결과 처리
    final data = results.data as Map<String, dynamic>;
    return data['imageUrl'] as String?;
  } catch (e) {
    print('Cloud Function Error: $e');
    // 에러 발생 시 로그 출력
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
