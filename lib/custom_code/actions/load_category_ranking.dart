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

Future<List<CombinedListItemStructStruct>> loadCategoryRanking(
  String categoryName,
  String sortBy,
  String categoryType,
) async {
  QuerySnapshot querySnapshot;
  String collectionPath = (categoryType == 'story') ? 'stories' : 'character';
  String categoryField = (categoryType == 'story') ? 'category' : 'genre';
  String orderByField = (sortBy == '인기순') ? 'heart_count' : 'created_timestamp';

  querySnapshot = await FirebaseFirestore.instance
      .collection(collectionPath)
      .where(categoryField, isEqualTo: categoryName)
      .orderBy(orderByField, descending: true)
      .limit(30)
      .get();

  final combinedList = <CombinedListItemStructStruct>[];

  if (categoryType == 'character') {
    final characterList = querySnapshot.docs
        .map((doc) => CharacterRecord.fromSnapshot(doc))
        .toList();
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
  } else {
    final storyList = querySnapshot.docs
        .map((doc) => StoriesRecord.fromSnapshot(doc))
        .toList();
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
  }

  return combinedList;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
