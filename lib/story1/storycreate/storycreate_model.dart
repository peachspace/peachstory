import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'storycreate_widget.dart' show StorycreateWidget;
import 'package:flutter/material.dart';

class StorycreateModel extends FlutterFlowModel<StorycreateWidget> {
  ///  Local state fields for this page.

  String? tempmainImage = '';

  List<String> hashitags = [];
  void addToHashitags(String item) => hashitags.add(item);
  void removeFromHashitags(String item) => hashitags.remove(item);
  void removeAtIndexFromHashitags(int index) => hashitags.removeAt(index);
  void insertAtIndexInHashitags(int index, String item) =>
      hashitags.insert(index, item);
  void updateHashitagsAtIndex(int index, Function(String) updateFn) =>
      hashitags[index] = updateFn(hashitags[index]);

  String? title = '';

  String? worldview = '';

  String? userrole = '';

  String? prologue = '';

  String? introduce = '';

  String? author = '';

  String? genre = '';

  List<SituationalImageStructStruct> newSituationalImages = [];
  void addToNewSituationalImages(SituationalImageStructStruct item) =>
      newSituationalImages.add(item);
  void removeFromNewSituationalImages(SituationalImageStructStruct item) =>
      newSituationalImages.remove(item);
  void removeAtIndexFromNewSituationalImages(int index) =>
      newSituationalImages.removeAt(index);
  void insertAtIndexInNewSituationalImages(
          int index, SituationalImageStructStruct item) =>
      newSituationalImages.insert(index, item);
  void updateNewSituationalImagesAtIndex(
          int index, Function(SituationalImageStructStruct) updateFn) =>
      newSituationalImages[index] = updateFn(newSituationalImages[index]);

  bool isGeneratingtitle = false;

  bool isGeneratingworldview = false;

  bool isGeneratingprologue = false;

  bool isGeneratinguserrole = false;

  bool isGeneratingintroduce = false;

  String selectedDetailMode = 'text';

  String? uploadedIntroImage;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for storyName widget.
  FocusNode? storyNameFocusNode;
  TextEditingController? storyNameTextController;
  String? Function(BuildContext, String?)? storyNameTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? generatedtitle;
  // State field(s) for worldSettings widget.
  FocusNode? worldSettingsFocusNode;
  TextEditingController? worldSettingsTextController;
  String? Function(BuildContext, String?)? worldSettingsTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? generatedworldview;
  // State field(s) for prologue widget.
  FocusNode? prologueFocusNode;
  TextEditingController? prologueTextController;
  String? Function(BuildContext, String?)? prologueTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? generatedprologue;
  // State field(s) for UserRoleInfo widget.
  FocusNode? userRoleInfoFocusNode;
  TextEditingController? userRoleInfoTextController;
  String? Function(BuildContext, String?)? userRoleInfoTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? generateduserrole;
  // Stores action output result for [Bottom Sheet - imagecreate] action in Button widget.
  String? createdImage;
  bool isDataUploading_uploadedMainImage = false;
  FFUploadedFile uploadedLocalFile_uploadedMainImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadedMainImage = '';

  // State field(s) for introduce widget.
  FocusNode? introduceFocusNode;
  TextEditingController? introduceTextController;
  String? Function(BuildContext, String?)? introduceTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in Container widget.
  String? generatedintroduce;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  bool isDataUploading_uploadDatadetail = false;
  FFUploadedFile uploadedLocalFile_uploadDatadetail =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDatadetail = '';

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
  StoriesRecord? newStoryRef;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    storyNameFocusNode?.dispose();
    storyNameTextController?.dispose();

    worldSettingsFocusNode?.dispose();
    worldSettingsTextController?.dispose();

    prologueFocusNode?.dispose();
    prologueTextController?.dispose();

    userRoleInfoFocusNode?.dispose();
    userRoleInfoTextController?.dispose();

    introduceFocusNode?.dispose();
    introduceTextController?.dispose();

    textFieldFocusNode?.dispose();
    textController6?.dispose();

    authorCommentFocusNode?.dispose();
    authorCommentTextController?.dispose();

    hashitagFocusNode?.dispose();
    hashitagTextController?.dispose();
  }
}
