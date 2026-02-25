import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/home/loginpage/loginpage_widget.dart';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'visualnovelpage_model.dart';
export 'visualnovelpage_model.dart';

class VisualnovelpageWidget extends StatefulWidget {
  const VisualnovelpageWidget({
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

  static String routeName = 'visualnovelpage';
  static String routePath = '/visualnovelpage';

  @override
  State<VisualnovelpageWidget> createState() => _VisualnovelpageWidgetState();
}

class _VisualnovelpageWidgetState extends State<VisualnovelpageWidget> {
  static const String _defaultAiModelId = 'claude-3-haiku-20240307';
  late VisualnovelpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSendingTurn = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VisualnovelpageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.loadedStory =
          await StoriesRecord.getDocumentOnce(widget.storyRef!);
      _model.messagesAsJson = await actions.getRecentHistoryAsJson(
        widget.storychatRef!,
        30,
      );
      _model.chatMessages = functions
          .mapJsonToStoryChatStructs(_model.messagesAsJson!.toList())
          .toList()
          .cast<StoryChatMessageStructStruct>();
      safeSetState(() {});
      if (!(_model.chatMessages.isNotEmpty)) {
        _model.pageloadformat = await actions.formatStoryTurnHeaderAndBg(
          functions.prologueTextToTagScript(
              _model.loadedStory!.prologuetext,
              _model.loadedStory!.characters.toList(),
              _model.loadedStory!.places.toList()),
          _model.chatMessages.toList(),
          _model.loadedStory?.places.toList(),
          _model.loadedStory?.characters.toList(),
          widget.userInChatName,
          true,
        );
        _model.chatMessages = functions
            .getemptyStoryChatMessages()
            .toList()
            .cast<StoryChatMessageStructStruct>();
        _model.aiResponseScript = _model.pageloadformat!;
        safeSetState(() {});
      }
    });

    _model.usertextFieldTextController ??= TextEditingController();
    _model.usertextFieldFocusNode ??= FocusNode();

    _model.messageTextFieldTextController ??= TextEditingController();
    _model.messageTextFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
        duration: const Duration(milliseconds: 2200),
        backgroundColor: FlutterFlowTheme.of(context).info,
      ),
    );
  }

  Future<void> _showLoginSheet() async {
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
            child: LoginpageWidget(),
          ),
        );
      },
    ).then((value) => safeSetState(() {}));
  }

  String _resolveSelectedModelId(String? rawModelId) {
    final value = (rawModelId ?? '').trim();
    return value.isEmpty ? _defaultAiModelId : value;
  }

  Future<void> _handleChatSend(
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) async {
    if (_isSendingTurn) return;

    final userInput = _model.messageTextFieldTextController.text.trim();
    if (userInput.isEmpty) {
      _showMessage('메시지를 입력해주세요.');
      return;
    }

    if (!loggedIn || currentUserReference == null) {
      await _showLoginSheet();
      return;
    }

    final selectedModelId = _resolveSelectedModelId(chatDoc.selectedAiModel);
    final pointCost = await actions.getPointCostAction(selectedModelId);
    if (valueOrDefault(currentUserDocument?.points, 0) < pointCost) {
      final moveToCharge = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('포인트 부족'),
                content: const Text('포인트가 부족합니다. 충전페이지로 이동할까요?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('이동하기'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('취소하기'),
                  ),
                ],
              );
            },
          ) ??
          false;
      if (moveToCharge && mounted) {
        context.pushNamed(PointchargepageWidget.routeName);
      }
      return;
    }

    safeSetState(() {
      _isSendingTurn = true;
    });

    try {
      await StorymessagesRecord.createDoc(chatDoc.reference).set(
        createStorymessagesRecordData(
          timestamp: getCurrentTimestamp,
          text: userInput,
          type: 'user',
          speakerName: widget.userInChatName,
          userRef: currentUserReference,
        ),
      );

      await currentUserReference!.update({
        ...mapToFirestore({
          'points': FieldValue.increment(-(pointCost)),
        }),
      });

      final creatorShare = await actions.calculateCreatorEarningAction(
        selectedModelId,
      );
      if (chatDoc.creatorRef != null &&
          currentUserReference != chatDoc.creatorRef) {
        await chatDoc.creatorRef!.update({
          ...mapToFirestore({
            'earnings': FieldValue.increment(creatorShare),
          }),
        });
      }

      final formattedHistory = await actions.getAndProcessHistory(
        widget.storychatRef,
      );
      final hybridMemory = await actions.buildHybridMemoryContext(
        widget.storychatRef,
        userInput,
      );
      final promptMemory = [
        functions.dynamicContextByOutlineMode(
          valueOrDefault<bool>(
            story.outlineMode,
            false,
          ),
          story.outlineText,
          valueOrDefault<int>(
            chatDoc.turnCount,
            0,
          ),
          valueOrDefault<int>(
            chatDoc.chapterIndex,
            1,
          ),
          chatDoc.storyBible,
          chatDoc.chapterState,
          chatDoc.summary,
        ),
        hybridMemory,
      ].where((part) => part.trim().isNotEmpty).join('\n\n');

      final aiRaw = await actions.callAiProxy(
        selectedModelId,
        functions.buildStoryPrompt(
          story.title,
          story.worldview,
          story.characters.toList(),
          story.userRole,
          story.places.toList(),
          chatDoc.userNote,
          widget.userInChatName ?? '',
          promptMemory,
          story.place,
          story.event,
          story.events.toList(),
        ),
        formattedHistory.toList(),
        userInput,
      );
      final aiRawText = (aiRaw ?? '').trim();

      if (aiRawText == 'BLOCKED_CONTENT') {
        _showMessage('부적절한 내용이라 답변할 수 없습니다.');
        return;
      }
      if (aiRawText.isEmpty || aiRawText.startsWith('ERROR:')) {
        _showMessage('다음 턴 생성에 실패했습니다. 다시 시도해주세요.');
        return;
      }

      _model.aiResponseScript = await actions.formatStoryTurnHeaderAndBg(
        aiRawText,
        _model.chatMessages.toList(),
        story.places.toList(),
        story.characters.toList(),
        widget.userInChatName,
        false,
      );
      _model.messageTextFieldTextController?.clear();
      safeSetState(() {});
    } catch (_) {
      _showMessage('다음 턴 생성에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (!mounted) return;
      safeSetState(() {
        _isSendingTurn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StoriesRecord>(
      stream: StoriesRecord.getDocument(widget.storyRef!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryText,
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

        final visualnovelpageStoriesRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryText,
            body: Builder(
              builder: (context) {
                if (_model.isvisualmode == true) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          'https://picsum.photos/seed/177/600',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          'https://picsum.photos/seed/177/600',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 50.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 7.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x26000000),
                                            Color(0x73000000),
                                            Color(0x8C000000),
                                            Color(0x8C000000),
                                            Color(0x73000000),
                                            Color(0x26000000)
                                          ],
                                          stops: [
                                            0.0,
                                            0.08,
                                            0.2,
                                            0.8,
                                            0.92,
                                            1.0
                                          ],
                                          begin: AlignmentDirectional(1.0, 0.0),
                                          end: AlignmentDirectional(-1.0, 0),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(0.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 0.0, 25.0, 7.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0),
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 20.0, 0.0),
                                      child: AutoSizeText(
                                        '',
                                        maxLines: 3,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 7.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x26000000),
                                            Color(0x73000000),
                                            Color(0x8C000000),
                                            Color(0x8C000000),
                                            Color(0x73000000),
                                            Color(0x26000000)
                                          ],
                                          stops: [
                                            0.0,
                                            0.08,
                                            0.2,
                                            0.8,
                                            0.92,
                                            1.0
                                          ],
                                          begin: AlignmentDirectional(1.0, 0.0),
                                          end: AlignmentDirectional(-1.0, 0),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(0.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 0.0, 25.0, 7.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0),
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 20.0, 0.0),
                                      child: AutoSizeText(
                                        '',
                                        maxLines: 3,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 7.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x26000000),
                                            Color(0x73000000),
                                            Color(0x8C000000),
                                            Color(0x8C000000),
                                            Color(0x73000000),
                                            Color(0x26000000)
                                          ],
                                          stops: [
                                            0.0,
                                            0.08,
                                            0.2,
                                            0.8,
                                            0.92,
                                            1.0
                                          ],
                                          begin: AlignmentDirectional(1.0, 0.0),
                                          end: AlignmentDirectional(-1.0, 0),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(0.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 0.0, 25.0, 7.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0),
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 20.0, 0.0),
                                      child: AutoSizeText(
                                        'Hello World',
                                        maxLines: 3,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.3,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              width: 290.0,
                                              child: TextFormField(
                                                controller: _model
                                                    .usertextFieldTextController,
                                                focusNode: _model
                                                    .usertextFieldFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText: 'TextField',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                maxLines: null,
                                                minLines: 1,
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                validator: _model
                                                    .usertextFieldTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 0.0, 0.0, 0.0),
                                            child: Icon(
                                              Icons.send,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              size: 20.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 200.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0x33000000)
                                      ],
                                      stops: [0.0, 0.25],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 200.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        40.0, 20.0, 40.0, 50.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Text(
                                            '캐릭터이름',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .warning,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          '대사 또는 내래이션',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0x33000000)
                                      ],
                                      stops: [0.0, 0.25],
                                      begin: AlignmentDirectional(0.0, 1.0),
                                      end: AlignmentDirectional(0, -1.0),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        60.0, 40.0, 40.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 8.0),
                                          child: Text(
                                            '',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .warning,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    25.0, 50.0, 25.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      size: 22.0,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 10.0, 0.0),
                                          child: Icon(
                                            Icons.cached,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 22.0,
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            scaffoldKey.currentState!
                                                .openEndDrawer();
                                          },
                                          child: Icon(
                                            Icons.menu,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 25.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return StreamBuilder<StorychatsRecord>(
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
                              Container(
                                width: 70.0,
                                height: 70.0,
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 0.0, 25.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Hello World',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Icon(
                                        Icons.cached,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        size: 24.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 0.0),
                                    child: custom_widgets.NotifierChatList(
                                      width: double.infinity,
                                      height: double.infinity,
                                      newResponseScript:
                                          _model.aiResponseScript,
                                      userInChatName: widget.userInChatName,
                                      initialMessages: _model.chatMessages,
                                      preDefinedCharacters:
                                          visualnovelpageStoriesRecord
                                              .characters,
                                      backgroundList:
                                          visualnovelpageStoriesRecord.places,
                                      onTurnComplete: (scenes) async {
                                        _model.newMessages = await actions
                                            .processAndSaveChatTurn(
                                          scenes!.toList(),
                                          stackStorychatsRecord.reference,
                                          visualnovelpageStoriesRecord.places
                                              .toList(),
                                          visualnovelpageStoriesRecord
                                              .characters
                                              .toList(),
                                          visualnovelpageStoriesRecord.events
                                              .toList(),
                                        );
                                        _model.chatMessages = functions
                                            .mergeChatLists(
                                                _model.chatMessages.toList(),
                                                _model.newMessages?.toList())
                                            .toList()
                                            .cast<
                                                StoryChatMessageStructStruct>();
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
                                        await actions.updateStoryMemory(
                                          _model.currentDocRef!,
                                          visualnovelpageStoriesRecord
                                              .outlineMode,
                                          visualnovelpageStoriesRecord
                                              .outlineText,
                                        );
                                        if (functions
                                            .isSummaryTurn(valueOrDefault<int>(
                                                  stackStorychatsRecord
                                                      .messageCount,
                                                  0,
                                                ) +
                                                1)) {
                                          await stackStorychatsRecord.reference
                                              .update(
                                                  createStorychatsRecordData(
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
                                        _model.olderMessages = await actions
                                            .getPreviousChatHistory(
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
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: SafeArea(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(30.0),
                                        topRight: Radius.circular(30.0),
                                      ),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 1.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
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
                                                    TextCapitalization
                                                        .sentences,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      '캐릭터의 대사나 행동을 입력하세요.',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
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
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
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
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  focusedErrorBorder:
                                                      InputBorder.none,
                                                ),
                                                style: FlutterFlowTheme.of(
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
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
                                                    MaxLengthEnforcement
                                                        .enforced,
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
                                                        .withFunction((oldValue,
                                                            newValue) {
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
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 25.0, 0.0),
                                                child: FlutterFlowIconButton(
                                                  borderRadius: 10.0,
                                                  buttonSize: 35.0,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                  icon: Icon(
                                                    Icons.send,
                                                    color: Colors.white,
                                                    size: 20.0,
                                                  ),
                                                  showLoadingIndicator: true,
                                                  onPressed: () async {
                                                    await _handleChatSend(
                                                      visualnovelpageStoriesRecord,
                                                      stackStorychatsRecord,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
