import '/backend/firebase_storage/storage.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'character_widget.dart' show CharacterWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CharacterModel extends FlutterFlowModel<CharacterWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadCharImage = false;
  FFUploadedFile uploadedLocalFile_uploadCharImage =
      FFUploadedFile(bytes: Uint8List.fromList([]));
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
