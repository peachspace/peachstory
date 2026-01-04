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

// [Helper] URL 형태를 파악하는 내부 함수 (로그용)
String _urlKind(String? s) {
  if (s == null) return 'null';
  final t = s.trim();
  if (t.isEmpty) return 'empty';
  if (t.startsWith('http://') || t.startsWith('https://')) return 'http(s)';
  if (t.startsWith('gs://')) return 'gs://';
  if (t.contains('/') && !t.contains(' ')) return 'storage-path?';
  return 'unknown';
}

Future<String?> callGenerateImageCloud(
  String mode,
  String prompt,
  String? characterImageUrl,
) async {
  try {
    // 1. 타임아웃 120초(2분) 설정
    final options = HttpsCallableOptions(timeout: const Duration(seconds: 120));

    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable =
        functions.httpsCallable('generateReplicateImage', options: options);

    // 2. [DEBUG] 백엔드 호출 전 데이터 검증 로그
    // 이 로그를 통해 프론트엔드가 '기쁨'만 보냈는지, '기쁨 + 텍스트'를 보냈는지,
    // 이미지 URL이 gs:// 인지 http:// 인지 확실히 알 수 있습니다.
    print('TRACE[callGenerateImageCloud:req] mode=$mode');
    print(
        'TRACE[callGenerateImageCloud:req] prompt="${prompt.length > 200 ? prompt.substring(0, 200) + '...' : prompt}"');
    print(
        'TRACE[callGenerateImageCloud:req] imgKind=${_urlKind(characterImageUrl)}');
    print(
        'TRACE[callGenerateImageCloud:req] characterImageUrl=$characterImageUrl');

    // 3. Cloud Function 호출
    final results = await callable.call(<String, dynamic>{
      'mode': mode,
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    final rawData = results.data;

    // 4. [DEBUG] 응답 로그
    print('TRACE[callGenerateImageCloud:resp] raw=$rawData');

    if (rawData is Map) {
      if (rawData['success'] == false) {
        print('TRACE[callGenerateImageCloud:error] ${rawData['error']}');
      }
      if (rawData['imageUrl'] != null) {
        return rawData['imageUrl'].toString();
      }
    }
    return null;
  } catch (e) {
    print('TRACE[callGenerateImageCloud:exception] $e');
    return null;
  }
}
