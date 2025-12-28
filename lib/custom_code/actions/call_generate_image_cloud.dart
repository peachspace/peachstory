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

Future<String?> callGenerateImageCloud(
  String prompt,
  String? characterImageUrl,
) async {
  try {
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('generateReplicateImage');

    final results = await callable.call(<String, dynamic>{
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
    });

    final rawData = results.data;

    // 성공한 경우 (URL인 경우)에만 반환
    if (rawData is Map && rawData['imageUrl'] != null) {
      return rawData['imageUrl'].toString();
    }
    if (rawData is String && rawData.startsWith('http')) {
      return rawData;
    }

    // ★ 실패하면 그냥 null 반환 (복잡한 메시지 X)
    return null;
  } catch (e) {
    // ★ 에러 나도 그냥 null 반환
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
