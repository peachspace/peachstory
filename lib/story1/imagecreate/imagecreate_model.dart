import '/flutter_flow/flutter_flow_util.dart';
import 'imagecreate_widget.dart' show ImagecreateWidget;
import 'package:flutter/material.dart';

class ImagecreateModel extends FlutterFlowModel<ImagecreateWidget> {
  ///  Local state fields for this component.

  String? generatedImageUrl;

  bool isImageLoading = false;

  bool isGenerating = false;

  ///  State fields for stateful widgets in this component.

  // State field(s) for imagemakeprompt widget.
  FocusNode? imagemakepromptFocusNode;
  TextEditingController? imagemakepromptTextController;
  String? Function(BuildContext, String?)?
      imagemakepromptTextControllerValidator;
  // Stores action output result for [Custom Action - generateImagePrompt] action in Container widget.
  String? suggestedPrompt;
  // Stores action output result for [Custom Action - translateToEnglish] action in Button widget.
  String? englishPrompt;
  // Stores action output result for [Custom Action - generateStableDiffusionImage] action in Button widget.
  String? newImageResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    imagemakepromptFocusNode?.dispose();
    imagemakepromptTextController?.dispose();
  }
}
