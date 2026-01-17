import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'storycreatepage_widget.dart' show StorycreatepageWidget;
import 'package:flutter/material.dart';

class StorycreatepageModel extends FlutterFlowModel<StorycreatepageWidget> {
  ///  Local state fields for this page.

  String? mainImage;

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

  String? introduce = '';

  String? author = '';

  String? genre = '';

  bool isGeneratingtitle = false;

  bool isGeneratingworldview = false;

  bool isGeneratingprologue = false;

  bool isGeneratinguserrole = false;

  bool isGeneratingintroduce = false;

  String selectedDetailMode = 'text';

  List<CharacterStructStruct> characterlist = [];
  void addToCharacterlist(CharacterStructStruct item) =>
      characterlist.add(item);
  void removeFromCharacterlist(CharacterStructStruct item) =>
      characterlist.remove(item);
  void removeAtIndexFromCharacterlist(int index) =>
      characterlist.removeAt(index);
  void insertAtIndexInCharacterlist(int index, CharacterStructStruct item) =>
      characterlist.insert(index, item);
  void updateCharacterlistAtIndex(
          int index, Function(CharacterStructStruct) updateFn) =>
      characterlist[index] = updateFn(characterlist[index]);

  List<BackgroundStructStruct> backgroundlist = [];
  void addToBackgroundlist(BackgroundStructStruct item) =>
      backgroundlist.add(item);
  void removeFromBackgroundlist(BackgroundStructStruct item) =>
      backgroundlist.remove(item);
  void removeAtIndexFromBackgroundlist(int index) =>
      backgroundlist.removeAt(index);
  void insertAtIndexInBackgroundlist(int index, BackgroundStructStruct item) =>
      backgroundlist.insert(index, item);
  void updateBackgroundlistAtIndex(
          int index, Function(BackgroundStructStruct) updateFn) =>
      backgroundlist[index] = updateFn(backgroundlist[index]);

  String? prologueimage;

  String? prologuetext;

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
  // Stores action output result for [Custom Action - generateSingleTextField] action in storynameaicreatebutton widget.
  String? generatedtitle;
  // State field(s) for worldSettings widget.
  FocusNode? worldSettingsFocusNode;
  TextEditingController? worldSettingsTextController;
  String? Function(BuildContext, String?)? worldSettingsTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in worldviewaicreatebutton widget.
  String? generatedworldview;
  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in backgroundaddbutton widget.
  GenResultStructStruct? generatedbackgroundimage;
  // State field(s) for UserRoleInfo widget.
  FocusNode? userRoleInfoFocusNode;
  TextEditingController? userRoleInfoTextController;
  String? Function(BuildContext, String?)? userRoleInfoTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in userroleaicreatebutton widget.
  String? generateduserrole;
  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in prologueimageeditbutton widget.
  GenResultStructStruct? editedprologueimage;
  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in prologueimageaddbutton widget.
  GenResultStructStruct? generatedprologueimage;
  // State field(s) for prologuetext widget.
  FocusNode? prologuetextFocusNode;
  TextEditingController? prologuetextTextController;
  String? Function(BuildContext, String?)? prologuetextTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in prologueaicreatebutton widget.
  String? generatedprologue;
  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in addmainimagebutton widget.
  GenResultStructStruct? generatedmainimage;
  // Stores action output result for [Bottom Sheet - imagecreatebottomsheet] action in editmainimagebutton widget.
  GenResultStructStruct? editedmainimage;
  // State field(s) for introduce widget.
  FocusNode? introduceFocusNode;
  TextEditingController? introduceTextController;
  String? Function(BuildContext, String?)? introduceTextControllerValidator;
  // Stores action output result for [Custom Action - generateSingleTextField] action in storyintroaicreatebutton widget.
  String? generatedintroduce;
  // State field(s) for detailinfotext widget.
  FocusNode? detailinfotextFocusNode;
  TextEditingController? detailinfotextTextController;
  String? Function(BuildContext, String?)?
      detailinfotextTextControllerValidator;
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
  // Stores action output result for [Backend Call - Create Document] action in storycreateandeditbutton widget.
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

    userRoleInfoFocusNode?.dispose();
    userRoleInfoTextController?.dispose();

    prologuetextFocusNode?.dispose();
    prologuetextTextController?.dispose();

    introduceFocusNode?.dispose();
    introduceTextController?.dispose();

    detailinfotextFocusNode?.dispose();
    detailinfotextTextController?.dispose();

    authorCommentFocusNode?.dispose();
    authorCommentTextController?.dispose();

    hashitagFocusNode?.dispose();
    hashitagTextController?.dispose();
  }
}
