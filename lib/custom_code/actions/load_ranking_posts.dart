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

Future<List<CombinedListItemStructStruct>> loadRankingPosts() async {
  // 캐릭터와 스토리를 각각 20개씩 조회수순으로 불러옵니다.
  final characterQuery = await FirebaseFirestore.instance
      .collection('character')
      .orderBy('view_count', descending: true)
      .limit(20)
      .get();

  final storyQuery = await FirebaseFirestore.instance
      .collection('stories')
      .orderBy('view_count', descending: true)
      .limit(20)
      .get();

  final characterList = characterQuery.docs
      .map((doc) => CharacterRecord.fromSnapshot(doc))
      .toList();
  final storyList =
      storyQuery.docs.map((doc) => StoriesRecord.fromSnapshot(doc)).toList();

  final combinedList = <CombinedListItemStructStruct>[];

  // 캐릭터 목록을 공통 형식으로 변환하여 추가
  for (var char in characterList) {
    combinedList.add(CombinedListItemStructStruct(
      type: 'character',
      title: char.name,
      imageUrl: char.characterimage,
      timestamp: char.createdTimestamp,
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

  // 스토리 목록을 공통 형식으로 변환하여 추가
  for (var story in storyList) {
    combinedList.add(CombinedListItemStructStruct(
      type: 'story',
      title: story.title,
      imageUrl: story.mainImage,
      timestamp: story.createdTimestamp,
      characterRef: null,
      storyRef: story.reference,
      category: story.category,
      userRole: story.userRole,
      introduction: story.description,
      viewCount: story.viewCount,
      heartCount: story.heartCount,
      creatorNickname: story.creatorNickname,
      hashtags: story.hashtags,
      creatorRef: story.creatorRef,
    ));
  }

  // 합쳐진 목록을 다시 한번 조회수 순으로 정렬합니다.
  combinedList.sort((a, b) => (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));

  // 최종 20개만 반환합니다.
  return combinedList.take(20).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
