import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'charactercomment_copy_model.dart';
export 'charactercomment_copy_model.dart';

class CharactercommentCopyWidget extends StatefulWidget {
  const CharactercommentCopyWidget({
    super.key,
    this.charactercommentDocument,
    this.parentcharacterRef,
    bool? isReply,
  }) : this.isReply = isReply ?? false;

  final CharacterCommentsRecord? charactercommentDocument;
  final DocumentReference? parentcharacterRef;
  final bool isReply;

  @override
  State<CharactercommentCopyWidget> createState() =>
      _CharactercommentCopyWidgetState();
}

class _CharactercommentCopyWidgetState
    extends State<CharactercommentCopyWidget> {
  late CharactercommentCopyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CharactercommentCopyModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.isLikedByUser = functions.didUserLike(
          widget.charactercommentDocument?.likedBy.toList(),
          currentUserReference);
      safeSetState(() {});
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    widget.charactercommentDocument!.userProfileImage,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 3.0),
                        child: Text(
                          valueOrDefault<String>(
                            widget.charactercommentDocument?.userName,
                            'No name',
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                      Text(
                        dateTimeFormat(
                          "relative",
                          widget.charactercommentDocument!.timestamp!,
                          locale: FFLocalizations.of(context).languageCode,
                        ),
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (currentUserReference ==
                widget.charactercommentDocument?.userRef)
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (widget.isReply) {
                    var confirmDialogResponse = await showDialog<bool>(
                          context: context,
                          builder: (alertDialogContext) {
                            return WebViewAware(
                              child: AlertDialog(
                                title: Text('삭제'),
                                content: Text('정말 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        alertDialogContext, false),
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext, true),
                                    child: Text('확인'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ) ??
                        false;
                    await widget.charactercommentDocument!.reference.delete();
                  } else {
                    var confirmDialogResponse = await showDialog<bool>(
                          context: context,
                          builder: (alertDialogContext) {
                            return WebViewAware(
                              child: AlertDialog(
                                title: Text('삭제'),
                                content: Text('정말 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        alertDialogContext, false),
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext, true),
                                    child: Text('확인'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ) ??
                        false;
                    try {
                      final result = await FirebaseFunctions.instanceFor(
                              region: 'asia-northeast3')
                          .httpsCallable('deleteCommentAndReplies')
                          .call({
                        "commentId":
                            widget.charactercommentDocument!.reference.id,
                      });
                      _model.cloudFunction =
                          DeleteCommentAndRepliesCloudFunctionCallResponse(
                        data: result.data,
                        succeeded: true,
                        resultAsString: result.data.toString(),
                        jsonBody: result.data,
                      );
                    } on FirebaseFunctionsException catch (error) {
                      _model.cloudFunction =
                          DeleteCommentAndRepliesCloudFunctionCallResponse(
                        errorCode: error.code,
                        succeeded: false,
                      );
                    }
                  }

                  safeSetState(() {});
                },
                child: Icon(
                  Icons.delete_outline,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 24.0,
                ),
              ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional(-1.0, 0.0),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(40.0, 10.0, 0.0, 0.0),
            child: Text(
              valueOrDefault<String>(
                widget.charactercommentDocument?.content,
                'No comment',
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(40.0, 10.0, 0.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (valueOrDefault<bool>(
                widget.isReply,
                false,
              ))
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ToggleIcon(
                      onPressed: () async {
                        safeSetState(() =>
                            _model.isReplyVisible = !_model.isReplyVisible);
                        _model.isReplyVisible = !_model.isReplyVisible;
                        safeSetState(() {});
                      },
                      value: _model.isReplyVisible,
                      onIcon: Icon(
                        Icons.mode_comment_outlined,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 20.0,
                      ),
                      offIcon: Icon(
                        Icons.mode_comment_outlined,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 20.0,
                      ),
                    ),
                    Text(
                      formatNumber(
                        widget.charactercommentDocument!.replyCount,
                        formatType: FormatType.compact,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ],
                ),
              if (valueOrDefault<bool>(
                widget.isReply,
                false,
              ))
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ToggleIcon(
                        onPressed: () async {
                          safeSetState(() =>
                              _model.isLikedByUser = !_model.isLikedByUser);
                          if (_model.isLikedByUser == true) {
                            await widget.charactercommentDocument!.reference
                                .update({
                              ...mapToFirestore(
                                {
                                  'like_count': FieldValue.increment(-(1)),
                                  'liked_by': FieldValue.arrayRemove(
                                      [currentUserReference]),
                                },
                              ),
                            });
                          } else {
                            await widget.charactercommentDocument!.reference
                                .update({
                              ...mapToFirestore(
                                {
                                  'like_count': FieldValue.increment(1),
                                  'liked_by': FieldValue.arrayUnion(
                                      [currentUserReference]),
                                },
                              ),
                            });
                          }

                          _model.isLikedByUser = !_model.isLikedByUser;
                          safeSetState(() {});
                        },
                        value: _model.isLikedByUser,
                        onIcon: Icon(
                          Icons.favorite_border,
                          color: FlutterFlowTheme.of(context).error,
                          size: 20.0,
                        ),
                        offIcon: Icon(
                          Icons.favorite_border,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 20.0,
                        ),
                      ),
                      Text(
                        formatNumber(
                          widget.charactercommentDocument!.likeCount,
                          formatType: FormatType.compact,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Divider(
          thickness: 1.0,
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        if (_model.isReplyVisible)
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              StreamBuilder<List<CharacterCommentsRecord>>(
                stream: queryCharacterCommentsRecord(
                  queryBuilder: (characterCommentsRecord) =>
                      characterCommentsRecord
                          .where(
                            'parent_comment_ref',
                            isEqualTo:
                                widget.charactercommentDocument?.reference,
                          )
                          .orderBy('timestamp'),
                ),
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
                  List<CharacterCommentsRecord>
                      listViewCharacterCommentsRecordList = snapshot.data!;

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: listViewCharacterCommentsRecordList.length,
                    itemBuilder: (context, listViewIndex) {
                      final listViewCharacterCommentsRecord =
                          listViewCharacterCommentsRecordList[listViewIndex];
                      return Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 0.0, 0.0),
                        child: CharactercommentCopyWidget(
                          key: Key(
                              'Keyj9z_${listViewIndex}_of_${listViewCharacterCommentsRecordList.length}'),
                          isReply: true,
                          charactercommentDocument:
                              widget.charactercommentDocument,
                          parentcharacterRef: widget.parentcharacterRef,
                        ),
                      );
                    },
                  );
                },
              ),
              if (valueOrDefault<bool>(
                widget.isReply,
                false,
              ))
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              70.0, 0.0, 0.0, 0.0),
                          child: Container(
                            width: 200.0,
                            child: TextFormField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                labelStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                hintText: '답글을 입력하세요...',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              maxLines: null,
                              cursorColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              validator: _model.textControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            await CharacterCommentsRecord.collection
                                .doc()
                                .set(createCharacterCommentsRecordData(
                                  userRef: currentUserReference,
                                  userName: currentUserDisplayName,
                                  userProfileImage: currentUserPhoto,
                                  content: _model.textController.text,
                                  timestamp: getCurrentTimestamp,
                                  characterRef: widget.parentcharacterRef,
                                  parentCommentRef: widget
                                      .charactercommentDocument?.reference,
                                ));
                            safeSetState(() {
                              _model.textController?.clear();
                            });

                            await widget.charactercommentDocument!.reference
                                .update({
                              ...mapToFirestore(
                                {
                                  'reply_count': FieldValue.increment(1),
                                },
                              ),
                            });
                          },
                          child: Icon(
                            Icons.arrow_circle_up_outlined,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        Divider(
          thickness: 1.0,
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
      ],
    );
  }
}
