import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared/login/login_widget.dart';
import '/unuse2/characterbottom/characterbottom_widget.dart';
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
import 'characterchat_model.dart';
export 'characterchat_model.dart';

class CharacterchatWidget extends StatefulWidget {
  const CharacterchatWidget({
    super.key,
    this.characterRef,
    this.characterchatRef,
  });

  final DocumentReference? characterRef;
  final DocumentReference? characterchatRef;

  static String routeName = 'characterchat';
  static String routePath = '/characterchat';

  @override
  State<CharacterchatWidget> createState() => _CharacterchatWidgetState();
}

class _CharacterchatWidgetState extends State<CharacterchatWidget>
    with TickerProviderStateMixin {
  late CharacterchatModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CharacterchatModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.characterDoc =
          await CharacterRecord.getDocumentOnce(widget.characterRef!);
      _model.currentCharacter = _model.characterDoc;
      _model.name = _model.characterDoc?.name;
      _model.setting = _model.characterDoc?.setting;
      _model.dialogueExample =
          _model.characterDoc!.dialogueExample.toList().cast<String>();
      _model.situation = _model.characterDoc!.situationalImages
          .toList()
          .cast<SituationalImageStructStruct>();
      _model.pageSelectedModel = _model.characterDoc!.aiModel;
      safeSetState(() {});
      _model.existingChatlist = await queryCharacterchatsRecordOnce(
        queryBuilder: (characterchatsRecord) => characterchatsRecord
            .where(
              'user_ref',
              isEqualTo: currentUserReference,
            )
            .where(
              'character_ref',
              isEqualTo: widget.characterRef,
            ),
      );
      if (_model.existingChatlist!.length > 0) {
        _model.currentDocRef = _model.existingChatlist?.firstOrNull?.reference;
        _model.pageSelectedModel =
            _model.existingChatlist!.firstOrNull!.selectedAiModel;
        safeSetState(() {});
        _model.messagesAsJson = await actions.getCharacterHistoryAsJson(
          _model.currentDocRef,
        );
        _model.chatMessages = functions
            .mapJsonToCharacterChatStructs(_model.messagesAsJson!.toList())
            .toList()
            .cast<CharacterChatMessageStructStruct>();
        safeSetState(() {});
      } else {
        var characterchatsRecordReference =
            CharacterchatsRecord.collection.doc();
        await characterchatsRecordReference.set(createCharacterchatsRecordData(
          userRef: currentUserReference,
          createdAt: getCurrentTimestamp,
          characterRef: widget.characterRef,
          lastSummaryMessageCount: 0,
          selectedAiModel: 'claude-3-haiku-20240307',
        ));
        _model.newChatRef = CharacterchatsRecord.getDocumentFromData(
            createCharacterchatsRecordData(
              userRef: currentUserReference,
              createdAt: getCurrentTimestamp,
              characterRef: widget.characterRef,
              lastSummaryMessageCount: 0,
              selectedAiModel: 'claude-3-haiku-20240307',
            ),
            characterchatsRecordReference);
        _model.currentDocRef = _model.newChatRef?.reference;
        _model.pageSelectedModel = 'claude-3-haiku-20240307';
        safeSetState(() {});
        _model.aiResponseScript = valueOrDefault<String>(
          _model.currentCharacter?.firstgreeting,
          '안녕하세요?',
        );
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
        backgroundColor: Color(0xFFFFF8F9),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFF8F9),
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
              _model.characterDoc?.name,
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
                            child: CharacterbottomWidget(
                              characterchatRef: _model.currentDocRef!,
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
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 25.0, 0.0),
                      child: custom_widgets.CharacterChatDirector(
                        width: 0.0,
                        height: 0.0,
                        newResponseScript: _model.aiResponseScript,
                        characterDoc: _model.currentCharacter,
                        initialMessages: _model.chatMessages,
                        onTurnComplete: (scenes) async {
                          for (int loop1Index = 0;
                              loop1Index < scenes!.length;
                              loop1Index++) {
                            final currentLoop1Item = scenes[loop1Index];
                            if (functions.isSceneType(
                                    currentLoop1Item, 'dialogue') ==
                                true) {
                              await CharactermessagesRecord.createDoc(
                                      _model.currentDocRef!)
                                  .set(createCharactermessagesRecordData(
                                text: getJsonField(
                                  currentLoop1Item,
                                  r'''$.content''',
                                ).toString(),
                                type: 'character',
                                timestamp: getCurrentTimestamp,
                                senderImage:
                                    _model.currentCharacter?.characterimage,
                                name: _model.currentCharacter?.name,
                              ));
                            } else {
                              await CharactermessagesRecord.createDoc(
                                      _model.currentDocRef!)
                                  .set(createCharactermessagesRecordData(
                                type: 'story_image',
                                timestamp: getCurrentTimestamp,
                                senderImage:
                                    _model.currentCharacter?.characterimage,
                                name: _model.currentCharacter?.name,
                                storyImageUrl: functions
                                    .findSituationalImageUrlByCondition(
                                        getJsonField(
                                          currentLoop1Item,
                                          r'''$.condition''',
                                        ).toString(),
                                        _model
                                            .currentCharacter!.situationalImages
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
                                  CharacterChatMessageStructStruct(
                                text: getJsonField(
                                  currentLoop2Item,
                                  r'''$.content''',
                                ).toString(),
                                type: 'character',
                              ));
                              safeSetState(() {});
                            } else {
                              _model.addToChatMessages(
                                  CharacterChatMessageStructStruct(
                                type: 'story_image',
                                storyImageUrl: functions
                                    .findSituationalImageUrlByCondition(
                                        getJsonField(
                                          currentLoop2Item,
                                          r'''$.condition''',
                                        ).toString(),
                                        _model.situation.toList()),
                              ));
                              safeSetState(() {});
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: SafeArea(
                    child: Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
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
                      ),
                      alignment: AlignmentDirectional(0.0, 1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                25.0, 0.0, 25.0, 0.0),
                            child: Container(
                              width: 350.0,
                              height: 50.0,
                              decoration: BoxDecoration(),
                              child: Container(
                                width: 350.0,
                                child: TextFormField(
                                  controller: _model.textController,
                                  focusNode: _model.textFieldFocusNode,
                                  autofocus: false,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText: '메세지를 입력하세요...',
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
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  maxLines: null,
                                  validator: _model.textControllerValidator
                                      .asValidator(context),
                                  inputFormatters: [
                                    if (!isAndroid && !isiOS)
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        return TextEditingValue(
                                          selection: newValue.selection,
                                          text: newValue.text.toCapitalization(
                                              TextCapitalization.sentences),
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
                                  onPressed: () async {
                                    _model.chatHistory =
                                        await queryCharactermessagesRecordOnce(
                                      parent: _model.currentDocRef,
                                      queryBuilder: (charactermessagesRecord) =>
                                          charactermessagesRecord
                                              .orderBy('timestamp'),
                                      limit: 20,
                                    );

                                    safeSetState(() {});
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
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
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
                                    borderRadius: BorderRadius.circular(0.0),
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
                                  onPressed: () async {
                                    if (loggedIn) {
                                      _model.addToChatMessages(
                                          CharacterChatMessageStructStruct(
                                        text: _model.textController.text,
                                        type: 'user',
                                      ));
                                      safeSetState(() {});

                                      await CharactermessagesRecord.createDoc(
                                              _model.currentDocRef!)
                                          .set(
                                              createCharactermessagesRecordData(
                                        senderImage: currentUserPhoto,
                                        timestamp: getCurrentTimestamp,
                                        name: currentUserDisplayName,
                                        text: _model.textController.text,
                                        type: 'user',
                                      ));
                                      safeSetState(() {
                                        _model.textController?.clear();
                                      });
                                      _model.formattedHistory = await actions
                                          .getCharacterHistoryAsJson(
                                        _model.currentDocRef,
                                      );
                                      _model.updatedChatDoc =
                                          await CharacterchatsRecord
                                              .getDocumentOnce(
                                                  _model.currentDocRef!);
                                      _model.currentChatDoc =
                                          _model.updatedChatDoc;
                                      safeSetState(() {});
                                      _model.pointsToDeduct =
                                          await actions.getPointCostAction(
                                        _model.currentChatDoc?.selectedAiModel,
                                      );
                                      _model.creatorShare = await actions
                                          .calculateCreatorEarningAction(
                                        _model.currentChatDoc?.selectedAiModel,
                                      );
                                      if (valueOrDefault(
                                              currentUserDocument?.points, 0) >=
                                          _model.pointsToDeduct!) {
                                        await currentUserReference!.update({
                                          ...mapToFirestore(
                                            {
                                              'points': FieldValue.increment(
                                                  -(_model.pointsToDeduct!)),
                                            },
                                          ),
                                        });
                                        if (currentUserReference !=
                                            _model
                                                .currentCharacter?.creatorRef) {
                                          await _model
                                              .currentChatDoc!.creatorRef!
                                              .update({
                                            ...mapToFirestore(
                                              {
                                                'earnings':
                                                    FieldValue.increment(
                                                        _model.creatorShare!),
                                              },
                                            ),
                                          });
                                        }
                                        _model.messageCount =
                                            await queryCharactermessagesRecordCount(
                                          parent: _model.currentDocRef,
                                          queryBuilder:
                                              (charactermessagesRecord) =>
                                                  charactermessagesRecord.where(
                                            'chat_ref',
                                            isEqualTo: _model.currentDocRef,
                                          ),
                                        );
                                        _model.characterChatDoc =
                                            await CharacterchatsRecord
                                                .getDocumentOnce(
                                                    _model.currentDocRef!);
                                      } else {
                                        var confirmDialogResponse =
                                            await showDialog<bool>(
                                                  context: context,
                                                  builder:
                                                      (alertDialogContext) {
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
                                                child: LoginWidget(),
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
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
          ),
        ),
      ),
    );
  }
}
