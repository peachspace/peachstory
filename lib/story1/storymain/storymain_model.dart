import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'storymain_widget.dart' show StorymainWidget;
import 'package:flutter/material.dart';

class StorymainModel extends FlutterFlowModel<StorymainWidget> {
  ///  Local state fields for this page.

  bool isHearted = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in storymain widget.
  StoriesRecord? loadedStory;
  // Stores action output result for [Backend Call - Read Document] action in storymain widget.
  UsersRecord? currentUserDoc;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
