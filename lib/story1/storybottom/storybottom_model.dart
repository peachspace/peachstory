import '/flutter_flow/flutter_flow_util.dart';
import 'storybottom_widget.dart' show StorybottomWidget;
import 'package:flutter/material.dart';

class StorybottomModel extends FlutterFlowModel<StorybottomWidget> {
  ///  Local state fields for this component.

  String localSelectedModel = '\" \"';

  ///  State fields for stateful widgets in this component.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
