import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'heartlistpage_widget.dart' show HeartlistpageWidget;
import 'package:flutter/material.dart';

class HeartlistpageModel extends FlutterFlowModel<HeartlistpageWidget> {
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

  // Stores action output result for [Backend Call - Read Document] action in heartlistpage widget.
  UsersRecord? currentUserDoc;
  // Stores action output result for [Custom Action - getHeartedPosts] action in heartlistpage widget.
  List<CombinedListItemStructStruct>? heartedItems;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
