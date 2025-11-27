import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared/login/login_widget.dart';
import '/story1/storybottom/storybottom_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'storychat_model.dart';
export 'storychat_model.dart';

class StorychatWidget extends StatefulWidget {
  const StorychatWidget({
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

  static String routeName = 'storychat';
  static String routePath = '/storychat';

  @override
  State<StorychatWidget> createState() => _StorychatWidgetState();
}

class _StorychatWidgetState extends State<StorychatWidget>
    with TickerProviderStateMixin {
  late StorychatModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StorychatModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.storyDoc = await StoriesRecord.getDocumentOnce(widget.storyRef!);
      _model.currentStory = _model.storyDoc;
      _model.title = valueOrDefault<String>(
        _model.storyDoc?.title,
        '무제',
      );
      _model.worldview = valueOrDefault<String>(
        _model.storyDoc?.worldview,
        '무제',
      );
      _model.characters =
          _model.storyDoc!.characters.toList().cast<CharacterStructStruct>();
      _model.userrole = valueOrDefault<String>(
        _model.storyDoc?.userRole,
        '무제',
      );
      _model.prologue = valueOrDefault<String>(
        _model.storyDoc?.prologue,
        '무제',
      );
      _model.pageSituationalImages = _model.storyDoc!.situationalImages
          .toList()
          .cast<SituationalImageStructStruct>();
      _model.pageSelectedModel = valueOrDefault<String>(
        _model.storyDoc?.aiModel,
        'claude-3-haiku-20240307',
      );
      safeSetState(() {});
      _model.existingChatRoom = await queryStorychatsRecordOnce(
        queryBuilder: (storychatsRecord) => storychatsRecord
            .where(
              'user_ref',
              isEqualTo: currentUserReference,
            )
            .where(
              'story_ref',
              isEqualTo: widget.storyRef,
            ),
      );
      if (_model.existingChatRoom!.length > 0) {
        _model.currentDocRef = _model.existingChatRoom?.firstOrNull?.reference;
        _model.pageSelectedModel =
            _model.existingChatRoom!.firstOrNull!.selectedAiModel;
        safeSetState(() {});
        _model.messagesAsJson = await actions.getHistoryAsJson(
          _model.currentDocRef,
        );
        _model.chatMessages = functions
            .mapJsonToStoryChatStructs(_model.messagesAsJson!.toList())
            .toList()
            .cast<StoryChatMessageStructStruct>();
        safeSetState(() {});
      } else {
        var storychatsRecordReference = StorychatsRecord.collection.doc();
        await storychatsRecordReference.set(createStorychatsRecordData(
          userRef: currentUserReference,
          lastSummaryMessageCount: 0,
          storyRef: widget.storyRef,
          userInChatName: widget.userInChatName,
          selectedAiModel: 'claude-3-haiku-20240307',
        ));
        _model.newChatRef = StorychatsRecord.getDocumentFromData(
            createStorychatsRecordData(
              userRef: currentUserReference,
              lastSummaryMessageCount: 0,
              storyRef: widget.storyRef,
              userInChatName: widget.userInChatName,
              selectedAiModel: 'claude-3-haiku-20240307',
            ),
            storychatsRecordReference);
        _model.currentDocRef = _model.newChatRef?.reference;
        _model.pageSelectedModel = 'claude-3-haiku-20240307';
        safeSetState(() {});
        _model.aitext = await actions.callAiProxy(
          _model.pageSelectedModel,
          functions.buildStoryPrompt(
              _model.title,
              _model.worldview,
              _model.characters.toList(),
              _model.userrole,
              _model.prologue,
              _model.pageSituationalImages.toList(),
              '',
              widget.userInChatName!,
              _model.updatedChatDoc?.summary),
          functions.prologue('도입부를 생성하라.').toList(),
          '',
        );
        _model.aiResponseScript = _model.aitext!;
        safeSetState(() {});
      }
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

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
          iconTheme:
              IconThemeData(color: FlutterFlowTheme.of(context).primaryText),
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(ChatlistWidget.routeName);
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
                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                ),
          ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation']!),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 25.0, 15.0),
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
                      return WebViewAware(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: StorybottomWidget(
                              storychatRef: _model.currentDocRef!,
                              currentSelectedModel: _model.pageSelectedModel,
                            ),
                          ),
                        ),
                      );
                    },
                  ).then((value) =>
                      safeSetState(() => _model.chosenModel = value));

                  if (_model.chosenModel != null && _model.chosenModel != '') {
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
          child: Stack(
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
                          initialMessages: _model.chatMessages,
                          preDefinedCharacters: _model.characters,
                          userInChatName: widget.userInChatName,
                          situationalImageList: _model.pageSituationalImages,
                          onTurnComplete: (scenes) async {
                            for (int loop1Index = 0;
                                loop1Index < scenes!.length;
                                loop1Index++) {
                              final currentLoop1Item = scenes[loop1Index];
                              if (functions.isSceneType(
                                      currentLoop1Item, 'dialogue') ==
                                  true) {
                                await StorymessagesRecord.createDoc(
                                        _model.currentDocRef!)
                                    .set(createStorymessagesRecordData(
                                  text: getJsonField(
                                    currentLoop1Item,
                                    r'''$.content''',
                                  ).toString(),
                                  type: 'dialogue',
                                  timestamp: getCurrentTimestamp,
                                  speakerName: getJsonField(
                                    currentLoop1Item,
                                    r'''$.speaker''',
                                  ).toString(),
                                  actionText: getJsonField(
                                    currentLoop1Item,
                                    r'''$.action''',
                                  ).toString(),
                                ));
                              } else if (functions.isSceneType(
                                      currentLoop1Item, 'narration') ==
                                  true) {
                                await StorymessagesRecord.createDoc(
                                        _model.currentDocRef!)
                                    .set(createStorymessagesRecordData(
                                  text: getJsonField(
                                    currentLoop1Item,
                                    r'''$.content''',
                                  ).toString(),
                                  type: 'narration',
                                  timestamp: getCurrentTimestamp,
                                ));
                              } else if (functions.isSceneType(
                                      currentLoop1Item, 'show_image') ==
                                  true) {
                                await StorymessagesRecord.createDoc(
                                        _model.currentDocRef!)
                                    .set(createStorymessagesRecordData(
                                  type: 'story_image',
                                  timestamp: getCurrentTimestamp,
                                  storyImageUrl: functions
                                      .findSituationalImageUrlByCondition(
                                          getJsonField(
                                            currentLoop1Item,
                                            r'''$.condition''',
                                          ).toString(),
                                          _model.pageSituationalImages
                                              .toList()),
                                ));
                              }
                            }
                            for (int loop2Index = 0;
                                loop2Index < scenes.length;
                                loop2Index++) {
                              final currentLoop2Item = scenes[loop2Index];
                              if (functions.isSceneType(
                                      currentLoop2Item, 'dialogue') ==
                                  true) {
                                _model.addToChatMessages(
                                    StoryChatMessageStructStruct(
                                  text: getJsonField(
                                    currentLoop2Item,
                                    r'''$.content''',
                                  ).toString(),
                                  type: getJsonField(
                                    currentLoop2Item,
                                    r'''$.type''',
                                  ).toString(),
                                  isStreaming: false,
                                  speakerName: getJsonField(
                                    currentLoop2Item,
                                    r'''$.speaker''',
                                  ).toString(),
                                  speakerImage:
                                      functions.findCharacterImageByName(
                                          getJsonField(
                                            currentLoop2Item,
                                            r'''$.speaker''',
                                          ).toString(),
                                          _model.characters.toList(),
                                          ''),
                                  actionText: getJsonField(
                                    currentLoop2Item,
                                    r'''$.action''',
                                  ).toString(),
                                ));
                                safeSetState(() {});
                              } else if (functions.isSceneType(
                                      currentLoop2Item, 'narration') ==
                                  true) {
                                _model.addToChatMessages(
                                    StoryChatMessageStructStruct(
                                  text: getJsonField(
                                    currentLoop2Item,
                                    r'''$.content''',
                                  ).toString(),
                                  type: getJsonField(
                                    currentLoop2Item,
                                    r'''$.type''',
                                  ).toString(),
                                ));
                                safeSetState(() {});
                              } else if (functions.isSceneType(
                                      currentLoop2Item, 'show_image') ==
                                  true) {
                                _model.addToChatMessages(
                                    StoryChatMessageStructStruct(
                                  type: getJsonField(
                                    currentLoop2Item,
                                    r'''$.type''',
                                  ).toString(),
                                  storyImageUrl: functions
                                      .findSituationalImageUrlByCondition(
                                          getJsonField(
                                            currentLoop2Item,
                                            r'''$.condition''',
                                          ).toString(),
                                          _model.pageSituationalImages
                                              .toList()),
                                ));
                                safeSetState(() {});
                              }
                            }
                            _model.istyping = false;
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
                              color: FlutterFlowTheme.of(context).alternate,
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
                                      controller: _model.textController,
                                      focusNode: _model.textFieldFocusNode,
                                      autofocus: false,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: '인물의 대사나 행동을 입력하세요...',
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color: Color(0xFF606A85),
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF15161E),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
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
                                      validator: _model.textControllerValidator
                                          .asValidator(context),
                                      inputFormatters: [
                                        if (!isAndroid && !isiOS)
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            return TextEditingValue(
                                              selection: newValue.selection,
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 5.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
                                      text: '',
                                      icon: Icon(
                                        Icons.auto_awesome,
                                        size: 20.0,
                                      ),
                                      options: FFButtonOptions(
                                        width: 35.0,
                                        height: 35.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        color: Color(0xFFFFF8F9),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.interTight(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                              fontSize: 15.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
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
                                      onPressed: (currentUserReference == null)
                                          ? null
                                          : () async {
                                              final firestoreBatch =
                                                  FirebaseFirestore.instanceFor(
                                                          app: Firebase.app(),
                                                          databaseId:
                                                              '(default)')
                                                      .batch();
                                              try {
                                                if (loggedIn) {
                                                  _model.addToChatMessages(
                                                      StoryChatMessageStructStruct(
                                                    text: _model
                                                        .textController.text,
                                                    type: 'user',
                                                  ));
                                                  safeSetState(() {});
                                                  _model.userinput = _model
                                                      .textController.text;
                                                  safeSetState(() {});

                                                  firestoreBatch.set(
                                                      StorymessagesRecord
                                                          .createDoc(_model
                                                              .currentDocRef!),
                                                      createStorymessagesRecordData(
                                                        timestamp:
                                                            getCurrentTimestamp,
                                                        text: _model.userinput,
                                                        type: 'user',
                                                        speakerName: widget
                                                            .userInChatName,
                                                        userRef:
                                                            currentUserReference,
                                                      ));
                                                  _model.addToChatMessages(
                                                      StoryChatMessageStructStruct(
                                                    text: '생각 중',
                                                    type: 'thinking',
                                                  ));
                                                  safeSetState(() {});
                                                  safeSetState(() {
                                                    _model.textController
                                                        ?.clear();
                                                  });
                                                  _model.formattedHistory =
                                                      await actions
                                                          .getAndProcessHistory(
                                                    _model.currentDocRef,
                                                  );
                                                  _model.updatedChatDoc =
                                                      await StorychatsRecord
                                                          .getDocumentOnce(_model
                                                              .currentDocRef!);
                                                  _model.currentChatDoc =
                                                      _model.updatedChatDoc;
                                                  safeSetState(() {});
                                                  _model.pointsToDeduct =
                                                      await actions
                                                          .getPointCostAction(
                                                    _model.currentChatDoc
                                                        ?.selectedAiModel,
                                                  );
                                                  _model.creatorShare =
                                                      await actions
                                                          .calculateCreatorEarningAction(
                                                    _model.currentChatDoc
                                                        ?.selectedAiModel,
                                                  );
                                                  if (valueOrDefault(
                                                          currentUserDocument
                                                              ?.points,
                                                          0) >=
                                                      _model.pointsToDeduct!) {
                                                    firestoreBatch.update(
                                                        currentUserReference!, {
                                                      ...mapToFirestore(
                                                        {
                                                          'points': FieldValue
                                                              .increment(-(_model
                                                                  .pointsToDeduct!)),
                                                        },
                                                      ),
                                                    });
                                                    if (currentUserReference !=
                                                        _model.currentStory
                                                            ?.creatorRef) {
                                                      firestoreBatch.update(
                                                          _model.currentChatDoc!
                                                              .creatorRef!,
                                                          {
                                                            ...mapToFirestore(
                                                              {
                                                                'earnings': FieldValue
                                                                    .increment(
                                                                        _model
                                                                            .creatorShare!),
                                                              },
                                                            ),
                                                          });
                                                    }
                                                    _model.aiFullText =
                                                        await actions
                                                            .callAiProxy(
                                                      _model.pageSelectedModel,
                                                      functions.buildStoryPrompt(
                                                          _model.title,
                                                          _model.worldview,
                                                          _model.characters
                                                              .toList(),
                                                          _model.userrole,
                                                          '',
                                                          _model
                                                              .pageSituationalImages
                                                              .toList(),
                                                          _model.updatedChatDoc!
                                                              .userNote,
                                                          widget
                                                              .userInChatName!,
                                                          _model.updatedChatDoc
                                                              ?.summary),
                                                      _model.formattedHistory
                                                          ?.toList(),
                                                      _model.userinput,
                                                    );
                                                    _model.cleanList =
                                                        await actions
                                                            .removeThinkingMessage(
                                                      _model.chatMessages
                                                          .toList(),
                                                    );
                                                    _model.chatMessages = _model
                                                        .cleanList!
                                                        .toList()
                                                        .cast<
                                                            StoryChatMessageStructStruct>();
                                                    safeSetState(() {});
                                                    if (_model.aiFullText ==
                                                        'BLOCKED_CONTENT') {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '부적절한 내용이라 답변할 수 없습니다.',
                                                            style: TextStyle(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                            ),
                                                          ),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  2000),
                                                          backgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .info,
                                                        ),
                                                      );
                                                    } else {
                                                      _model.aiResponseScript =
                                                          _model.aiFullText!;
                                                      safeSetState(() {});
                                                      _model.messageCount =
                                                          await queryStorymessagesRecordCount(
                                                        parent: widget
                                                            .storychatRef,
                                                      );
                                                      _model.characterChatDoc =
                                                          await StorychatsRecord
                                                              .getDocumentOnce(
                                                                  _model
                                                                      .currentDocRef!);
                                                      if (functions.shouldSummarize(
                                                          _model.messageCount!,
                                                          _model
                                                              .characterChatDoc!
                                                              .lastSummaryMessageCount)) {
                                                        _model.summary =
                                                            await actions
                                                                .callAiSummaryAction(
                                                          _model.currentDocRef,
                                                        );

                                                        firestoreBatch.update(
                                                            _model
                                                                .currentDocRef!,
                                                            createStorychatsRecordData(
                                                              lastSummaryMessageCount:
                                                                  _model
                                                                      .messageCount,
                                                              summary: _model
                                                                  .summary,
                                                            ));
                                                      }
                                                    }
                                                  } else {
                                                    var confirmDialogResponse =
                                                        await showDialog<bool>(
                                                              context: context,
                                                              builder:
                                                                  (alertDialogContext) {
                                                                return WebViewAware(
                                                                  child:
                                                                      AlertDialog(
                                                                    title: Text(
                                                                        '피치 부족'),
                                                                    content: Text(
                                                                        '피치가 부족합니다. 충전하시겠습니까?'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            alertDialogContext,
                                                                            false),
                                                                        child: Text(
                                                                            '이동'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            alertDialogContext,
                                                                            true),
                                                                        child: Text(
                                                                            '취소'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ) ??
                                                            false;
                                                  }
                                                } else {
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    enableDrag: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return WebViewAware(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                LoginWidget(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));
                                                }
                                              } finally {
                                                await firestoreBatch.commit();
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
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 25.0, 15.0),
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
                                  _model.istyping = true;
                                  safeSetState(() {});
                                  _model.addToChatMessages(
                                      StoryChatMessageStructStruct(
                                    text: _model.textController.text,
                                    type: 'user',
                                  ));
                                  safeSetState(() {});
                                  _model.userinput = _model.textController.text;
                                  safeSetState(() {});
                                  _model.addToChatMessages(
                                      StoryChatMessageStructStruct(
                                    text: '생각 중',
                                    type: 'thinking',
                                  ));
                                  safeSetState(() {});
                                  safeSetState(() {
                                    _model.textController?.clear();
                                  });
                                  _model.formattedHistory1 =
                                      await actions.getAndProcessHistory(
                                    _model.currentDocRef,
                                  );
                                  _model.updatedChatDoc1 =
                                      await StorychatsRecord.getDocumentOnce(
                                          _model.currentDocRef!);
                                  _model.currentChatDoc =
                                      _model.updatedChatDoc1;
                                  safeSetState(() {});
                                  _model.pointsToDeduct1 =
                                      await actions.getPointCostAction(
                                    _model.currentChatDoc?.selectedAiModel,
                                  );
                                  _model.creatorShare1 = await actions
                                      .calculateCreatorEarningAction(
                                    _model.currentChatDoc?.selectedAiModel,
                                  );
                                  if (valueOrDefault(
                                          currentUserDocument?.points, 0) >=
                                      _model.pointsToDeduct1!) {
                                    firestoreBatch
                                        .update(currentUserReference!, {
                                      ...mapToFirestore(
                                        {
                                          'points': FieldValue.increment(
                                              -(_model.pointsToDeduct1!)),
                                        },
                                      ),
                                    });
                                    if (currentUserReference !=
                                        _model.currentStory?.creatorRef) {
                                      firestoreBatch.update(
                                          _model.currentChatDoc!.creatorRef!, {
                                        ...mapToFirestore(
                                          {
                                            'earnings': FieldValue.increment(
                                                _model.creatorShare1!),
                                          },
                                        ),
                                      });
                                    }
                                    _model.nextCommand =
                                        await actions.getNextPhaseCommand(
                                      _model.chatMessages.length,
                                    );
                                    _model.aiFullText1 =
                                        await actions.callAiProxy(
                                      _model.pageSelectedModel,
                                      functions.buildStoryPrompt(
                                          _model.title,
                                          _model.worldview,
                                          _model.characters.toList(),
                                          _model.userrole,
                                          '',
                                          _model.pageSituationalImages.toList(),
                                          _model.updatedChatDoc1!.userNote,
                                          widget.userInChatName!,
                                          _model.updatedChatDoc1?.summary),
                                      _model.formattedHistory1?.toList(),
                                      _model.nextCommand,
                                    );
                                    _model.cleanList1 =
                                        await actions.removeThinkingMessage(
                                      _model.chatMessages.toList(),
                                    );
                                    _model.chatMessages = _model.cleanList1!
                                        .toList()
                                        .cast<StoryChatMessageStructStruct>();
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
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 2000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context).info,
                                        ),
                                      );
                                    } else {
                                      _model.aiResponseScript =
                                          _model.aiFullText1!;
                                      safeSetState(() {});
                                      _model.messageCount2 =
                                          await queryStorymessagesRecordCount(
                                        parent: widget.storychatRef,
                                      );
                                      _model.characterChatDoc1 =
                                          await StorychatsRecord
                                              .getDocumentOnce(
                                                  _model.currentDocRef!);
                                      if (functions.shouldSummarize(
                                          _model.messageCount2!,
                                          _model.characterChatDoc1!
                                              .lastSummaryMessageCount)) {
                                        _model.summary1 =
                                            await actions.callAiSummaryAction(
                                          _model.currentDocRef,
                                        );

                                        firestoreBatch.update(
                                            _model.currentDocRef!,
                                            createStorychatsRecordData(
                                              lastSummaryMessageCount:
                                                  _model.messageCount2,
                                              summary: _model.summary1,
                                            ));
                                      }
                                    }
                                  } else {
                                    var confirmDialogResponse =
                                        await showDialog<bool>(
                                              context: context,
                                              builder: (alertDialogContext) {
                                                return WebViewAware(
                                                  child: AlertDialog(
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
                                                  ),
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
                                      return WebViewAware(
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: LoginWidget(),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                }
                              } finally {
                                await firestoreBatch.commit();
                              }

                              safeSetState(() {});
                            },
                    ).animateOnPageLoad(
                        animationsMap['iconButtonOnPageLoadAnimation']!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
