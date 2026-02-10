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
  List<EventstructStruct>? events, // ✅ 추가
) async {
  // 1) 화면 표시용
  List<StoryChatMessageStructStruct> localMessages = [];

  // 2) 배치
  final batch = FirebaseFirestore.instance.batch();
  final CollectionReference messagesRef =
      storyDocRef.collection('storymessages');

  // ✅ 이벤트 빠른 검색용 맵(태그 -> url)
  final eventMap = <String, String>{};
  if (events != null) {
    for (final ev in events) {
      final d = ev as dynamic;
      final tag = (d.event ?? '').toString().trim();
      final url = ((d.imageurl ?? d.imageUrl) ?? '').toString().trim();
      if (tag.isNotEmpty && url.isNotEmpty) {
        // 중복이면 최초 1개만 유지
        eventMap.putIfAbsent(tag, () => url);
      }
    }
  }

  for (var scene in scenes) {
    if (scene is! Map) continue;

    // --- 데이터 추출 ---
    String type = scene['type']?.toString() ?? 'narration';
    String content = scene['content']?.toString() ?? '';
    String speaker = scene['speaker']?.toString() ?? '';
    String action = scene['action']?.toString() ?? '';
    String condition = scene['condition']?.toString() ?? '';

    // 어떤 파서들은 imageUrl을 직접 넣기도 함
    String directImageUrl =
        scene['imageUrl']?.toString() ?? scene['url']?.toString() ?? '';
    directImageUrl = directImageUrl.trim();

    String imageUrl = '';

    // --- 이미지 URL 찾기 로직 ---
    if (type == 'show_image' || type == 'story_image') {
      type = 'story_image';

      final tag = condition.trim();

      // ✅ 0) scene에 imageUrl이 직접 있으면 그걸 최우선
      if (directImageUrl.isNotEmpty) {
        imageUrl = directImageUrl;
      } else {
        // ✅ 1) 이벤트에서 찾기 (EventAssets)
        // event tag가 있으면 events에서 url로 매핑
        if (imageUrl.isEmpty && tag.isNotEmpty) {
          final evUrl = eventMap[tag];
          if (evUrl != null && evUrl.isNotEmpty) {
            imageUrl = evUrl;
          }
        }

        // ✅ 2) 배경에서 찾기 (BackgroundAssets)
        if (imageUrl.isEmpty && backgrounds != null && tag.isNotEmpty) {
          for (var bg in backgrounds) {
            if (bg.placeName == tag) {
              imageUrl = bg.imageUrl;
              break;
            }
          }
        }

        // ✅ 3) 상황에서 찾기 (SituationAssets)
        if (imageUrl.isEmpty && characters != null && tag.isNotEmpty) {
          for (var char in characters) {
            for (var sit in char.situationImages) {
              if (sit.condition == tag) {
                imageUrl = sit.imageUrl;
                break;
              }
            }
            if (imageUrl.isNotEmpty) break;
          }
        }
      }
    }

    // --- A) Firestore 저장용 데이터 ---
    final newDocRef = messagesRef.doc();
    final messageData = createStorymessagesRecordData(
      text: content,
      type: type,
      speakerName: speaker,
      actionText: action,
      storyImageUrl: imageUrl,
      timestamp: DateTime.now(),
    );
    batch.set(newDocRef, messageData);

    // --- B) 화면 표시용 Struct ---
    localMessages.add(createStoryChatMessageStructStruct(
      text: content,
      type: type,
      speakerName: speaker,
      actionText: action,
      storyImageUrl: imageUrl,
      timestamp: DateTime.now(),
    ));
  }

  await batch.commit();
  return localMessages;
}
