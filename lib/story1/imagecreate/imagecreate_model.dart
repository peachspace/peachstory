import '/flutter_flow/flutter_flow_util.dart';
import 'imagecreate_widget.dart' show ImagecreateWidget;
import 'package:flutter/material.dart';

class ImagecreateModel extends FlutterFlowModel<ImagecreateWidget> {
  ///  Local state fields for this component.

  String? generatedImageUrl;

  bool isImageLoading = false;

  bool isGenerating = false;

  List<int> selectedIndices = [];
  void addToSelectedIndices(int item) => selectedIndices.add(item);
  void removeFromSelectedIndices(int item) => selectedIndices.remove(item);
  void removeAtIndexFromSelectedIndices(int index) =>
      selectedIndices.removeAt(index);
  void insertAtIndexInSelectedIndices(int index, int item) =>
      selectedIndices.insert(index, item);
  void updateSelectedIndicesAtIndex(int index, Function(int) updateFn) =>
      selectedIndices[index] = updateFn(selectedIndices[index]);

  String? selectedCharImage;

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
  // Stores action output result for [Custom Action - callGenerateImageCloud] action in Button widget.
  String? newImageResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    imagemakepromptFocusNode?.dispose();
    imagemakepromptTextController?.dispose();
  }
}
