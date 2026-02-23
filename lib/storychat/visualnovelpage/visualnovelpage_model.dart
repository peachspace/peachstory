import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'visualnovelpage_widget.dart' show VisualnovelpageWidget;
import 'package:flutter/material.dart';

class VisualnovelpageModel extends FlutterFlowModel<VisualnovelpageWidget> {
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

  bool isvisualmode = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in visualnovelpage widget.
  StoriesRecord? loadedStory;
  // Stores action output result for [Custom Action - getRecentHistoryAsJson] action in visualnovelpage widget.
  List<dynamic>? messagesAsJson;
  // Stores action output result for [Custom Action - formatStoryTurnHeaderAndBg] action in visualnovelpage widget.
  String? pageloadformat;
  // State field(s) for usertextField widget.
  FocusNode? usertextFieldFocusNode;
  TextEditingController? usertextFieldTextController;
  String? Function(BuildContext, String?)? usertextFieldTextControllerValidator;
  // Stores action output result for [Custom Action - processAndSaveChatTurn] action in NotifierChatList widget.
  List<StoryChatMessageStructStruct>? newMessages;
  // Stores action output result for [Custom Action - getPreviousChatHistory] action in NotifierChatList widget.
  List<dynamic>? olderMessages;
  // State field(s) for messageTextField widget.
  FocusNode? messageTextFieldFocusNode;
  TextEditingController? messageTextFieldTextController;
  String? Function(BuildContext, String?)?
      messageTextFieldTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    usertextFieldFocusNode?.dispose();
    usertextFieldTextController?.dispose();

    messageTextFieldFocusNode?.dispose();
    messageTextFieldTextController?.dispose();
  }
}
