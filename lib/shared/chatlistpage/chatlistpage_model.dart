import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'chatlistpage_widget.dart' show ChatlistpageWidget;
import 'package:flutter/material.dart';

class ChatlistpageModel extends FlutterFlowModel<ChatlistpageWidget> {
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

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
