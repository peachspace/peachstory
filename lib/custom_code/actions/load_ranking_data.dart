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
  if (period == 'daily') {
    duration = Duration(days: 1);
  } else if (period == 'weekly') {
    duration = Duration(days: 7);
  } else if (period == 'monthly') {
    duration = Duration(days: 30);
  } else {
    duration = Duration(days: 1);
  }

  final startTime = DateTime.now().subtract(duration);
  final db = FirebaseFirestore.instance;
  final storyQuery = await db
      .collection('stories')
      .where('created_timestamp', isGreaterThanOrEqualTo: startTime)
      .get();

  final characterQuery = await db
      .collection('character')
      .where('created_timestamp', isGreaterThanOrEqualTo: startTime)
      .get();

  final storyList =
      storyQuery.docs.map((doc) => StoriesRecord.fromSnapshot(doc)).toList();
  final characterList = characterQuery.docs
      .map((doc) => CharacterRecord.fromSnapshot(doc))
      .toList();

  final combinedList = <CombinedListItemStructStruct>[];

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

  combinedList.sort((a, b) => (b.heartCount ?? 0).compareTo(a.heartCount ?? 0));

  return combinedList;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
