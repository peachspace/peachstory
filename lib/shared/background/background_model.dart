import '/flutter_flow/flutter_flow_util.dart';
import 'background_widget.dart' show BackgroundWidget;
import 'package:flutter/material.dart';

class BackgroundModel extends FlutterFlowModel<BackgroundWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  bool isDataUploading_uploadimage = false;
  FFUploadedFile uploadedLocalFile_uploadimage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadimage = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
