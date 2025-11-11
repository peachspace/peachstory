import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'characterchat_widget.dart' show CharacterchatWidget;
import 'package:flutter/material.dart';

class CharacterchatModel extends FlutterFlowModel<CharacterchatWidget> {
  ///  Local state fields for this page.

  DocumentReference? currentDocRef;

  String? userinput = '';

  List<CharacterChatMessageStructStruct> chatMessages = [];
  void addToChatMessages(CharacterChatMessageStructStruct item) =>
      chatMessages.add(item);
  void removeFromChatMessages(CharacterChatMessageStructStruct item) =>
      chatMessages.remove(item);
  void removeAtIndexFromChatMessages(int index) => chatMessages.removeAt(index);
  void insertAtIndexInChatMessages(
          int index, CharacterChatMessageStructStruct item) =>
      chatMessages.insert(index, item);
  void updateChatMessagesAtIndex(
          int index, Function(CharacterChatMessageStructStruct) updateFn) =>
      chatMessages[index] = updateFn(chatMessages[index]);

  CharacterRecord? currentCharacter;

  String? name;

  String? setting;

  List<String> dialogueExample = [];
  void addToDialogueExample(String item) => dialogueExample.add(item);
  void removeFromDialogueExample(String item) => dialogueExample.remove(item);
  void removeAtIndexFromDialogueExample(int index) =>
      dialogueExample.removeAt(index);
  void insertAtIndexInDialogueExample(int index, String item) =>
      dialogueExample.insert(index, item);
  void updateDialogueExampleAtIndex(int index, Function(String) updateFn) =>
      dialogueExample[index] = updateFn(dialogueExample[index]);

  String aiResponseScript = '\" \"';

  List<SituationalImageStructStruct> situation = [];
  void addToSituation(SituationalImageStructStruct item) => situation.add(item);
  void removeFromSituation(SituationalImageStructStruct item) =>
      situation.remove(item);
  void removeAtIndexFromSituation(int index) => situation.removeAt(index);
  void insertAtIndexInSituation(int index, SituationalImageStructStruct item) =>
      situation.insert(index, item);
  void updateSituationAtIndex(
          int index, Function(SituationalImageStructStruct) updateFn) =>
      situation[index] = updateFn(situation[index]);

  String pageSelectedModel = '\" \"';

  CharacterchatsRecord? currentChatDoc;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in characterchat widget.
  CharacterRecord? characterDoc;
  // Stores action output result for [Firestore Query - Query a collection] action in characterchat widget.
  List<CharacterchatsRecord>? existingChatlist;
  // Stores action output result for [Custom Action - getCharacterHistoryAsJson] action in characterchat widget.
  List<dynamic>? messagesAsJson;
  // Stores action output result for [Backend Call - Create Document] action in characterchat widget.
  CharacterchatsRecord? newChatRef;
  // Stores action output result for [Bottom Sheet - characterbottom] action in Icon widget.
  String? chosenModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<CharactermessagesRecord>? chatHistory;
  // Stores action output result for [Custom Action - getCharacterHistoryAsJson] action in messagesendbutton widget.
  List<dynamic>? formattedHistory;
  // Stores action output result for [Backend Call - Read Document] action in messagesendbutton widget.
  CharacterchatsRecord? updatedChatDoc;
  // Stores action output result for [Custom Action - getPointCostAction] action in messagesendbutton widget.
  int? pointsToDeduct;
  // Stores action output result for [Custom Action - calculateCreatorEarningAction] action in messagesendbutton widget.
  int? creatorShare;
  // Stores action output result for [Custom Action - callAiProxy] action in messagesendbutton widget.
  String? aiFullResponse;
  // Stores action output result for [Firestore Query - Query a collection] action in messagesendbutton widget.
  int? messageCount;
  // Stores action output result for [Backend Call - Read Document] action in messagesendbutton widget.
  CharacterchatsRecord? characterChatDoc;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
