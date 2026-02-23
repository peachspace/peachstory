import '/flutter_flow/flutter_flow_util.dart';
import 'settingsheet_widget.dart' show SettingsheetWidget;
import 'package:flutter/material.dart';

class SettingsheetModel extends FlutterFlowModel<SettingsheetWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for usernoteTextField widget.
  FocusNode? usernoteTextFieldFocusNode;
  TextEditingController? usernoteTextFieldTextController;
  String? Function(BuildContext, String?)?
      usernoteTextFieldTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    usernoteTextFieldFocusNode?.dispose();
    usernoteTextFieldTextController?.dispose();
  }
}
