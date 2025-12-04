import '/flutter_flow/flutter_flow_util.dart';
import 'situation_widget.dart' show SituationWidget;
import 'package:flutter/material.dart';

class SituationModel extends FlutterFlowModel<SituationWidget> {
  ///  Local state fields for this component.

  String? tempSituationImage;

  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadsituationimage = false;
  FFUploadedFile uploadedLocalFile_uploadsituationimage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadsituationimage = '';

  // Stores action output result for [Bottom Sheet - imagecreate] action in Container widget.
  String? createdImage;
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
