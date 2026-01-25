import '/flutter_flow/flutter_flow_util.dart';
import 'profileeditcomponent_widget.dart' show ProfileeditcomponentWidget;
import 'package:flutter/material.dart';

class ProfileeditcomponentModel
    extends FlutterFlowModel<ProfileeditcomponentWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadData = false;
  FFUploadedFile uploadedLocalFile_uploadData =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadData = '';

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
