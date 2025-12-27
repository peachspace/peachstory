import '/flutter_flow/flutter_flow_util.dart';
import 'dialogue_input_item_widget.dart' show DialogueInputItemWidget;
import 'package:flutter/material.dart';

class DialogueInputItemModel extends FlutterFlowModel<DialogueInputItemWidget> {
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
