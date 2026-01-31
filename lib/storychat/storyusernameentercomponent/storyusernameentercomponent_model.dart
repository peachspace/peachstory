import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'storyusernameentercomponent_widget.dart'
    show StoryusernameentercomponentWidget;
import 'package:flutter/material.dart';

class StoryusernameentercomponentModel
    extends FlutterFlowModel<StoryusernameentercomponentWidget> {
  ///  Local state fields for this component.

  StoriesRecord? storyDoc;

  String? selectedMode;

  ///  State fields for stateful widgets in this component.

  // State field(s) for usernameTextField widget.
  FocusNode? usernameTextFieldFocusNode;
  TextEditingController? usernameTextFieldTextController;
  String? Function(BuildContext, String?)?
      usernameTextFieldTextControllerValidator;
  // Stores action output result for [Backend Call - Create Document] action in nameinstoryButton widget.
  StorychatsRecord? newChatDoc;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    usernameTextFieldFocusNode?.dispose();
    usernameTextFieldTextController?.dispose();
  }
}
