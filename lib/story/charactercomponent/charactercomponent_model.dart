import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'charactercomponent_widget.dart' show CharactercomponentWidget;
import 'package:flutter/material.dart';

class CharactercomponentModel
    extends FlutterFlowModel<CharactercomponentWidget> {
  ///  Local state fields for this component.

  String? tempAppearance;

  CharacterStructStruct? deleteCharacter;
  void updateDeleteCharacterStruct(Function(CharacterStructStruct) updateFn) {
    updateFn(deleteCharacter ??= CharacterStructStruct());
  }

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in charaicreate widget.
  String? createdcharacterImage;
  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in emotionaddutton widget.
  String? createdemotionimage;
  // State field(s) for charName widget.
  FocusNode? charNameFocusNode;
  TextEditingController? charNameTextController;
  String? Function(BuildContext, String?)? charNameTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? name;
  // State field(s) for charSetting widget.
  FocusNode? charSettingFocusNode;
  TextEditingController? charSettingTextController;
  String? Function(BuildContext, String?)? charSettingTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? personality;
  // State field(s) for charintroduce widget.
  FocusNode? charintroduceFocusNode;
  TextEditingController? charintroduceTextController;
  String? Function(BuildContext, String?)? charintroduceTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? introduce;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    charNameFocusNode?.dispose();
    charNameTextController?.dispose();

    charSettingFocusNode?.dispose();
    charSettingTextController?.dispose();

    charintroduceFocusNode?.dispose();
    charintroduceTextController?.dispose();
  }
}
