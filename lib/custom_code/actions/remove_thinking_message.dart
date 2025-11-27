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

Future<List<StoryChatMessageStructStruct>> removeThinkingMessage(
  List<StoryChatMessageStructStruct> currentMessages,
) async {
  // 리스트를 복사해서 수정 (안전)
  List<StoryChatMessageStructStruct> updatedList = List.from(currentMessages);

  // 'thinking' 타입인 녀석을 찾아서 모두 지웁니다.
  updatedList.removeWhere((msg) => msg.type == 'thinking');

  return updatedList;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
