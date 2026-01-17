import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'storymainpage_widget.dart' show StorymainpageWidget;
import 'package:flutter/material.dart';

class StorymainpageModel extends FlutterFlowModel<StorymainpageWidget> {
  ///  Local state fields for this page.

  bool isHearted = false;

  StoriesRecord? loadStory;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in startButton widget.
  StorychatsRecord? foundChat;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
