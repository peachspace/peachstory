import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'storychat_widget.dart' show StorychatWidget;
import 'package:flutter/material.dart';

class StorychatModel extends FlutterFlowModel<StorychatWidget> {
  ///  Local state fields for this page.

  DocumentReference? currentDocRef;

  String userinput = '\" \"';

  List<StoryChatMessageStructStruct> chatMessages = [];
  void addToChatMessages(StoryChatMessageStructStruct item) =>
      chatMessages.add(item);
  void removeFromChatMessages(StoryChatMessageStructStruct item) =>
      chatMessages.remove(item);
  void removeAtIndexFromChatMessages(int index) => chatMessages.removeAt(index);
  void insertAtIndexInChatMessages(
          int index, StoryChatMessageStructStruct item) =>
      chatMessages.insert(index, item);
  void updateChatMessagesAtIndex(
          int index, Function(StoryChatMessageStructStruct) updateFn) =>
      chatMessages[index] = updateFn(chatMessages[index]);

  StoriesRecord? currentStory;

  String title = '\" \"';

  String worldview = '\" \"';

  List<CharacterStructStruct> characters = [];
  void addToCharacters(CharacterStructStruct item) => characters.add(item);
  void removeFromCharacters(CharacterStructStruct item) =>
      characters.remove(item);
  void removeAtIndexFromCharacters(int index) => characters.removeAt(index);
  void insertAtIndexInCharacters(int index, CharacterStructStruct item) =>
      characters.insert(index, item);
  void updateCharactersAtIndex(
          int index, Function(CharacterStructStruct) updateFn) =>
      characters[index] = updateFn(characters[index]);

  String userrole = '\" \"';

  String prologue = '\" \"';

  List<SituationalImageStructStruct> pageSituationalImages = [];
  void addToPageSituationalImages(SituationalImageStructStruct item) =>
      pageSituationalImages.add(item);
  void removeFromPageSituationalImages(SituationalImageStructStruct item) =>
      pageSituationalImages.remove(item);
  void removeAtIndexFromPageSituationalImages(int index) =>
      pageSituationalImages.removeAt(index);
  void insertAtIndexInPageSituationalImages(
          int index, SituationalImageStructStruct item) =>
      pageSituationalImages.insert(index, item);
  void updatePageSituationalImagesAtIndex(
          int index, Function(SituationalImageStructStruct) updateFn) =>
      pageSituationalImages[index] = updateFn(pageSituationalImages[index]);

  String aiResponseScript = '\" \"';

  int requiredPoints = 0;

  String pageSelectedModel = '\" \"';

  StorychatsRecord? currentChatDoc;

  bool istyping = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in storychat widget.
  StoriesRecord? storyDoc;
  // Stores action output result for [Firestore Query - Query a collection] action in storychat widget.
  List<StorychatsRecord>? existingChatRoom;
  // Stores action output result for [Custom Action - getHistoryAsJson] action in storychat widget.
  List<dynamic>? messagesAsJson;
  // Stores action output result for [Backend Call - Create Document] action in storychat widget.
  StorychatsRecord? newChatRef;
  // Stores action output result for [Custom Action - callAiProxy] action in storychat widget.
  String? aitext;
  // Stores action output result for [Bottom Sheet - storybottom] action in Icon widget.
  String? chosenModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - getAndProcessHistory] action in messagesendbutton widget.
  List<dynamic>? formattedHistory;
  // Stores action output result for [Backend Call - Read Document] action in messagesendbutton widget.
  StorychatsRecord? updatedChatDoc;
  // Stores action output result for [Custom Action - getPointCostAction] action in messagesendbutton widget.
  int? pointsToDeduct;
  // Stores action output result for [Custom Action - calculateCreatorEarningAction] action in messagesendbutton widget.
  int? creatorShare;
  // Stores action output result for [Custom Action - callAiProxy] action in messagesendbutton widget.
  String? aiFullText;
  // Stores action output result for [Custom Action - removeThinkingMessage] action in messagesendbutton widget.
  List<StoryChatMessageStructStruct>? cleanList;
  // Stores action output result for [Firestore Query - Query a collection] action in messagesendbutton widget.
  int? messageCount;
  // Stores action output result for [Backend Call - Read Document] action in messagesendbutton widget.
  StorychatsRecord? characterChatDoc;
  // Stores action output result for [Custom Action - callAiSummaryAction] action in messagesendbutton widget.
  String? summary;
  // Stores action output result for [Custom Action - getAndProcessHistory] action in messagesendbutton widget.
  List<dynamic>? formattedHistory1;
  // Stores action output result for [Backend Call - Read Document] action in messagesendbutton widget.
  StorychatsRecord? updatedChatDoc1;
  // Stores action output result for [Custom Action - getPointCostAction] action in messagesendbutton widget.
  int? pointsToDeduct1;
  // Stores action output result for [Custom Action - calculateCreatorEarningAction] action in messagesendbutton widget.
  int? creatorShare1;
  // Stores action output result for [Custom Action - getNextPhaseCommand] action in messagesendbutton widget.
  String? nextCommand;
  // Stores action output result for [Custom Action - callAiProxy] action in messagesendbutton widget.
  String? aiFullText1;
  // Stores action output result for [Custom Action - removeThinkingMessage] action in messagesendbutton widget.
  List<StoryChatMessageStructStruct>? cleanList1;
  // Stores action output result for [Firestore Query - Query a collection] action in messagesendbutton widget.
  int? messageCount2;
  // Stores action output result for [Backend Call - Read Document] action in messagesendbutton widget.
  StorychatsRecord? characterChatDoc1;
  // Stores action output result for [Custom Action - callAiSummaryAction] action in messagesendbutton widget.
  String? summary1;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
