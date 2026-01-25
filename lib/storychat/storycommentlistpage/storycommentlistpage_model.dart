import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'storycommentlistpage_widget.dart' show StorycommentlistpageWidget;
import 'package:flutter/material.dart';

class StorycommentlistpageModel
    extends FlutterFlowModel<StorycommentlistpageWidget> {
  ///  Local state fields for this page.

  bool isSortByLatest = true;

  int? commentCharCount;

  String? replyingToCommentId;

  String? expandedRepliesCommentId;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in storycommentlistpage widget.
  int? commentCountResult;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
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
