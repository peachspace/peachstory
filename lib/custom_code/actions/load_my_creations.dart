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

Future<List<CombinedListItemStructStruct>> loadMyCreations() async {
  final db = FirebaseFirestore.instance;

  // 1. 현재 유저의 Reference 가져오기
  final currentUserRef = currentUserReference;
  if (currentUserRef == null) {
    // 로그인하지 않았으면 빈 리스트 반환
    return [];
  }

  // 2. 'stories'에서 내가 만든 것 쿼리
  final storyQuery = await db
      .collection('stories')
      .where('creatorRef', isEqualTo: currentUserRef)
      .orderBy('created_timestamp', descending: true)
      .get();

  // 3. 'character'에서 내가 만든 것 쿼리
  final characterQuery = await db
      .collection('character')
      .where('creatorRef', isEqualTo: currentUserRef)
      .orderBy('created_timestamp', descending: true)
      .get();

  final storyList =
      storyQuery.docs.map((doc) => StoriesRecord.fromSnapshot(doc)).toList();
  final characterList = characterQuery.docs
      .map((doc) => CharacterRecord.fromSnapshot(doc))
      .toList();

  final combinedList = <CombinedListItemStructStruct>[];

  // 4. 'stories' 리스트 변환
  for (var story in storyList) {
    combinedList.add(CombinedListItemStructStruct(
      type: 'story',
      title: story.title,
      imageUrl: story.mainImage,
      timestamp: story.createdTimestamp,
      storyRef: story.reference,
      category: story.category,
      introduction: story.description,
      viewCount: story.viewCount,
      heartCount: story.heartCount,
      creatorNickname: story.creatorNickname,
      hashtags: story.hashtags,
      creatorRef: story.creatorRef,
    ));
  }

  // 5. 'character' 리스트 변환
  for (var char in characterList) {
    combinedList.add(CombinedListItemStructStruct(
      type: 'character',
      title: char.name,
      imageUrl: char.characterimage,
      timestamp: char.createdTimestamp,
      characterRef: char.reference,
      category: char.genre,
      introduction: char.introduce,
      viewCount: char.viewCount,
      heartCount: char.heartCount,
      creatorNickname: char.creatorNickname,
      hashtags: char.hashtags,
      creatorRef: char.creatorRef,
    ));
  }

  // 6. 두 리스트를 합쳐서 다시 시간순으로 정렬
  combinedList.sort((a, b) => (b.timestamp!).compareTo(a.timestamp!));

  return combinedList;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
