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

Future saveChatTurnToDB(
  List<dynamic> scenes,
  DocumentReference storyRef,
  List<BackgroundStructStruct> backgrounds,
  List<CharacterStructStruct> characters,
) async {
  // 1. Batch 초기화 (한 번에 저장하기 위함)
  final WriteBatch batch = FirebaseFirestore.instance.batch();

  // 'messages' 서브 컬렉션 참조 (컬렉션 이름이 다르면 수정하세요! 예: chat_history 등)
  final CollectionReference messagesRef = storyRef.collection('messages');

  // 현재 시간 (순서 보장을 위해 미세하게 시간차를 둠)
  DateTime now = DateTime.now();

  // 2. Loop: 장면(scene) 하나씩 처리
  for (var i = 0; i < scenes.length; i++) {
    final scene = scenes[i];
    final String type = scene['type'] ?? 'narration';
    final String content = scene['content'] ?? '';

    // 순서 보장을 위해 10ms씩 시간을 더함
    final timestamp = now.add(Duration(milliseconds: i * 10));

    // 저장할 데이터 맵 초기화
    Map<String, dynamic> messageData = {
      'created_at': timestamp,
      'type': type, // narration, dialogue, story_image
      'text': content, // 대사 또는 지문
      'role': 'assistant', // AI가 쓴 글임
      // 필요한 필드가 더 있다면 여기에 추가 (예: is_read, user_name 등)
    };

    // A. 이미지 처리 (show_image)
    if (type == 'show_image') {
      final String condition = scene['condition'] ?? '';
      String foundImageUrl = '';

      // (1) 배경 리스트 검색
      for (final bg in backgrounds) {
        if (bg.placeName.trim() == condition.trim()) {
          foundImageUrl = bg.imageUrl;
          break;
        }
      }

      // (2) 못 찾았으면 캐릭터 상황 리스트 검색
      if (foundImageUrl.isEmpty) {
        for (final char in characters) {
          for (final sit in char.situationImages) {
            if (sit.condition.trim() == condition.trim()) {
              foundImageUrl = sit.imageUrl;
              break;
            }
          }
          if (foundImageUrl.isNotEmpty) break;
        }
      }

      // 이미지를 찾았을 때만 저장 (못 찾으면 저장 안 함 or 에러 로그)
      if (foundImageUrl.isNotEmpty) {
        messageData['type'] = 'story_image';
        messageData['story_image_url'] = foundImageUrl; // DB 필드명 확인 필요
        messageData['text'] = ''; // 이미지는 텍스트 없음

        // 새 문서 ID 생성 및 Batch 추가
        final newDocRef = messagesRef.doc();
        batch.set(newDocRef, messageData);
      }
    }
    // B. 대화(dialogue) 처리
    else if (type == 'dialogue') {
      messageData['speaker_name'] = scene['speaker'] ?? '';
      messageData['action_text'] = scene['action'] ?? '';
      // 캐릭터 이미지 찾기 로직이 필요하다면 여기서 추가 가능하지만,
      // 보통은 speaker_name만 저장하고 보여줄 때 앱에서 매칭함.

      final newDocRef = messagesRef.doc();
      batch.set(newDocRef, messageData);
    }
    // C. 내레이션(narration) 처리
    else {
      // type은 이미 narration으로 설정됨
      final newDocRef = messagesRef.doc();
      batch.set(newDocRef, messageData);
    }
  }

  // 3. 최종 저장 (Commit)
  await batch.commit();
}
