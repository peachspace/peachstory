import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'charactercomponent_widget.dart' show CharactercomponentWidget;
import 'package:flutter/material.dart';

class CharactercomponentModel
    extends FlutterFlowModel<CharactercomponentWidget> {
  ///  Local state fields for this component.

  CharacterStructStruct? deleteCharacter;
  void updateDeleteCharacterStruct(Function(CharacterStructStruct) updateFn) {
    updateFn(deleteCharacter ??= CharacterStructStruct());
  }

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

  ///  State fields for stateful widgets in this component.

  // State field(s) for charName widget.
  FocusNode? charNameFocusNode;
  TextEditingController? charNameTextController;
  String? Function(BuildContext, String?)? charNameTextControllerValidator;
  // Stores action output result for [Custom Action - generateCharacterField] action in charnameaicreate widget.
  String? name;
  // State field(s) for charSetting widget.
  FocusNode? charSettingFocusNode;
  TextEditingController? charSettingTextController;
  String? Function(BuildContext, String?)? charSettingTextControllerValidator;
  // Stores action output result for [Custom Action - generateCharacterField] action in charsettingaicreate widget.
  String? personality;
  // State field(s) for charintroduce widget.
  FocusNode? charintroduceFocusNode;
  TextEditingController? charintroduceTextController;
  String? Function(BuildContext, String?)? charintroduceTextControllerValidator;
  // Stores action output result for [Custom Action - generateCharacterField] action in charintroaicreate widget.
  String? introduce;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in charaicreate widget.
  GenResultStructStruct? generatedcharacterImage;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in emotionaddutton widget.
  GenResultStructStruct? generatedemotionimage;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in situationaddutton widget.
  GenResultStructStruct? generatedsituationimage;

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
