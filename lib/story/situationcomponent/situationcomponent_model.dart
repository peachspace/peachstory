import '/flutter_flow/flutter_flow_util.dart';
import 'situationcomponent_widget.dart' show SituationcomponentWidget;
import 'package:flutter/material.dart';

class SituationcomponentModel
    extends FlutterFlowModel<SituationcomponentWidget> {
  ///  Local state fields for this component.

  String? tempSituationImage;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in situationaicreate widget.
  String? createdsituationmage;
  bool isDataUploading_uploadsituationimage = false;
  FFUploadedFile uploadedLocalFile_uploadsituationimage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadsituationimage = '';

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? generatedCondition;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
