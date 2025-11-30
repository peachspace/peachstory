import '/flutter_flow/flutter_flow_util.dart';
import 'character_widget.dart' show CharacterWidget;
import 'package:flutter/material.dart';

class CharacterModel extends FlutterFlowModel<CharacterWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadCharImage = false;
  FFUploadedFile uploadedLocalFile_uploadCharImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadCharImage = '';

  // State field(s) for charName widget.
  FocusNode? charNameFocusNode1;
  TextEditingController? charNameTextController1;
  String? Function(BuildContext, String?)? charNameTextController1Validator;
  // State field(s) for charPersonailty widget.
  FocusNode? charPersonailtyFocusNode;
  TextEditingController? charPersonailtyTextController;
  String? Function(BuildContext, String?)?
      charPersonailtyTextControllerValidator;
  // State field(s) for charName widget.
  FocusNode? charNameFocusNode2;
  TextEditingController? charNameTextController2;
  String? Function(BuildContext, String?)? charNameTextController2Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    charNameFocusNode1?.dispose();
    charNameTextController1?.dispose();

    charPersonailtyFocusNode?.dispose();
    charPersonailtyTextController?.dispose();

    charNameFocusNode2?.dispose();
    charNameTextController2?.dispose();
  }
}
