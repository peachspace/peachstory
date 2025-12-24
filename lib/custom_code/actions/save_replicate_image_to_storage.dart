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

import 'package:http/http.dart' as http;
import '/backend/firebase_storage/storage.dart';

Future<String> saveReplicateImageToStorage(String imageUrl) async {
  try {
    // 1. 임시 주소에서 이미지 데이터 다운로드
    var response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      // 2. 파일명 자동 생성 (현재시간 기준)
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String storagePath = 'users/ai_generated/${timestamp}.png';

      // 3. 내 Firebase Storage에 업로드 (플러터플로우 내부 함수 사용)
      String? downloadUrl = await uploadData(storagePath, response.bodyBytes);

      if (downloadUrl != null) {
        return downloadUrl; // 성공! 영구 주소 반환
      }
    }
  } catch (e) {
    print('이미지 저장 실패: $e');
  }
  return imageUrl;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
