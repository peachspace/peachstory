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
  FocusNode? charNameFocusNode;
  TextEditingController? charNameTextController;
  String? Function(BuildContext, String?)? charNameTextControllerValidator;
  // State field(s) for charPersonailty widget.
  FocusNode? charPersonailtyFocusNode;
  TextEditingController? charPersonailtyTextController;
  String? Function(BuildContext, String?)?
      charPersonailtyTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    charNameFocusNode?.dispose();
    charNameTextController?.dispose();

    charPersonailtyFocusNode?.dispose();
    charPersonailtyTextController?.dispose();
  }
}
