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
  // 캐릭터와 스토리를 각각 20개씩 최신순으로 불러옵니다.
  final characterQuery = await FirebaseFirestore.instance
      .collection('character')
      .orderBy('created_timestamp', descending: true)
      .limit(20)
      .get();

  final storyQuery = await FirebaseFirestore.instance
      .collection('stories')
      .orderBy('created_timestamp', descending: true)
      .limit(20)
      .get();

  final characterList = characterQuery.docs
      .map((doc) => CharacterRecord.fromSnapshot(doc))
      .toList();
  final storyList =
      storyQuery.docs.map((doc) => StoriesRecord.fromSnapshot(doc)).toList();

  final combinedList = <CombinedListItemStructStruct>[];

  // 캐릭터 목록을 공통 형식으로 변환
  for (var char in characterList) {
    combinedList.add(CombinedListItemStructStruct(
      type: 'character',
      title: char.name,
      imageUrl: char.characterimage,
      timestamp: char.createdTimestamp,
      viewCount: char.viewCount,
      heartCount: char.heartCount,
      introduction: char.introduce,
      creatorNickname: char.creatorNickname,
      characterRef: char.reference,
      hashtags: char.hashtags,
      creatorRef: char.creatorRef,
    ));
  }

  // 스토리 목록을 공통 형식으로 변환
  for (var story in storyList) {
    combinedList.add(CombinedListItemStructStruct(
      type: 'story',
      title: story.title,
      imageUrl: story.mainImage,
      timestamp: story.createdTimestamp,
      viewCount: story.viewCount,
      heartCount: story.heartCount,
      introduction: story.description,
      creatorNickname: story.creatorNickname,
      storyRef: story.reference,
      hashtags: story.hashtags,
      creatorRef: story.creatorRef,
    ));
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
