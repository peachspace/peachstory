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

Future<dynamic> callGenerateImageCloud(
  String mode,
  String prompt,
  String? referenceImageUrl, // [변경] 서버 키와 일치시킴 (기존 characterImageUrl)
  String? poseImageUrl, // [신규] 상황 모드용 포즈 이미지
  int? seed,
  String? basePrompt,
  String style, // [신규] 스타일 (필수!)
) async {
  try {
    print('📌 [Image Gen] Mode: $mode / Style: $style / Seed: $seed');

    // [중요] 타임아웃 540초 (9분) 설정 - 고화질 생성 대기용
    final options = HttpsCallableOptions(timeout: const Duration(seconds: 540));

    final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable('generateReplicateImage', options: options);

    final results = await callable.call(<String, dynamic>{
      'mode': mode,
      'style': style, // [추가] 서버 v16.0 필수 파라미터
      'prompt': prompt,
      'basePrompt': basePrompt,
      'referenceImageUrl': referenceImageUrl, // [수정] 키 이름 서버와 일치
      'poseImageUrl': poseImageUrl, // [추가]
      'seed': seed,
    });

    final rawData = results.data;

    // 결과값 검증 및 반환
    if (rawData is Map) {
      // 서버에서 명시적 에러를 보낸 경우
      if (rawData['success'] == false) {
        return {
          'success': false,
          'error': rawData['error'] ?? 'Unknown server error'
        };
      }
      // 성공 시 데이터 반환 ({success: true, imageUrl: ..., seed: ...})
      return rawData;
    }

    return {'success': false, 'error': 'Invalid response format from server'};
  } catch (e) {
    // 네트워크 에러, 타임아웃 등 예외 처리
    return {'success': false, 'error': e.toString()};
  }
}
