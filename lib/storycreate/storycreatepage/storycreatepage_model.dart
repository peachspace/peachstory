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

  List<PlaceStructStruct> backgroundlist = [];
  void addToBackgroundlist(PlaceStructStruct item) => backgroundlist.add(item);
  void removeFromBackgroundlist(PlaceStructStruct item) =>
      backgroundlist.remove(item);
  void removeAtIndexFromBackgroundlist(int index) =>
      backgroundlist.removeAt(index);
  void insertAtIndexInBackgroundlist(int index, PlaceStructStruct item) =>
      backgroundlist.insert(index, item);
  void updateBackgroundlistAtIndex(
          int index, Function(PlaceStructStruct) updateFn) =>
      backgroundlist[index] = updateFn(backgroundlist[index]);

  String? prologuetext;

  String? currentStoryId;

  bool isgenerating = false;

  String? generatingTarget;

  String? placetext;

  String? event;

  List<EventStructStruct> eventlist = [];
  void addToEventlist(EventStructStruct item) => eventlist.add(item);
  void removeFromEventlist(EventStructStruct item) => eventlist.remove(item);
  void removeAtIndexFromEventlist(int index) => eventlist.removeAt(index);
  void insertAtIndexInEventlist(int index, EventStructStruct item) =>
      eventlist.insert(index, item);
  void updateEventlistAtIndex(
          int index, Function(EventStructStruct) updateFn) =>
      eventlist[index] = updateFn(eventlist[index]);

  String? outline;

  bool outlineSwitch = false;

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
  // State field(s) for worldSettings widget.
  FocusNode? worldSettingsFocusNode;
  TextEditingController? worldSettingsTextController;
  String? Function(BuildContext, String?)? worldSettingsTextControllerValidator;
  // State field(s) for placetextfield widget.
  FocusNode? placetextfieldFocusNode;
  TextEditingController? placetextfieldTextController;
  String? Function(BuildContext, String?)?
      placetextfieldTextControllerValidator;
  // State field(s) for placenametextField widget.
  FocusNode? placenametextFieldFocusNode;
  TextEditingController? placenametextFieldTextController;
  String? Function(BuildContext, String?)?
      placenametextFieldTextControllerValidator;
  // State field(s) for placeexplanationtextField widget.
  FocusNode? placeexplanationtextFieldFocusNode;
  TextEditingController? placeexplanationtextFieldTextController;
  String? Function(BuildContext, String?)?
      placeexplanationtextFieldTextControllerValidator;
  // State field(s) for UserRoleInfo widget.
  FocusNode? userRoleInfoFocusNode;
  TextEditingController? userRoleInfoTextController;
  String? Function(BuildContext, String?)? userRoleInfoTextControllerValidator;
  // State field(s) for charORusername widget.
  FocusNode? charORusernameFocusNode;
  TextEditingController? charORusernameTextController;
  String? Function(BuildContext, String?)?
      charORusernameTextControllerValidator;
  // State field(s) for resourcename widget.
  FocusNode? resourcenameFocusNode;
  TextEditingController? resourcenameTextController;
  String? Function(BuildContext, String?)? resourcenameTextControllerValidator;
  // State field(s) for firstvalue widget.
  FocusNode? firstvalueFocusNode;
  TextEditingController? firstvalueTextController;
  String? Function(BuildContext, String?)? firstvalueTextControllerValidator;
  // State field(s) for conditionalstatement widget.
  FocusNode? conditionalstatementFocusNode;
  TextEditingController? conditionalstatementTextController;
  String? Function(BuildContext, String?)?
      conditionalstatementTextControllerValidator;
  // State field(s) for increaseORdecrease widget.
  String? increaseORdecreaseValue;
  FormFieldController<String>? increaseORdecreaseValueController;
  // State field(s) for increaseORdecreasevalue widget.
  FocusNode? increaseORdecreasevalueFocusNode;
  TextEditingController? increaseORdecreasevalueTextController;
  String? Function(BuildContext, String?)?
      increaseORdecreasevalueTextControllerValidator;
  // State field(s) for operator widget.
  String? operatorValue;
  FormFieldController<String>? operatorValueController;
  // State field(s) for referencevalue widget.
  FocusNode? referencevalueFocusNode;
  TextEditingController? referencevalueTextController;
  String? Function(BuildContext, String?)?
      referencevalueTextControllerValidator;
  // State field(s) for effect widget.
  FocusNode? effectFocusNode;
  TextEditingController? effectTextController;
  String? Function(BuildContext, String?)? effectTextControllerValidator;
  // State field(s) for eventtextField widget.
  FocusNode? eventtextFieldFocusNode;
  TextEditingController? eventtextFieldTextController;
  String? Function(BuildContext, String?)?
      eventtextFieldTextControllerValidator;
  // State field(s) for eventexplanationtextField widget.
  FocusNode? eventexplanationtextFieldFocusNode;
  TextEditingController? eventexplanationtextFieldTextController;
  String? Function(BuildContext, String?)?
      eventexplanationtextFieldTextControllerValidator;
  // State field(s) for placedropdown widget.
  String? placedropdownValue;
  FormFieldController<String>? placedropdownValueController;
  // State field(s) for narrationtextField widget.
  FocusNode? narrationtextFieldFocusNode;
  TextEditingController? narrationtextFieldTextController;
  String? Function(BuildContext, String?)?
      narrationtextFieldTextControllerValidator;
  // State field(s) for charnameplacedropdown widget.
  String? charnameplacedropdownValue;
  FormFieldController<String>? charnameplacedropdownValueController;
  // State field(s) for emotionplacedropdown widget.
  String? emotionplacedropdownValue;
  FormFieldController<String>? emotionplacedropdownValueController;
  // State field(s) for dialoguetextField widget.
  FocusNode? dialoguetextFieldFocusNode;
  TextEditingController? dialoguetextFieldTextController;
  String? Function(BuildContext, String?)?
      dialoguetextFieldTextControllerValidator;
  // State field(s) for guidetextfield widget.
  FocusNode? guidetextfieldFocusNode;
  TextEditingController? guidetextfieldTextController;
  String? Function(BuildContext, String?)?
      guidetextfieldTextControllerValidator;
  // State field(s) for introduce widget.
  FocusNode? introduceFocusNode;
  TextEditingController? introduceTextController;
  String? Function(BuildContext, String?)? introduceTextControllerValidator;
  // State field(s) for detailinfotext widget.
  FocusNode? detailinfotextFocusNode;
  TextEditingController? detailinfotextTextController;
  String? Function(BuildContext, String?)?
      detailinfotextTextControllerValidator;
  // State field(s) for authorComment widget.
  FocusNode? authorCommentFocusNode;
  TextEditingController? authorCommentTextController;
  String? Function(BuildContext, String?)? authorCommentTextControllerValidator;
  // State field(s) for genredropdown widget.
  String? genredropdownValue;
  FormFieldController<String>? genredropdownValueController;
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

    placetextfieldFocusNode?.dispose();
    placetextfieldTextController?.dispose();

    placenametextFieldFocusNode?.dispose();
    placenametextFieldTextController?.dispose();

    placeexplanationtextFieldFocusNode?.dispose();
    placeexplanationtextFieldTextController?.dispose();

    userRoleInfoFocusNode?.dispose();
    userRoleInfoTextController?.dispose();

    charORusernameFocusNode?.dispose();
    charORusernameTextController?.dispose();

    resourcenameFocusNode?.dispose();
    resourcenameTextController?.dispose();

    firstvalueFocusNode?.dispose();
    firstvalueTextController?.dispose();

    conditionalstatementFocusNode?.dispose();
    conditionalstatementTextController?.dispose();

    increaseORdecreasevalueFocusNode?.dispose();
    increaseORdecreasevalueTextController?.dispose();

    referencevalueFocusNode?.dispose();
    referencevalueTextController?.dispose();

    effectFocusNode?.dispose();
    effectTextController?.dispose();

    eventtextFieldFocusNode?.dispose();
    eventtextFieldTextController?.dispose();

    eventexplanationtextFieldFocusNode?.dispose();
    eventexplanationtextFieldTextController?.dispose();

    narrationtextFieldFocusNode?.dispose();
    narrationtextFieldTextController?.dispose();

    dialoguetextFieldFocusNode?.dispose();
    dialoguetextFieldTextController?.dispose();

    guidetextfieldFocusNode?.dispose();
    guidetextfieldTextController?.dispose();

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
