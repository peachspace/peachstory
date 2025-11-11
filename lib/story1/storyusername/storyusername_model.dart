import '/flutter_flow/flutter_flow_util.dart';
import 'storyusername_widget.dart' show StoryusernameWidget;
import 'package:flutter/material.dart';

class StoryusernameModel extends FlutterFlowModel<StoryusernameWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
