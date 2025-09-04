import '/auth/base_auth_user_provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/character/characterbottom/characterbottom_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared/login/login_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'characterchat_widget.dart' show CharacterchatWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

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
  // Stores action output result for [Backend Call - API (getInnerThought)] action in Button widget.
  ApiCallResponse? apiResultInnerThought;
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
  // Stores action output result for [Firestore Query - Query a collection] action in messagesendbutton widget.
  List<CharactermessagesRecord>? messagesToSummarize;
  // Stores action output result for [Backend Call - API (groqsummary)] action in messagesendbutton widget.
  ApiCallResponse? summary;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
