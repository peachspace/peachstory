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

Future<List<CombinedListItemStructStruct>> getHeartedPosts(
  List<String> postPaths,
) async {
  if (postPaths.isEmpty) {
    return [];
  }

  final combinedList = <CombinedListItemStructStruct>[];

  for (String path in postPaths) {
    try {
      final docRef = FirebaseFirestore.instance.doc(path);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        if (path.startsWith('character/')) {
          final char = CharacterRecord.fromSnapshot(snapshot);
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
        } else if (path.startsWith('stories/')) {
          final story = StoriesRecord.fromSnapshot(snapshot);
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
    } catch (e) {
      print('Error fetching document from path: $path, Error: $e');
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
