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
  // [디버그 1] 함수 시작 알림
  print('================= [DEBUG START] =================');
  print('1. 입력된 프롬프트: $prompt');
  print('2. 입력된 캐릭터 이미지: $characterImageUrl');

  try {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('generateReplicateImage');

    print('3. 클라우드 펑션 호출 시작...');

    final results = await callable.call(<String, dynamic>{
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    // [디버그 2] 서버 응답 확인
    final rawData = results.data;
    print('4. 서버 응답 도착!');
    print('   - 데이터 타입: ${rawData.runtimeType}');
    print('   - 데이터 내용: $rawData');

    // 데이터 파싱 (안전 장치 포함)
    String? finalUrl;

    if (rawData is Map) {
      print('5. 데이터가 Map(상자) 형태입니다.');
      if (rawData.containsKey('imageUrl')) {
        finalUrl = rawData['imageUrl']?.toString();
        print('   - imageUrl 발견: $finalUrl');
      } else {
        print('   - ⚠️ 경고: Map 안에 imageUrl 키가 없습니다!');
      }
    } else if (rawData is String) {
      print('5. 데이터가 String(글자) 형태입니다.');
      finalUrl = rawData;
    } else {
      print('5. ⚠️ 알 수 없는 데이터 타입입니다.');
    }

    if (finalUrl != null && finalUrl.isNotEmpty) {
      print('6. 최종 반환할 URL: $finalUrl');
      print('================= [DEBUG SUCCESS] =================');
      return finalUrl;
    } else {
      print('6. ⚠️ 유효한 URL을 찾지 못했습니다.');
      return null;
    }
  } catch (e, stackTrace) {
    // [디버그 3] 에러 발생 시 상세 내용 출력
    print('xxxxxxxxx [DEBUG ERROR] xxxxxxxxx');
    print('에러 내용: $e');
    print('스택 트레이스: $stackTrace');
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

    // 앱이 멈추지 않게 null 반환
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
