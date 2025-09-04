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

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<dynamic>> getHistoryAsJson(DocumentReference? chatRef) async {
  if (chatRef == null) {
    return [];
  }
  // 👇 컬렉션 이름을 'storymessages'로 수정
  final messagesSnapshot = await chatRef
      .collection('storymessages')
      .orderBy('timestamp')
      .limit(30)
      .get();

  if (messagesSnapshot.docs.isEmpty) {
    return [];
  }

  return messagesSnapshot.docs.map((doc) => doc.data() ?? {}).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
