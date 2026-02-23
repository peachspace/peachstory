import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatlistpage_model.dart';
export 'chatlistpage_model.dart';

class ChatlistpageWidget extends StatefulWidget {
  const ChatlistpageWidget({super.key});

  static String routeName = 'chatlistpage';
  static String routePath = '/chatlistpage';

  @override
  State<ChatlistpageWidget> createState() => _ChatlistpageWidgetState();
}

class _ChatlistpageWidgetState extends State<ChatlistpageWidget> {
  late ChatlistpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _deletingChatIds = <String>{};
  final Set<String> _deletedChatIds = <String>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatlistpageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('삭제하기'),
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
    return confirmed;
  }

  Future<void> _deleteChatItem(StorychatsRecord chatDoc) async {
    final chatId = chatDoc.reference.id;
    if (_deletingChatIds.contains(chatId)) {
      return;
    }

    final confirm = await _showDeleteConfirmDialog();
    if (!confirm) {
      return;
    }

    safeSetState(() {
      _deletingChatIds.add(chatId);
    });

    try {
      final messagesSnapshot =
          await chatDoc.reference.collection('storymessages').get();

      final refsToDelete = <DocumentReference>[
        ...messagesSnapshot.docs.map((doc) => doc.reference),
        chatDoc.reference,
      ];

      const int chunkSize = 400;
      for (int i = 0; i < refsToDelete.length; i += chunkSize) {
        final batch = FirebaseFirestore.instance.batch();
        final end = (i + chunkSize) > refsToDelete.length
            ? refsToDelete.length
            : (i + chunkSize);

        for (final ref in refsToDelete.sublist(i, end)) {
          batch.delete(ref);
        }

        await batch.commit();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '삭제에 실패했습니다. 다시 시도해주세요.',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            duration: const Duration(milliseconds: 2200),
            backgroundColor: FlutterFlowTheme.of(context).info,
          ),
        );
      }
      safeSetState(() {
        _deletingChatIds.remove(chatId);
      });
      return;
    }

    safeSetState(() {
      _deletingChatIds.remove(chatId);
      _deletedChatIds.add(chatId);
    });
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
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        drawer: Opacity(
          opacity: 0.8,
          child: Container(
            width: 250.0,
            child: Drawer(
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(25.0, 40.0, 25.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Text(
                          'PEACHSTORY',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.oswald(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.home,
                              color: FlutterFlowTheme.of(context).warning,
                              size: 24.0,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(HomepageWidget.routeName);

                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '홈',
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
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
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.chat,
                              color: FlutterFlowTheme.of(context).warning,
                              size: 24.0,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context
                                      .pushNamed(ChatlistpageWidget.routeName);

                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '대화내역',
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
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
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.create_sharp,
                              color: FlutterFlowTheme.of(context).warning,
                              size: 24.0,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(
                                      CreatelistpageWidget.routeName);

                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '생성하기',
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
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
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.person,
                              color: FlutterFlowTheme.of(context).warning,
                              size: 24.0,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(MypageWidget.routeName);

                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '프로필',
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryText,
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              scaffoldKey.currentState!.openDrawer();
            },
            child: Icon(
              Icons.menu,
              color: FlutterFlowTheme.of(context).primaryBackground,
              size: 24.0,
            ),
          ),
          title: Text(
            '대화목록',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 25.0, 0.0),
                    child: StreamBuilder<List<StorychatsRecord>>(
                      stream: queryStorychatsRecord(
                        queryBuilder: (storychatsRecord) => storychatsRecord
                            .where(
                              'user_ref',
                              isEqualTo: currentUserReference,
                            )
                            .orderBy('last_timestamp', descending: true),
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
                        final listViewStorychatsRecordList = snapshot.data!
                            .where((chat) =>
                                !_deletingChatIds.contains(chat.reference.id) &&
                                !_deletedChatIds.contains(chat.reference.id))
                            .toList();

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: listViewStorychatsRecordList.length,
                          itemBuilder: (context, listViewIndex) {
                            final listViewStorychatsRecord =
                                listViewStorychatsRecordList[listViewIndex];
                            return StreamBuilder<StoriesRecord>(
                              stream: StoriesRecord.getDocument(
                                  listViewStorychatsRecord.storyRef!),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final containerStoriesRecord = snapshot.data!;

                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          VisualnovelpageWidget.routeName,
                                          queryParameters: {
                                            'storyRef': serializeParam(
                                              containerStoriesRecord.reference,
                                              ParamType.DocumentReference,
                                            ),
                                            'userInChatName': serializeParam(
                                              listViewStorychatsRecord
                                                  .userInChatName,
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 60.0,
                                            height: 60.0,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                containerStoriesRecord
                                                    .mainImage,
                                                width: 60.0,
                                                height: 60.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      15.0, 0.0, 15.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 10.0),
                                                    child: Text(
                                                      containerStoriesRecord
                                                          .title,
                                                      maxLines: 1,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .fontStyle,
                                                              ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                12.0, 0.0),
                                                    child: Text(
                                                      valueOrDefault<String>(
                                                        listViewStorychatsRecord
                                                            .lastMessage,
                                                        '대화를 시작해보세요!',
                                                      ),
                                                      maxLines: 1,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                              ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ].divide(SizedBox(height: 4.0)),
                                              ),
                                            ),
                                          ),
                                          _deletingChatIds.contains(
                                                  listViewStorychatsRecord
                                                      .reference.id)
                                              ? SizedBox(
                                                  width: 22.0,
                                                  height: 22.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                    ),
                                                  ),
                                                )
                                              : IconButton(
                                                  icon: Icon(
                                                    Icons.delete_outline_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    size: 22.0,
                                                  ),
                                                  onPressed: () async {
                                                    await _deleteChatItem(
                                                      listViewStorychatsRecord,
                                                    );
                                                  },
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
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
