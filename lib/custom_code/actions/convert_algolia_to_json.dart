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

Future<List<dynamic>> convertAlgoliaToJson(
  List<dynamic>? algoliaRecords,
) async {
  // Algolia 검색 결과(실질적으로 List<JSON>)를 그대로 반환합니다.
  // 이 액션은 FlutterFlow의 타입 체커를 통과하기 위한 명시적인 변환 단계 역할을 합니다.
  if (algoliaRecords == null) {
    return [];
  }
  return algoliaRecords.map((r) => r).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
