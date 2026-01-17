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

import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<StoryChatMessageStructStruct>> processAndSaveChatTurn(
  List<dynamic> scenes,
  DocumentReference storyDocRef,
  List<BackgroundStructStruct>? backgrounds,
  List<CharacterStructStruct>? characters,
) async {
  // 1. 결과 반환용 리스트 (화면 표시용)
  List<StoryChatMessageStructStruct> localMessages = [];

  // 2. Firestore 배치 생성 (한번에 저장하기 위함)
  final batch = FirebaseFirestore.instance.batch();
  final CollectionReference messagesRef =
      storyDocRef.collection('storymessages');

  for (var scene in scenes) {
    if (scene is Map) {
      // --- 데이터 추출 ---
      String type = scene['type']?.toString() ?? 'narration';
      String content = scene['content']?.toString() ?? '';
      String speaker = scene['speaker']?.toString() ?? '';
      String action = scene['action']?.toString() ?? '';
      String condition = scene['condition']?.toString() ?? '';
      String imageUrl = '';

      // --- 이미지 URL 찾기 로직 ---
      if (type == 'show_image' || type == 'story_image') {
        type = 'story_image';

        // 1. 배경에서 찾기
        if (backgrounds != null) {
          for (var bg in backgrounds) {
            if (bg.placeName == condition) {
              imageUrl = bg.imageUrl;
              break;
            }
          }
        }
        // 2. 배경에 없으면 캐릭터에서 찾기
        if (imageUrl.isEmpty && characters != null) {
          for (var char in characters) {
            for (var sit in char.situationImages) {
              if (sit.condition == condition) {
                imageUrl = sit.imageUrl;
                break;
              }
            }
            if (imageUrl.isNotEmpty) break;
          }
        }
      }

      // --- A. Firestore 저장용 데이터 준비 ---
      final newDocRef = messagesRef.doc(); // 새 문서 ID 생성
      final messageData = createStorymessagesRecordData(
        text: content,
        type: type,
        speakerName: speaker,
        actionText: action,
        storyImageUrl: imageUrl,
        timestamp: DateTime.now(), // [수정됨] 현재 시간 사용
        // role: 'ai',  <-- [삭제됨] 이 부분이 에러 원인이었으므로 제거했습니다.
      );
      batch.set(newDocRef, messageData);

      // --- B. 화면 표시용 Struct 생성 ---
      localMessages.add(createStoryChatMessageStructStruct(
        text: content,
        type: type,
        speakerName: speaker,
        actionText: action,
        storyImageUrl: imageUrl,
        timestamp: DateTime.now(), // 현재 시간
      ));
    }
  }

  // 3. DB에 일괄 저장 실행 (await)
  await batch.commit();

  // 4. 화면용 리스트 반환
  return localMessages;
}
