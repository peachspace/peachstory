import '/flutter_flow/flutter_flow_util.dart';
import 'imagecreate_widget.dart' show ImagecreateWidget;
import 'package:flutter/material.dart';

class ImagecreateModel extends FlutterFlowModel<ImagecreateWidget> {
  ///  Local state fields for this component.

  String? generatedImageUrl;

  bool isImageLoading = false;

  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - generateImagePrompt] action in Container widget.
  String? suggestedPrompt;
  // Stores action output result for [Custom Action - generateStableDiffusionImage] action in Button widget.
  String? newImageResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
