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

import 'index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<StoryChatMessageStructStruct>> processAndSaveChatTurn(
  List<dynamic> scenes, // ✅ 파서 결과(JSON List)
  DocumentReference storyDocRef,
  List<PlaceStructStruct>? backgrounds,
  List<CharacterStructStruct>? characters,
  List<EventStructStruct>? events,
) async {
  final localMessages = <StoryChatMessageStructStruct>[];

  final batch = FirebaseFirestore.instance.batch();
  final CollectionReference messagesRef =
      storyDocRef.collection('storymessages');

  // 이벤트 맵: event tag -> url
  final eventMap = <String, String>{};
  if (events != null) {
    for (final ev in events) {
      final tag = (ev.event).toString().trim();
      final url = (ev.imageurl).toString().trim();
      if (tag.isNotEmpty && url.isNotEmpty) {
        eventMap.putIfAbsent(tag, () => url);
      }
    }
  }

  // 배경 맵: place -> url
  final bgMap = <String, String>{};
  if (backgrounds != null) {
    for (final bg in backgrounds) {
      final place = (bg.place).toString().trim();
      final url = (bg.imageUrl).toString().trim();
      if (place.isNotEmpty && url.isNotEmpty) {
        bgMap.putIfAbsent(place, () => url);
      }
    }
  }

  // 조합 맵: PLACE__TAG -> url
  final comboMap = <String, String>{};
  if (characters != null) {
    for (final c in characters) {
      for (final a in (c.abilityStruct ?? <AbilityStructStruct>[])) {
        final place = (a.place).toString().trim();
        final tag = (a.ability).toString().trim();
        final url = (a.imageUrl).toString().trim();
        if (place.isNotEmpty && tag.isNotEmpty && url.isNotEmpty) {
          comboMap.putIfAbsent('${place}__${tag}', () => url);
        }
      }
      for (final e in (c.emotionStruct ?? <EmotionStructStruct>[])) {
        final place = (e.place).toString().trim();
        final tag = (e.emotion).toString().trim();
        final url = (e.imageurl).toString().trim();
        if (place.isNotEmpty && tag.isNotEmpty && url.isNotEmpty) {
          comboMap.putIfAbsent('${place}__${tag}', () => url);
        }
      }
    }
  }

  String resolveUrl(String assetName) {
    final key = assetName.trim();
    if (key.isEmpty) return '';

    // 1) event
    final ev = eventMap[key];
    if (ev != null && ev.isNotEmpty) return ev;

    // 2) combo
    final c = comboMap[key];
    if (c != null && c.isNotEmpty) return c;

    // 3) background(place)
    final bg = bgMap[key];
    if (bg != null && bg.isNotEmpty) return bg;

    return '';
  }

  for (final scene in scenes) {
    if (scene is! Map) continue;

    String type = (scene['type'] ?? 'narration').toString();
    String content = (scene['content'] ?? '').toString();
    String speaker = (scene['speaker'] ?? '').toString();
    String action = (scene['action'] ?? '').toString();
    String condition = (scene['condition'] ?? '').toString();

    String directImageUrl =
        ((scene['imageUrl'] ?? scene['url']) ?? '').toString().trim();

    String imageUrl = '';

    if (type == 'show_image' || type == 'story_image') {
      type = 'story_image';
      final assetName = condition.trim();

      if (directImageUrl.isNotEmpty) {
        imageUrl = directImageUrl;
      } else {
        imageUrl = resolveUrl(assetName);
      }

      // 못 찾으면 저장하지 않음
      if (imageUrl.isEmpty) continue;
    }

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

    localMessages.add(
      createStoryChatMessageStructStruct(
        text: content,
        type: type,
        speakerName: speaker,
        actionText: action,
        storyImageUrl: imageUrl,
        timestamp: DateTime.now(),
      ),
    );
  }

  await batch.commit();
  return localMessages;
}
