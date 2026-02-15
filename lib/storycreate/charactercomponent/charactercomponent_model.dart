import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'charactercomponent_widget.dart' show CharactercomponentWidget;
import 'package:flutter/material.dart';

class CharactercomponentModel
    extends FlutterFlowModel<CharactercomponentWidget> {
  ///  Local state fields for this component.

  String? profileimage;

  List<EmotionImageStructStruct> emotionimagelist = [];
  void addToEmotionimagelist(EmotionImageStructStruct item) =>
      emotionimagelist.add(item);
  void removeFromEmotionimagelist(EmotionImageStructStruct item) =>
      emotionimagelist.remove(item);
  void removeAtIndexFromEmotionimagelist(int index) =>
      emotionimagelist.removeAt(index);
  void insertAtIndexInEmotionimagelist(
          int index, EmotionImageStructStruct item) =>
      emotionimagelist.insert(index, item);
  void updateEmotionimagelistAtIndex(
          int index, Function(EmotionImageStructStruct) updateFn) =>
      emotionimagelist[index] = updateFn(emotionimagelist[index]);

  List<SituationalImageStructStruct> situationimage = [];
  void addToSituationimage(SituationalImageStructStruct item) =>
      situationimage.add(item);
  void removeFromSituationimage(SituationalImageStructStruct item) =>
      situationimage.remove(item);
  void removeAtIndexFromSituationimage(int index) =>
      situationimage.removeAt(index);
  void insertAtIndexInSituationimage(
          int index, SituationalImageStructStruct item) =>
      situationimage.insert(index, item);
  void updateSituationimageAtIndex(
          int index, Function(SituationalImageStructStruct) updateFn) =>
      situationimage[index] = updateFn(situationimage[index]);

  int? seed;

  String? baseprompt;

  ///  State fields for stateful widgets in this component.

  // State field(s) for charName widget.
  FocusNode? charNameFocusNode;
  TextEditingController? charNameTextController;
  String? Function(BuildContext, String?)? charNameTextControllerValidator;
  // Stores action output result for [Custom Action - generateCharacterField] action in charnamegenbutton widget.
  String? name;
  // State field(s) for charSetting widget.
  FocusNode? charSettingFocusNode;
  TextEditingController? charSettingTextController;
  String? Function(BuildContext, String?)? charSettingTextControllerValidator;
  // Stores action output result for [Custom Action - generateCharacterField] action in charsettinggenbutton widget.
  String? personality;
  // State field(s) for charAppearance widget.
  FocusNode? charAppearanceFocusNode;
  TextEditingController? charAppearanceTextController;
  String? Function(BuildContext, String?)?
      charAppearanceTextControllerValidator;
  // Stores action output result for [Custom Action - generateCharacterField] action in charappearancegenbutton widget.
  String? appearance;
  // State field(s) for charSkill widget.
  FocusNode? charSkillFocusNode;
  TextEditingController? charSkillTextController;
  String? Function(BuildContext, String?)? charSkillTextControllerValidator;
  // State field(s) for charintroduce widget.
  FocusNode? charintroduceFocusNode;
  TextEditingController? charintroduceTextController;
  String? Function(BuildContext, String?)? charintroduceTextControllerValidator;
  // Stores action output result for [Custom Action - generateCharacterField] action in charintrogenbutton widget.
  String? introduce;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in profilegenbutton widget.
  GenResultStructStruct? generatedcharacterImage;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in emotionaddbutton widget.
  GenResultStructStruct? generatedemotionimage;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in Abilityaddbutton widget.
  GenResultStructStruct? generatedsituationimage;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    charNameFocusNode?.dispose();
    charNameTextController?.dispose();

    charSettingFocusNode?.dispose();
    charSettingTextController?.dispose();

    charAppearanceFocusNode?.dispose();
    charAppearanceTextController?.dispose();

    charSkillFocusNode?.dispose();
    charSkillTextController?.dispose();

    charintroduceFocusNode?.dispose();
    charintroduceTextController?.dispose();
  }
}
