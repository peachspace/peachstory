import '/flutter_flow/flutter_flow_util.dart';
import 'charactercomponent_widget.dart' show CharactercomponentWidget;
import 'package:flutter/material.dart';

class CharactercomponentModel
    extends FlutterFlowModel<CharactercomponentWidget> {
  ///  Local state fields for this component.

  String? tempImage;

  String? tempAppearance;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in charaicreate widget.
  String? createdcharacterImage;
  bool isDataUploading_uploadCharImage = false;
  FFUploadedFile uploadedLocalFile_uploadCharImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadCharImage = '';

  // State field(s) for charName widget.
  FocusNode? charNameFocusNode;
  TextEditingController? charNameTextController;
  String? Function(BuildContext, String?)? charNameTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? name;
  // State field(s) for charSetting widget.
  FocusNode? charSettingFocusNode;
  TextEditingController? charSettingTextController;
  String? Function(BuildContext, String?)? charSettingTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? personality;
  // State field(s) for charintroduce widget.
  FocusNode? charintroduceFocusNode;
  TextEditingController? charintroduceTextController;
  String? Function(BuildContext, String?)? charintroduceTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? introduce;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    charNameFocusNode?.dispose();
    charNameTextController?.dispose();

    charSettingFocusNode?.dispose();
    charSettingTextController?.dispose();

    charintroduceFocusNode?.dispose();
    charintroduceTextController?.dispose();
  }
}
