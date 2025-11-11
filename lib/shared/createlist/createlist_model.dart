import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'createlist_widget.dart' show CreatelistWidget;
import 'package:flutter/material.dart';

class CreatelistModel extends FlutterFlowModel<CreatelistWidget> {
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

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - loadMyCreations] action in createlist widget.
  List<CombinedListItemStructStruct>? creations;
  // Stores action output result for [Custom Action - loadMyCreations] action in Icon widget.
  List<CombinedListItemStructStruct>? refreshedList;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
