import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'heartlist_widget.dart' show HeartlistWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HeartlistModel extends FlutterFlowModel<HeartlistWidget> {
  ///  Local state fields for this page.

  List<CombinedListItemStructStruct> myHeartedList = [];
  void addToMyHeartedList(CombinedListItemStructStruct item) =>
      myHeartedList.add(item);
  void removeFromMyHeartedList(CombinedListItemStructStruct item) =>
      myHeartedList.remove(item);
  void removeAtIndexFromMyHeartedList(int index) =>
      myHeartedList.removeAt(index);
  void insertAtIndexInMyHeartedList(
          int index, CombinedListItemStructStruct item) =>
      myHeartedList.insert(index, item);
  void updateMyHeartedListAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      myHeartedList[index] = updateFn(myHeartedList[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in heartlist widget.
  UsersRecord? currentUserDoc;
  // Stores action output result for [Custom Action - getHeartedPosts] action in heartlist widget.
  List<CombinedListItemStructStruct>? heartedItems;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
