import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/story/storycommentcomponent/storycommentcomponent_widget.dart';
import 'storycommentcomponent_widget.dart' show StorycommentcomponentWidget;
import 'package:flutter/material.dart';

class StorycommentcomponentModel
    extends FlutterFlowModel<StorycommentcomponentWidget> {
  ///  Local state fields for this component.

  bool isReplyVisible = false;

  bool isLikedByUser = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Cloud Function - deleteCommentAndReplies] action in Icon widget.
  DeleteCommentAndRepliesCloudFunctionCallResponse? cloudFunction;
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
