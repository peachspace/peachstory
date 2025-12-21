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

Future<String?> callGenerateImageCloud(String prompt) async {
  try {
    final functions = FirebaseFunctions.instance;

    // 2. 함수 이름('generateReplicateImage')으로 호출할 준비를 합니다.
    final callable = functions.httpsCallable('generateReplicateImage');

    // 3. 실행! (프롬프트를 전달)
    final results = await callable.call(<String, dynamic>{
      'prompt': prompt,
    });

    // 4. 결과에서 이미지 URL 꺼내기
    // (index.ts에서 return { imageUrl: ... } 라고 줬으니까요)
    final data = results.data as Map<String, dynamic>;
    return data['imageUrl'] as String?;
  } catch (e) {
    print('Cloud Function Error: $e');
    // 에러가 나면 null을 반환
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
