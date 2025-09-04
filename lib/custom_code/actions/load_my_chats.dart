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

import '/auth/firebase_auth/auth_util.dart';

Future<List<CombinedListItemStructStruct>> loadMyChats() async {
  final currentUserRef = currentUserReference;
  if (currentUserRef == null) {
    return [];
  }

  final combinedList = <CombinedListItemStructStruct>[];
  final db = FirebaseFirestore.instance;

  final storyChatsSnapshot = await db
      .collection('storychats')
      .where('user_ref', isEqualTo: currentUserRef)
      .get();

  for (var chatDoc in storyChatsSnapshot.docs) {
    final chatData = chatDoc.data();
    final storyRef = chatData['story_ref'] as DocumentReference?;
    if (storyRef != null) {
      final storyDoc = await storyRef.get();
      if (storyDoc.exists) {
        final story = StoriesRecord.fromSnapshot(storyDoc);
        combinedList.add(CombinedListItemStructStruct(
          type: 'story',
          title: story.title,
          imageUrl: story.mainImage,
          timestamp: (chatData['last_timestamp'] as Timestamp?)?.toDate(),
          characterRef: null,
          storyRef: story.reference,
          category: story.category,
          userRole: chatData['userinChatName'] ?? '',
          introduction: story.description,
          viewCount: story.viewCount,
          heartCount: story.heartCount,
          creatorNickname: story.creatorNickname,
          hashtags: story.hashtags,
          creatorRef: story.creatorRef,
        ));
      }
    }
  }

  final characterChatsSnapshot = await db
      .collection('characterchats')
      .where('user_ref', isEqualTo: currentUserRef)
      .get();

  for (var chatDoc in characterChatsSnapshot.docs) {
    final chatData = chatDoc.data();
    final characterRef = chatData['character_ref'] as DocumentReference?;
    if (characterRef != null) {
      final characterDoc = await characterRef.get();
      if (characterDoc.exists) {
        final char = CharacterRecord.fromSnapshot(characterDoc);
        combinedList.add(CombinedListItemStructStruct(
          type: 'character',
          title: char.name,
          imageUrl: char.characterimage,
          timestamp: (chatData['last_timestamp'] as Timestamp?)?.toDate(),
          characterRef: char.reference,
          storyRef: null,
          category: char.genre,
          userRole: '',
          introduction: char.introduce,
          viewCount: char.viewCount,
          heartCount: char.heartCount,
          creatorNickname: char.creatorNickname,
          hashtags: char.hashtags,
          creatorRef: char.creatorRef,
        ));
      }
    }
  }

  combinedList.sort((a, b) {
    final aTime = a.timestamp ?? DateTime(1970);
    final bTime = b.timestamp ?? DateTime(1970);
    return bTime.compareTo(aTime);
  });
  return combinedList;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
