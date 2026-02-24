import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'storychatpage_widget.dart' show StorychatpageWidget;
import 'package:flutter/material.dart';

class StorychatpageModel extends FlutterFlowModel<StorychatpageWidget> {
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

  StoriesRecord? currentdoc;

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

  String aiResponseScript = '\" \"';

  int requiredPoints = 0;

  bool aiModelListopen = false;

  StorychatsRecord? currentChatDoc;

  bool istyping = false;

  List<PlaceStructStruct> backgrounds = [];
  void addToBackgrounds(PlaceStructStruct item) => backgrounds.add(item);
  void removeFromBackgrounds(PlaceStructStruct item) =>
      backgrounds.remove(item);
  void removeAtIndexFromBackgrounds(int index) => backgrounds.removeAt(index);
  void insertAtIndexInBackgrounds(int index, PlaceStructStruct item) =>
      backgrounds.insert(index, item);
  void updateBackgroundsAtIndex(
          int index, Function(PlaceStructStruct) updateFn) =>
      backgrounds[index] = updateFn(backgrounds[index]);

  List<dynamic> messageAsJson = [];
  void addToMessageAsJson(dynamic item) => messageAsJson.add(item);
  void removeFromMessageAsJson(dynamic item) => messageAsJson.remove(item);
  void removeAtIndexFromMessageAsJson(int index) =>
      messageAsJson.removeAt(index);
  void insertAtIndexInMessageAsJson(int index, dynamic item) =>
      messageAsJson.insert(index, item);
  void updateMessageAsJsonAtIndex(int index, Function(dynamic) updateFn) =>
      messageAsJson[index] = updateFn(messageAsJson[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in storychatpage widget.
  StoriesRecord? loadedStory;
  // Stores action output result for [Custom Action - getRecentHistoryAsJson] action in storychatpage widget.
  List<dynamic>? messagesAsJson;
  // Stores action output result for [Custom Action - formatStoryTurnHeaderAndBg] action in storychatpage widget.
  String? pageloadformat;
  // Stores action output result for [Custom Action - processAndSaveChatTurn] action in NotifierChatList widget.
  List<StoryChatMessageStructStruct>? newMessages;
  // Stores action output result for [Custom Action - getPreviousChatHistory] action in NotifierChatList widget.
  List<dynamic>? olderMessages;
  // State field(s) for messageTextField widget.
  FocusNode? messageTextFieldFocusNode;
  TextEditingController? messageTextFieldTextController;
  String? Function(BuildContext, String?)?
      messageTextFieldTextControllerValidator;
  // Stores action output result for [Custom Action - getAndProcessHistory] action in messagesendbutton widget.
  List<dynamic>? formattedHistory;
  // Stores action output result for [Custom Action - buildHybridMemoryContext] action in messagesendbutton widget.
  String? ragContext;
  // Stores action output result for [Custom Action - compose prompt memory] action in messagesendbutton widget.
  String? promptMemory;
  // Stores action output result for [Custom Action - getPointCostAction] action in messagesendbutton widget.
  int? pointsToDeduct;
  // Stores action output result for [Custom Action - calculateCreatorEarningAction] action in messagesendbutton widget.
  int? creatorShare;
  // Stores action output result for [Custom Action - callAiProxy] action in messagesendbutton widget.
  String? aiFullText;
  // Stores action output result for [Custom Action - removeThinkingMessage] action in messagesendbutton widget.
  List<StoryChatMessageStructStruct>? cleanList;
  // Stores action output result for [Custom Action - getAndProcessHistory] action in continuebutton widget.
  List<dynamic>? formattedHistory1;
  // Stores action output result for [Custom Action - buildHybridMemoryContext] action in continuebutton widget.
  String? ragContext1;
  // Stores action output result for [Custom Action - compose prompt memory] action in continuebutton widget.
  String? promptMemory1;
  // Stores action output result for [Custom Action - getPointCostAction] action in continuebutton widget.
  int? pointsToDeduct1;
  // Stores action output result for [Custom Action - calculateCreatorEarningAction] action in continuebutton widget.
  int? creatorShare1;
  // Stores action output result for [Custom Action - getNextPhaseCommand] action in continuebutton widget.
  String? nextCommand;
  // Stores action output result for [Custom Action - callAiProxy] action in continuebutton widget.
  String? aiFullText1;
  // Stores action output result for [Custom Action - removeThinkingMessage] action in continuebutton widget.
  List<StoryChatMessageStructStruct>? cleanList1;
  // Stores action output result for [Custom Action - formatStoryTurnHeaderAndBg] action in continuebutton widget.
  String? continueformat;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    messageTextFieldFocusNode?.dispose();
    messageTextFieldTextController?.dispose();
  }
}
