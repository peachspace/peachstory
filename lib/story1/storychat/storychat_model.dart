import '/auth/base_auth_user_provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared/login/login_widget.dart';
import '/story1/storybottom/storybottom_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'storychat_widget.dart' show StorychatWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

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

  List<LocationBackgroundStructStruct> pageBackgrounds = [];
  void addToPageBackgrounds(LocationBackgroundStructStruct item) =>
      pageBackgrounds.add(item);
  void removeFromPageBackgrounds(LocationBackgroundStructStruct item) =>
      pageBackgrounds.remove(item);
  void removeAtIndexFromPageBackgrounds(int index) =>
      pageBackgrounds.removeAt(index);
  void insertAtIndexInPageBackgrounds(
          int index, LocationBackgroundStructStruct item) =>
      pageBackgrounds.insert(index, item);
  void updatePageBackgroundsAtIndex(
          int index, Function(LocationBackgroundStructStruct) updateFn) =>
      pageBackgrounds[index] = updateFn(pageBackgrounds[index]);

  String currentBackground = '\" \"';

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
  // Stores action output result for [Firestore Query - Query a collection] action in messagesendbutton widget.
  int? messageCount;
  // Stores action output result for [Backend Call - Read Document] action in messagesendbutton widget.
  StorychatsRecord? characterChatDoc;
  // Stores action output result for [Firestore Query - Query a collection] action in messagesendbutton widget.
  List<StorymessagesRecord>? messagesToSummarize;
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
