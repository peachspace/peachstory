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

  String selectedDetailMode = 'text';

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

  String? prologuetext;

  String? currentStoryId;

  bool isgenerating = false;

  String? generatingTarget;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for genre widget.
  String? genreValue;
  FormFieldController<String>? genreValueController;
  // State field(s) for worldSettings widget.
  FocusNode? worldSettingsFocusNode;
  TextEditingController? worldSettingsTextController;
  String? Function(BuildContext, String?)? worldSettingsTextControllerValidator;
  // Stores action output result for [Custom Action - generateWorldText] action in worldviewgenbutton widget.
  String? generatedworldview;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in backgroundaddbutton widget.
  GenResultStructStruct? generatedbackgroundimage;
  // State field(s) for UserRoleInfo widget.
  FocusNode? userRoleInfoFocusNode;
  TextEditingController? userRoleInfoTextController;
  String? Function(BuildContext, String?)? userRoleInfoTextControllerValidator;
  // Stores action output result for [Custom Action - generateCharacterField] action in userrolegenbutton widget.
  String? generateduserrole;
  // State field(s) for prologuetext widget.
  FocusNode? prologuetextFocusNode;
  TextEditingController? prologuetextTextController;
  String? Function(BuildContext, String?)? prologuetextTextControllerValidator;
  // Stores action output result for [Custom Action - generatePrologueField] action in prologuegenbutton widget.
  String? generatedprologue;
  // State field(s) for storyName widget.
  FocusNode? storyNameFocusNode;
  TextEditingController? storyNameTextController;
  String? Function(BuildContext, String?)? storyNameTextControllerValidator;
  // Stores action output result for [Custom Action - generateMetaFields] action in titlegenbutton widget.
  String? generatedtitle;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in addmainimagebutton widget.
  GenResultStructStruct? generatedmainimage;
  // Stores action output result for [Bottom Sheet - SourceSelectSheet] action in editmainimagebutton widget.
  GenResultStructStruct? editmainimage;
  // State field(s) for introduce widget.
  FocusNode? introduceFocusNode;
  TextEditingController? introduceTextController;
  String? Function(BuildContext, String?)? introduceTextControllerValidator;
  // Stores action output result for [Custom Action - generateMetaFields] action in storyintrogenbutton widget.
  String? generatedintroduce;
  // State field(s) for detailinfotext widget.
  FocusNode? detailinfotextFocusNode;
  TextEditingController? detailinfotextTextController;
  String? Function(BuildContext, String?)?
      detailinfotextTextControllerValidator;
  // Stores action output result for [Custom Action - generateMetaFields] action in storydetalilgenbutton widget.
  String? generateddetail;
  // State field(s) for authorComment widget.
  FocusNode? authorCommentFocusNode;
  TextEditingController? authorCommentTextController;
  String? Function(BuildContext, String?)? authorCommentTextControllerValidator;
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
    worldSettingsFocusNode?.dispose();
    worldSettingsTextController?.dispose();

    userRoleInfoFocusNode?.dispose();
    userRoleInfoTextController?.dispose();

    prologuetextFocusNode?.dispose();
    prologuetextTextController?.dispose();

    storyNameFocusNode?.dispose();
    storyNameTextController?.dispose();

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
