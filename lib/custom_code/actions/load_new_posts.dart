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

Future<List<CombinedListItemStructStruct>> loadNewPosts() async {
  final db = FirebaseFirestore.instance;

  // 1. 'stories'에서 최신 30개 쿼리
  final storyQuery = await db
      .collection('stories')
      .orderBy('created_timestamp', descending: true)
      .limit(30)
      .get();

  // 2. 'character'에서 최신 30개 쿼리
  final characterQuery = await db
      .collection('character')
      .orderBy('created_timestamp', descending: true)
      .limit(30)
      .get();

  final storyList =
      storyQuery.docs.map((doc) => StoriesRecord.fromSnapshot(doc)).toList();
  final characterList = characterQuery.docs
      .map((doc) => CharacterRecord.fromSnapshot(doc))
      .toList();

  final combinedList = <CombinedListItemStructStruct>[];

  // 3. 'stories' 리스트 변환
  for (var story in storyList) {
    combinedList.add(CombinedListItemStructStruct(
      type: 'story',
      title: story.title,
      imageUrl: story.mainImage,
      timestamp: story.createdTimestamp,
      characterRef: null,
      storyRef: story.reference,
      category: story.category,
      introduction: story.description,
      viewCount: story.viewCount,
      heartCount: story.heartCount,
      creatorNickname: story.creatorNickname,
      hashtags: story.hashtags,
      creatorRef: story.creatorRef,
      // userRole은 CombinedListItemStructStruct에 없으면 이 줄 삭제
      // userRole: story.userRole,
    ));
  }

  // 4. 'character' 리스트 변환
  for (var char in characterList) {
    combinedList.add(CombinedListItemStructStruct(
      type: 'character',
      title: char.name,
      imageUrl: char.characterimage,
      timestamp: char.createdTimestamp,
      characterRef: char.reference,
      storyRef: null,
      category: char.genre,
      introduction: char.introduce,
      viewCount: char.viewCount,
      heartCount: char.heartCount,
      creatorNickname: char.creatorNickname,
      hashtags: char.hashtags,
      creatorRef: char.creatorRef,
      // userRole: '', // userRole이 필요하면 추가
    ));
  }

  // 5. 두 리스트를 합쳐서 다시 시간순으로 정렬
  combinedList.sort((a, b) => (b.timestamp!).compareTo(a.timestamp!));

  // 6. 합쳐진 리스트에서 최종 30개만 반환
  return combinedList.take(30).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
