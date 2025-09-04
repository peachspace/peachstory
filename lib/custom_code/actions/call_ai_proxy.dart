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

Future<String?> callAiProxy(
  String? modelName,
  String? systemPrompt,
  List<dynamic>? messages,
) async {
  // 배포한 Cloud Function의 이름을 정확히 입력합니다.
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('callAiProxy');
  try {
    // Cloud Function에 파라미터를 전달하며 호출합니다.
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'modelName': modelName,
      'systemPrompt': systemPrompt,
      'messages': messages,
    });
    // Cloud Function이 반환한 'fullText'를 다시 반환합니다.
    return result.data['fullText'];
  } on FirebaseFunctionsException catch (e) {
    // Cloud Function 관련 오류 처리
    print('Cloud Function Error: ${e.code} - ${e.message}');
    return '오류: AI 응답을 받아오지 못했습니다. (${e.message})';
  } catch (e) {
    // 기타 오류 처리
    print('Generic Error: $e');
    return '알 수 없는 오류가 발생했습니다.';
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
