import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'chatlist_widget.dart' show ChatlistWidget;
import 'package:flutter/material.dart';

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
