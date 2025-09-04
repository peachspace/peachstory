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
  final currentUserRef = currentUserReference;
  if (currentUserRef == null) {
    return [];
  }

  final combinedList = <CombinedListItemStructStruct>[];

  final storiesSnapshot = await FirebaseFirestore.instance
      .collection('stories')
      .where('creator_ref', isEqualTo: currentUserRef)
      .get();

  for (var doc in storiesSnapshot.docs) {
    final story = StoriesRecord.fromSnapshot(doc);
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

  final charactersSnapshot = await FirebaseFirestore.instance
      .collection('character')
      .where('creator_ref', isEqualTo: currentUserRef)
      .get();

  for (var doc in charactersSnapshot.docs) {
    final char = CharacterRecord.fromSnapshot(doc);
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

  combinedList.sort((a, b) {
    final aTime = a.timestamp ?? DateTime(1970);
    final bTime = b.timestamp ?? DateTime(1970);
    return bTime.compareTo(aTime);
  });
  return combinedList;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
