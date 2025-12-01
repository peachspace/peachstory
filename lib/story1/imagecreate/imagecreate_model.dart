import '/flutter_flow/flutter_flow_util.dart';
import 'imagecreate_widget.dart' show ImagecreateWidget;
import 'package:flutter/material.dart';

class ImagecreateModel extends FlutterFlowModel<ImagecreateWidget> {
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
