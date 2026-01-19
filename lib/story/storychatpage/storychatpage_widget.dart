import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared/loginpage/loginpage_widget.dart';
import '/story/storychatsettingcomponent/storychatsettingcomponent_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'storychatpage_model.dart';
export 'storychatpage_model.dart';

class StorychatpageWidget extends StatefulWidget {
  const StorychatpageWidget({
    super.key,
    this.storyRef,
    this.storychatRef,
    required this.userInChatName,
    this.isNovelMode,
  });

  final DocumentReference? storyRef;
  final DocumentReference? storychatRef;
  final String? userInChatName;
  final bool? isNovelMode;

  static String routeName = 'storychatpage';
  static String routePath = '/storychatpage';

  @override
  State<StorychatpageWidget> createState() => _StorychatpageWidgetState();
}

class _StorychatpageWidgetState extends State<StorychatpageWidget>
    with TickerProviderStateMixin {
  late StorychatpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StorychatpageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.messagesAsJson = await actions.getRecentHistoryAsJson(
        widget.storychatRef!,
        30,
      );
      _model.chatMessages = functions
          .mapJsonToStoryChatStructs(_model.messagesAsJson!.toList())
          .toList()
          .cast<StoryChatMessageStructStruct>();
      safeSetState(() {});
    });

    _model.messageTextFieldTextController ??= TextEditingController();
    _model.messageTextFieldFocusNode ??= FocusNode();

    animationsMap.addAll({
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 1000.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'iconButtonOnPageLoadAnimation': AnimationInfo(
        loop: true,
        reverse: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeIn,
            delay: 0.0.ms,
            duration: 900.0.ms,
            begin: 0.4,
            end: 0.8,
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StoriesRecord>(
      stream: StoriesRecord.getDocument(widget.storyRef!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final storychatpageStoriesRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              iconTheme: IconThemeData(
                  color: FlutterFlowTheme.of(context).primaryText),
              automaticallyImplyLeading: false,
              leading: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(ChatlistpageWidget.routeName);
                },
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 20.0,
                ),
              ),
              title: Text(
                valueOrDefault<String>(
                  _model.title,
                  'PEACHSTORY',
                ),
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).tertiary,
                      fontSize: 18.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
              ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation']!),
              actions: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 25.0, 15.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: StorychatsettingcomponentWidget(
                                storychatRef: _model.currentDocRef!,
                                currentSelectedModel: _model.pageSelectedModel,
                              ),
                            ),
                          );
                        },
                      ).then((value) =>
                          safeSetState(() => _model.chosenModel = value));

                      if (_model.chosenModel != null &&
                          _model.chosenModel != '') {
                        _model.pageSelectedModel = _model.chosenModel!;
                        safeSetState(() {});
                      }

                      safeSetState(() {});
                    },
                    child: Icon(
                      Icons.settings_outlined,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
              centerTitle: true,
              elevation: 0.0,
            ),
            body: SafeArea(
              top: true,
              child: StreamBuilder<StorychatsRecord>(
                stream: StorychatsRecord.getDocument(widget.storychatRef!),
                builder: (context, snapshot) {
                  // Customize what your widget looks like when it's loading.
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    );
                  }

                  final stackStorychatsRecord = snapshot.data!;

                  return Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    25.0, 0.0, 25.0, 0.0),
                                child: custom_widgets.NotifierChatList(
                                  width: double.infinity,
                                  height: double.infinity,
                                  newResponseScript: _model.aiResponseScript,
                                  userInChatName: widget.userInChatName,
                                  isNovelMode: false,
                                  initialMessages: _model.chatMessages,
                                  preDefinedCharacters:
                                      storychatpageStoriesRecord.characters,
                                  backgroundList:
                                      storychatpageStoriesRecord.backgrounds,
                                  onTurnComplete: (scenes) async {
                                    _model.newMessages =
                                        await actions.processAndSaveChatTurn(
                                      scenes!.toList(),
                                      stackStorychatsRecord.reference,
                                      storychatpageStoriesRecord.backgrounds
                                          .toList(),
                                      storychatpageStoriesRecord.characters
                                          .toList(),
                                    );
                                    _model.chatMessages = functions
                                        .mergeChatLists(
                                            _model.chatMessages.toList(),
                                            _model.newMessages?.toList())
                                        .toList()
                                        .cast<StoryChatMessageStructStruct>();
                                    safeSetState(() {});

                                    await stackStorychatsRecord.reference
                                        .update({
                                      ...mapToFirestore(
                                        {
                                          'messageCount':
                                              FieldValue.increment(1),
                                        },
                                      ),
                                    });
                                    if (functions
                                        .isSummaryTurn(valueOrDefault<int>(
                                              stackStorychatsRecord
                                                  .messageCount,
                                              0,
                                            ) +
                                            1)) {
                                      await stackStorychatsRecord.reference
                                          .update(createStorychatsRecordData(
                                        lastSummaryMessageCount:
                                            valueOrDefault<int>(
                                                  stackStorychatsRecord
                                                      .messageCount,
                                                  0,
                                                ) +
                                                1,
                                      ));
                                    }
                                    _model.aiResponseScript = '';
                                    safeSetState(() {});

                                    safeSetState(() {});
                                  },
                                  onLoadOlderMessages: () async {
                                    _model.olderMessages =
                                        await actions.getPreviousChatHistory(
                                      stackStorychatsRecord.reference,
                                      _model.messageAsJson.toList(),
                                      30,
                                    );
                                    _model.messageAsJson = functions
                                        .combineJsonLists(
                                            _model.olderMessages?.toList(),
                                            _model.messageAsJson.toList())
                                        .toList()
                                        .cast<dynamic>();
                                    safeSetState(() {});

                                    safeSetState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                          if (widget.isNovelMode == false)
                            Align(
                              alignment: AlignmentDirectional(0.0, 1.0),
                              child: SafeArea(
                                child: Container(
                                  width: double.infinity,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFF8F9),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: Color(0x33000000),
                                        offset: Offset(
                                          0.0,
                                          2.0,
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(30.0),
                                      topRight: Radius.circular(30.0),
                                    ),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                    ),
                                  ),
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            25.0, 0.0, 25.0, 0.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 50.0,
                                          decoration: BoxDecoration(),
                                          child: Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller: _model
                                                  .messageTextFieldTextController,
                                              focusNode: _model
                                                  .messageTextFieldFocusNode,
                                              autofocus: false,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                hintText:
                                                    '인물의 대사나 행동을 입력하세요...',
                                                hintStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF606A85),
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                focusedErrorBorder:
                                                    InputBorder.none,
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            Color(0xFF15161E),
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                              maxLines: null,
                                              maxLength: 200,
                                              maxLengthEnforcement:
                                                  MaxLengthEnforcement.enforced,
                                              buildCounter: (context,
                                                      {required currentLength,
                                                      required isFocused,
                                                      maxLength}) =>
                                                  null,
                                              validator: _model
                                                  .messageTextFieldTextControllerValidator
                                                  .asValidator(context),
                                              inputFormatters: [
                                                if (!isAndroid && !isiOS)
                                                  TextInputFormatter
                                                      .withFunction(
                                                          (oldValue, newValue) {
                                                    return TextEditingValue(
                                                      selection:
                                                          newValue.selection,
                                                      text: newValue.text
                                                          .toCapitalization(
                                                              TextCapitalization
                                                                  .sentences),
                                                    );
                                                  }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 25.0, 0.0),
                                            child: FlutterFlowIconButton(
                                              borderRadius: 10.0,
                                              buttonSize: 35.0,
                                              fillColor: Color(0xFFFFD1BA),
                                              icon: Icon(
                                                Icons.send,
                                                color: Colors.white,
                                                size: 20.0,
                                              ),
                                              showLoadingIndicator: true,
                                              onPressed:
                                                  (currentUserReference == null)
                                                      ? null
                                                      : () async {
                                                          final firestoreBatch =
                                                              FirebaseFirestore.instanceFor(
                                                                      app: Firebase
                                                                          .app(),
                                                                      databaseId:
                                                                          '(default)')
                                                                  .batch();
                                                          try {
                                                            if (loggedIn) {
                                                              _model.addToChatMessages(
                                                                  StoryChatMessageStructStruct(
                                                                text: _model
                                                                    .messageTextFieldTextController
                                                                    .text,
                                                                type: 'user',
                                                              ));
                                                              safeSetState(
                                                                  () {});
                                                              _model.userinput =
                                                                  _model
                                                                      .messageTextFieldTextController
                                                                      .text;
                                                              safeSetState(
                                                                  () {});

                                                              firestoreBatch
                                                                  .set(
                                                                      StorymessagesRecord.createDoc(
                                                                          stackStorychatsRecord
                                                                              .reference),
                                                                      createStorymessagesRecordData(
                                                                        timestamp:
                                                                            getCurrentTimestamp,
                                                                        text: _model
                                                                            .userinput,
                                                                        type:
                                                                            'user',
                                                                        speakerName:
                                                                            widget.userInChatName,
                                                                        userRef:
                                                                            currentUserReference,
                                                                      ));
                                                              _model.addToChatMessages(
                                                                  StoryChatMessageStructStruct(
                                                                text: '생각 중',
                                                                type:
                                                                    'thinking',
                                                              ));
                                                              safeSetState(
                                                                  () {});
                                                              safeSetState(() {
                                                                _model
                                                                    .messageTextFieldTextController
                                                                    ?.clear();
                                                              });
                                                              _model.formattedHistory =
                                                                  await actions
                                                                      .getAndProcessHistory(
                                                                widget
                                                                    .storychatRef,
                                                              );
                                                              _model.pointsToDeduct =
                                                                  await actions
                                                                      .getPointCostAction(
                                                                stackStorychatsRecord
                                                                    .selectedAiModel,
                                                              );
                                                              _model.creatorShare =
                                                                  await actions
                                                                      .calculateCreatorEarningAction(
                                                                stackStorychatsRecord
                                                                    .selectedAiModel,
                                                              );
                                                              if (valueOrDefault(
                                                                      currentUserDocument
                                                                          ?.points,
                                                                      0) >=
                                                                  _model
                                                                      .pointsToDeduct!) {
                                                                firestoreBatch
                                                                    .update(
                                                                        currentUserReference!,
                                                                        {
                                                                      ...mapToFirestore(
                                                                        {
                                                                          'points':
                                                                              FieldValue.increment(-(_model.pointsToDeduct!)),
                                                                        },
                                                                      ),
                                                                    });
                                                                if (currentUserReference !=
                                                                    stackStorychatsRecord
                                                                        .creatorRef) {
                                                                  firestoreBatch.update(
                                                                      stackStorychatsRecord
                                                                          .creatorRef!,
                                                                      {
                                                                        ...mapToFirestore(
                                                                          {
                                                                            'earnings':
                                                                                FieldValue.increment(_model.creatorShare!),
                                                                          },
                                                                        ),
                                                                      });
                                                                }
                                                                _model.aiFullText =
                                                                    await actions
                                                                        .callAiProxy(
                                                                  valueOrDefault<
                                                                      String>(
                                                                    stackStorychatsRecord
                                                                        .selectedAiModel,
                                                                    'gpt-4o',
                                                                  ),
                                                                  functions.buildStoryPrompt(
                                                                      storychatpageStoriesRecord
                                                                          .title,
                                                                      storychatpageStoriesRecord
                                                                          .worldview,
                                                                      storychatpageStoriesRecord
                                                                          .characters
                                                                          .toList(),
                                                                      storychatpageStoriesRecord
                                                                          .userRole,
                                                                      storychatpageStoriesRecord
                                                                          .backgrounds
                                                                          .toList(),
                                                                      stackStorychatsRecord
                                                                          .userNote,
                                                                      widget
                                                                          .userInChatName!,
                                                                      stackStorychatsRecord
                                                                          .summary,
                                                                      widget
                                                                          .isNovelMode!),
                                                                  _model
                                                                      .formattedHistory
                                                                      ?.toList(),
                                                                  _model
                                                                      .userinput,
                                                                );
                                                                _model.cleanList =
                                                                    await actions
                                                                        .removeThinkingMessage(
                                                                  _model
                                                                      .chatMessages
                                                                      .toList(),
                                                                );
                                                                _model.chatMessages = _model
                                                                    .cleanList!
                                                                    .toList()
                                                                    .cast<
                                                                        StoryChatMessageStructStruct>();
                                                                safeSetState(
                                                                    () {});
                                                                if (_model
                                                                        .aiFullText ==
                                                                    'BLOCKED_CONTENT') {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        '부적절한 내용이라 답변할 수 없습니다.',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
                                                                        ),
                                                                      ),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              2000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .info,
                                                                    ),
                                                                  );
                                                                } else {
                                                                  _model.aiResponseScript =
                                                                      _model
                                                                          .aiFullText!;
                                                                  safeSetState(
                                                                      () {});
                                                                }
                                                              } else {
                                                                var confirmDialogResponse =
                                                                    await showDialog<
                                                                            bool>(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (alertDialogContext) {
                                                                            return AlertDialog(
                                                                              title: Text('피치 부족'),
                                                                              content: Text('피치가 부족합니다. 충전하시겠습니까?'),
                                                                              actions: [
                                                                                TextButton(
                                                                                  onPressed: () => Navigator.pop(alertDialogContext, false),
                                                                                  child: Text('이동'),
                                                                                ),
                                                                                TextButton(
                                                                                  onPressed: () => Navigator.pop(alertDialogContext, true),
                                                                                  child: Text('취소'),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          },
                                                                        ) ??
                                                                        false;
                                                              }
                                                            } else {
                                                              await showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                enableDrag:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return GestureDetector(
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
                                                                      child:
                                                                          LoginpageWidget(),
                                                                    ),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            }
                                                          } finally {
                                                            await firestoreBatch
                                                                .commit();
                                                          }

                                                          safeSetState(() {});
                                                        },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (widget.isNovelMode == true)
                        Align(
                          alignment: AlignmentDirectional(1.0, 1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 25.0, 15.0),
                            child: FlutterFlowIconButton(
                              borderRadius: 10.0,
                              buttonSize: 35.0,
                              fillColor: Color(0xFFFFD1BA),
                              icon: Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              showLoadingIndicator: true,
                              onPressed: (currentUserReference == null)
                                  ? null
                                  : () async {
                                      final firestoreBatch =
                                          FirebaseFirestore.instanceFor(
                                                  app: Firebase.app(),
                                                  databaseId: '(default)')
                                              .batch();
                                      try {
                                        if (loggedIn) {
                                          _model.aiResponseScript = '';
                                          safeSetState(() {});
                                          _model.istyping = true;
                                          safeSetState(() {});
                                          _model.addToChatMessages(
                                              StoryChatMessageStructStruct(
                                            text: '생각 중',
                                            type: 'thinking',
                                          ));
                                          safeSetState(() {});
                                          safeSetState(() {
                                            _model
                                                .messageTextFieldTextController
                                                ?.clear();
                                          });
                                          _model.formattedHistory1 =
                                              await actions
                                                  .getAndProcessHistory(
                                            widget.storychatRef,
                                          );
                                          _model.pointsToDeduct1 =
                                              await actions.getPointCostAction(
                                            stackStorychatsRecord
                                                .selectedAiModel,
                                          );
                                          _model.creatorShare1 = await actions
                                              .calculateCreatorEarningAction(
                                            stackStorychatsRecord
                                                .selectedAiModel,
                                          );
                                          if (valueOrDefault(
                                                  currentUserDocument?.points,
                                                  0) >=
                                              _model.pointsToDeduct1!) {
                                            firestoreBatch
                                                .update(currentUserReference!, {
                                              ...mapToFirestore(
                                                {
                                                  'points': FieldValue
                                                      .increment(-(_model
                                                          .pointsToDeduct1!)),
                                                },
                                              ),
                                            });
                                            if (currentUserReference !=
                                                stackStorychatsRecord
                                                    .creatorRef) {
                                              firestoreBatch.update(
                                                  stackStorychatsRecord
                                                      .creatorRef!,
                                                  {
                                                    ...mapToFirestore(
                                                      {
                                                        'earnings': FieldValue
                                                            .increment(_model
                                                                .creatorShare1!),
                                                      },
                                                    ),
                                                  });
                                            }
                                            _model.nextCommand = await actions
                                                .getNextPhaseCommand(
                                              _model.chatMessages.length,
                                            );
                                            _model.aiFullText1 =
                                                await actions.callAiProxy(
                                              valueOrDefault<String>(
                                                stackStorychatsRecord
                                                    .selectedAiModel,
                                                'gpt-4o',
                                              ),
                                              functions.buildStoryPrompt(
                                                  storychatpageStoriesRecord
                                                      .title,
                                                  storychatpageStoriesRecord
                                                      .worldview,
                                                  storychatpageStoriesRecord
                                                      .characters
                                                      .toList(),
                                                  storychatpageStoriesRecord
                                                      .userRole,
                                                  storychatpageStoriesRecord
                                                      .backgrounds
                                                      .toList(),
                                                  stackStorychatsRecord
                                                      .userNote,
                                                  widget.userInChatName!,
                                                  stackStorychatsRecord.summary,
                                                  widget.isNovelMode!),
                                              _model.formattedHistory1
                                                  ?.toList(),
                                              _model.nextCommand,
                                            );
                                            _model.cleanList1 = await actions
                                                .removeThinkingMessage(
                                              _model.chatMessages.toList(),
                                            );
                                            _model.chatMessages = _model
                                                .cleanList1!
                                                .toList()
                                                .cast<
                                                    StoryChatMessageStructStruct>();
                                            safeSetState(() {});
                                            if (_model.aiFullText1 ==
                                                'BLOCKED_CONTENT') {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '부적절한 내용이라 답변할 수 없습니다.',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                    ),
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 2000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .info,
                                                ),
                                              );
                                            } else {
                                              _model.aiResponseScript =
                                                  _model.aiFullText1!;
                                              safeSetState(() {});
                                            }
                                          } else {
                                            var confirmDialogResponse =
                                                await showDialog<bool>(
                                                      context: context,
                                                      builder:
                                                          (alertDialogContext) {
                                                        return AlertDialog(
                                                          title: Text('피치 부족'),
                                                          content: Text(
                                                              '피치가 부족합니다. 충전하시겠습니까?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      alertDialogContext,
                                                                      false),
                                                              child: Text('이동'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      alertDialogContext,
                                                                      true),
                                                              child: Text('취소'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ) ??
                                                    false;
                                          }
                                        } else {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: LoginpageWidget(),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        }
                                      } finally {
                                        await firestoreBatch.commit();
                                      }

                                      safeSetState(() {});
                                    },
                            ).animateOnPageLoad(animationsMap[
                                'iconButtonOnPageLoadAnimation']!),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
