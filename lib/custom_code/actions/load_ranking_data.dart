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

Future<List<CombinedListItemStructStruct>> loadRankingData(
    String period) async {
  Duration duration;
  if (period == '일간') {
    // [!code correction]
    duration = Duration(days: 1);
  } else if (period == '주간') {
    // [!code correction]
    duration = Duration(days: 7);
  } else if (period == '월간') {
    // [!code correction]
    duration = Duration(days: 30);
  } else {
    // 기본값
    duration = Duration(days: 1);
  }

  final startTime = DateTime.now().subtract(duration);
  final db = FirebaseFirestore.instance;

  // 1. 'stories' 컬렉션에서 상위 30개 쿼리
  //    - created_timestamp로 기간 필터링
  //    - heartCount로 정렬
  //    - limit(30)으로 30개만 가져오기
  final storyQuery = await db
      .collection('stories')
      .where('created_timestamp', isGreaterThanOrEqualTo: startTime)
      .orderBy('heartCount', descending: true)
      .limit(30)
      .get();

  // 2. 'character' 컬렉션에서 상위 30개 쿼리 (동일한 로직)
  final characterQuery = await db
      .collection('character')
      .where('created_timestamp', isGreaterThanOrEqualTo: startTime)
      .orderBy('heartCount', descending: true)
      .limit(30)
      .get();

  final storyList =
      storyQuery.docs.map((doc) => StoriesRecord.fromSnapshot(doc)).toList();
  final characterList = characterQuery.docs
      .map((doc) => CharacterRecord.fromSnapshot(doc))
      .toList();

  final combinedList = <CombinedListItemStructStruct>[];

  // 3. 쿼리 결과를 CombinedListItemStructStruct로 변환 (기존 코드와 동일)
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

  // 4. 앱 메모리에서 최종 정렬
  // (최대 60개(30+30) 아이템만 정렬하므로 매우 빠름)
  combinedList.sort((a, b) => (b.heartCount ?? 0).compareTo(a.heartCount ?? 0));

  // 5. 실제 상위 30개만 반환 (선택 사항이지만 권장)
  return combinedList.take(30).toList();
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
