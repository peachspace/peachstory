import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'charsettingpage_widget.dart' show CharsettingpageWidget;
import 'package:flutter/material.dart';

class CharsettingpageModel extends FlutterFlowModel<CharsettingpageWidget> {
  ///  Local state fields for this page.

  CharacterStructStruct? editchar;
  void updateEditcharStruct(Function(CharacterStructStruct) updateFn) {
    updateFn(editchar ??= CharacterStructStruct());
  }

  ///  State fields for stateful widgets in this page.

  // State field(s) for charName widget.
  FocusNode? charNameFocusNode;
  TextEditingController? charNameTextController;
  String? Function(BuildContext, String?)? charNameTextControllerValidator;
  // State field(s) for charSetting widget.
  FocusNode? charSettingFocusNode;
  TextEditingController? charSettingTextController;
  String? Function(BuildContext, String?)? charSettingTextControllerValidator;
  // State field(s) for charability widget.
  FocusNode? charabilityFocusNode;
  TextEditingController? charabilityTextController;
  String? Function(BuildContext, String?)? charabilityTextControllerValidator;
  // State field(s) for charintroduce widget.
  FocusNode? charintroduceFocusNode;
  TextEditingController? charintroduceTextController;
  String? Function(BuildContext, String?)? charintroduceTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    charNameFocusNode?.dispose();
    charNameTextController?.dispose();

    charSettingFocusNode?.dispose();
    charSettingTextController?.dispose();

    charabilityFocusNode?.dispose();
    charabilityTextController?.dispose();

    charintroduceFocusNode?.dispose();
    charintroduceTextController?.dispose();
  }
}
