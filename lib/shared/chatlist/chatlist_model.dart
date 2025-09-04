import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'chatlist_widget.dart' show ChatlistWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class ChatlistModel extends FlutterFlowModel<ChatlistWidget> {
  ///  Local state fields for this page.

  List<CombinedListItemStructStruct> combinedList = [];
  void addToCombinedList(CombinedListItemStructStruct item) =>
      combinedList.add(item);
  void removeFromCombinedList(CombinedListItemStructStruct item) =>
      combinedList.remove(item);
  void removeAtIndexFromCombinedList(int index) => combinedList.removeAt(index);
  void insertAtIndexInCombinedList(
          int index, CombinedListItemStructStruct item) =>
      combinedList.insert(index, item);
  void updateCombinedListAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      combinedList[index] = updateFn(combinedList[index]);

  String type = 'character';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - loadMyChats] action in chatlist widget.
  List<CombinedListItemStructStruct>? chats;
  // Stores action output result for [Firestore Query - Query a collection] action in Icon widget.
  StorychatsRecord? deletestory;
  // Stores action output result for [Firestore Query - Query a collection] action in Icon widget.
  CharacterchatsRecord? deletecharacter;
  // Stores action output result for [Custom Action - loadMyChats] action in Icon widget.
  List<CombinedListItemStructStruct>? mychat;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
