import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'imagecreatebottomsheet_widget.dart' show ImagecreatebottomsheetWidget;
import 'package:flutter/material.dart';

class ImagecreatebottomsheetModel
    extends FlutterFlowModel<ImagecreatebottomsheetWidget> {
  ///  Local state fields for this component.

  String? generatedImageUrl;

  bool isImageLoading = false;

  bool isGenerating = false;

  CharacterStructStruct? selectedCharImage;
  void updateSelectedCharImageStruct(Function(CharacterStructStruct) updateFn) {
    updateFn(selectedCharImage ??= CharacterStructStruct());
  }

  int? generatedSeed;

  String? generatedBasePrompt;

  String? generatingTarget;

  ///  State fields for stateful widgets in this component.

  // State field(s) for imagestyleChoiceChips widget.
  FormFieldController<List<String>>? imagestyleChoiceChipsValueController;
  String? get imagestyleChoiceChipsValue =>
      imagestyleChoiceChipsValueController?.value?.firstOrNull;
  set imagestyleChoiceChipsValue(String? val) =>
      imagestyleChoiceChipsValueController?.value = val != null ? [val] : [];
  // State field(s) for backgroundprompt widget.
  FocusNode? backgroundpromptFocusNode;
  TextEditingController? backgroundpromptTextController;
  String? Function(BuildContext, String?)?
      backgroundpromptTextControllerValidator;
  // Stores action output result for [Custom Action - generateTriggerKeyword] action in backgroundtaggenbutton widget.
  String? backgroundtagprompt;
  // State field(s) for situationprompt widget.
  FocusNode? situationpromptFocusNode;
  TextEditingController? situationpromptTextController;
  String? Function(BuildContext, String?)?
      situationpromptTextControllerValidator;
  // Stores action output result for [Custom Action - generateTriggerKeyword] action in situationtaggenbutton widget.
  String? situationtagPrompt;
  // State field(s) for emotionChoiceChips widget.
  FormFieldController<List<String>>? emotionChoiceChipsValueController;
  String? get emotionChoiceChipsValue =>
      emotionChoiceChipsValueController?.value?.firstOrNull;
  set emotionChoiceChipsValue(String? val) =>
      emotionChoiceChipsValueController?.value = val != null ? [val] : [];
  // State field(s) for imagecreateprompt widget.
  FocusNode? imagecreatepromptFocusNode;
  TextEditingController? imagecreatepromptTextController;
  String? Function(BuildContext, String?)?
      imagecreatepromptTextControllerValidator;
  // Stores action output result for [Custom Action - generateVisualTags] action in imagepromptgenbutton widget.
  String? profiletag;
  // Stores action output result for [Custom Action - generateVisualTags] action in imagepromptgenbutton widget.
  String? situationtag;
  // Stores action output result for [Custom Action - generateVisualTags] action in imagepromptgenbutton widget.
  String? backgroundtag;
  // Stores action output result for [Custom Action - generateVisualTags] action in imagepromptgenbutton widget.
  String? maintag;
  // Stores action output result for [Custom Action - generateVisualTags] action in imagepromptgenbutton widget.
  String? emotiontag;
  // Stores action output result for [Custom Action - composeScenePrompt] action in imagegenbutton widget.
  String? charimagePrompt;
  // Stores action output result for [Custom Action - callGenerateImageCloud] action in imagegenbutton widget.
  dynamic characterImageResult;
  // Stores action output result for [Custom Action - composeScenePrompt] action in imagegenbutton widget.
  String? emotionimagePrompt;
  // Stores action output result for [Custom Action - callGenerateImageCloud] action in imagegenbutton widget.
  dynamic emotionimageResult;
  // Stores action output result for [Custom Action - composeScenePrompt] action in imagegenbutton widget.
  String? situationimageprompt;
  // Stores action output result for [Custom Action - callGenerateImageCloud] action in imagegenbutton widget.
  dynamic situationImageResult;
  // Stores action output result for [Custom Action - composeScenePrompt] action in imagegenbutton widget.
  String? backgroundimageprompt;
  // Stores action output result for [Custom Action - callGenerateImageCloud] action in imagegenbutton widget.
  dynamic backgroundimageResult;
  // Stores action output result for [Custom Action - callGenerateImageCloud] action in imagegenbutton widget.
  dynamic mainimageResult;
  bool isDataUploading_downloadUrl = false;
  FFUploadedFile uploadedLocalFile_downloadUrl =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_downloadUrl = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    backgroundpromptFocusNode?.dispose();
    backgroundpromptTextController?.dispose();

    situationpromptFocusNode?.dispose();
    situationpromptTextController?.dispose();

    imagecreatepromptFocusNode?.dispose();
    imagecreatepromptTextController?.dispose();
  }
}
