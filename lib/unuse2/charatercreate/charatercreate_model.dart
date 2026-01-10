import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'charatercreate_widget.dart' show CharatercreateWidget;
import 'package:flutter/material.dart';

class CharatercreateModel extends FlutterFlowModel<CharatercreateWidget> {
  ///  Local state fields for this page.

  String? name = '';

  String? setting = '';

  List<String> dialogueExample = [];
  void addToDialogueExample(String item) => dialogueExample.add(item);
  void removeFromDialogueExample(String item) => dialogueExample.remove(item);
  void removeAtIndexFromDialogueExample(int index) =>
      dialogueExample.removeAt(index);
  void insertAtIndexInDialogueExample(int index, String item) =>
      dialogueExample.insert(index, item);
  void updateDialogueExampleAtIndex(int index, Function(String) updateFn) =>
      dialogueExample[index] = updateFn(dialogueExample[index]);

  String? voice = '';

  String? firstgreeting = '';

  String? mainimage = '';

  String? introduce = '';

  String? author = '';

  String? genre = '';

  List<String> hashitags = [];
  void addToHashitags(String item) => hashitags.add(item);
  void removeFromHashitags(String item) => hashitags.remove(item);
  void removeAtIndexFromHashitags(int index) => hashitags.removeAt(index);
  void insertAtIndexInHashitags(int index, String item) =>
      hashitags.insert(index, item);
  void updateHashitagsAtIndex(int index, Function(String) updateFn) =>
      hashitags[index] = updateFn(hashitags[index]);

  String? characterimage = '';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in charatercreate widget.
  CharacterRecord? editcharacter;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  bool isDataUploading_characterimagefile = false;
  FFUploadedFile uploadedLocalFile_characterimagefile =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_characterimagefile = '';

  // State field(s) for Name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for Setting widget.
  FocusNode? settingFocusNode;
  TextEditingController? settingTextController;
  String? Function(BuildContext, String?)? settingTextControllerValidator;
  // State field(s) for voice widget.
  String? voiceValue;
  FormFieldController<String>? voiceValueController;
  // State field(s) for firstgreeting widget.
  FocusNode? firstgreetingFocusNode;
  TextEditingController? firstgreetingTextController;
  String? Function(BuildContext, String?)? firstgreetingTextControllerValidator;
  bool isDataUploading_mainImageFile = false;
  FFUploadedFile uploadedLocalFile_mainImageFile =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_mainImageFile = '';

  // State field(s) for introduce widget.
  FocusNode? introduceFocusNode;
  TextEditingController? introduceTextController;
  String? Function(BuildContext, String?)? introduceTextControllerValidator;
  // State field(s) for authorComment widget.
  FocusNode? authorCommentFocusNode;
  TextEditingController? authorCommentTextController;
  String? Function(BuildContext, String?)? authorCommentTextControllerValidator;
  // State field(s) for genre widget.
  String? genreValue;
  FormFieldController<String>? genreValueController;
  // State field(s) for hashitag widget.
  FocusNode? hashitagFocusNode;
  TextEditingController? hashitagTextController;
  String? Function(BuildContext, String?)? hashitagTextControllerValidator;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  CharacterRecord? newCharacterRef;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    settingFocusNode?.dispose();
    settingTextController?.dispose();

    firstgreetingFocusNode?.dispose();
    firstgreetingTextController?.dispose();

    introduceFocusNode?.dispose();
    introduceTextController?.dispose();

    authorCommentFocusNode?.dispose();
    authorCommentTextController?.dispose();

    hashitagFocusNode?.dispose();
    hashitagTextController?.dispose();
  }
}
