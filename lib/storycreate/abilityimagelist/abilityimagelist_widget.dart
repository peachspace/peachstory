import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/storycreate/abilitystruct/abilitystruct_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'abilityimagelist_model.dart';
export 'abilityimagelist_model.dart';

class AbilityimagelistWidget extends StatefulWidget {
  const AbilityimagelistWidget({
    super.key,
    this.abilityTags,
    this.placeTags,
  });

  final List<String>? abilityTags;
  final List<String>? placeTags;

  static String routeName = 'abilityimagelist';
  static String routePath = '/abilityimagelist';

  @override
  State<AbilityimagelistWidget> createState() => _AbilityimagelistWidgetState();
}

class _AbilityimagelistWidgetState extends State<AbilityimagelistWidget> {
  late AbilityimagelistModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AbilityimagelistModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryText,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 0.0, 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.safePop();
              },
              child: Icon(
                Icons.keyboard_arrow_left,
                color: FlutterFlowTheme.of(context).primaryBackground,
                size: 24.0,
              ),
            ),
          ),
          title: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              '능력 이미지',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    fontSize: 20.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 25.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      final selectedMedia =
                          await selectMediaWithSourceBottomSheet(
                        context: context,
                        allowPhoto: true,
                      );
                      if (selectedMedia != null &&
                          selectedMedia.every((m) =>
                              validateFileFormat(m.storagePath, context))) {
                        safeSetState(() =>
                            _model.isDataUploading_uploadabilityimage = true);
                        var selectedUploadedFiles = <FFUploadedFile>[];

                        var downloadUrls = <String>[];
                        try {
                          selectedUploadedFiles = selectedMedia
                              .map((m) => FFUploadedFile(
                                    name: m.storagePath.split('/').last,
                                    bytes: m.bytes,
                                    height: m.dimensions?.height,
                                    width: m.dimensions?.width,
                                    blurHash: m.blurHash,
                                    originalFilename: m.originalFilename,
                                  ))
                              .toList();

                          downloadUrls = (await Future.wait(
                            selectedMedia.map(
                              (m) async =>
                                  await uploadData(m.storagePath, m.bytes),
                            ),
                          ))
                              .where((u) => u != null)
                              .map((u) => u!)
                              .toList();
                        } finally {
                          _model.isDataUploading_uploadabilityimage = false;
                        }
                        if (selectedUploadedFiles.length ==
                                selectedMedia.length &&
                            downloadUrls.length == selectedMedia.length) {
                          safeSetState(() {
                            _model.uploadedLocalFile_uploadabilityimage =
                                selectedUploadedFiles.first;
                            _model.uploadedFileUrl_uploadabilityimage =
                                downloadUrls.first;
                          });
                        } else {
                          safeSetState(() {});
                          return;
                        }
                      }

                      _model.addToAbilities(AbilityStructStruct(
                        ability: '\' \'',
                        imageUrl: _model.uploadedFileUrl_uploadabilityimage,
                      ));
                      safeSetState(() {});
                      FFAppState().Abilities =
                          _model.abilities.toList().cast<AbilityStructStruct>();
                      safeSetState(() {});
                    },
                    child: FaIcon(
                      FontAwesomeIcons.images,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final abilityitem = FFAppState().Abilities.toList();

                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20.0,
                          mainAxisSpacing: 20.0,
                          childAspectRatio: 0.7,
                        ),
                        scrollDirection: Axis.vertical,
                        itemCount: abilityitem.length,
                        itemBuilder: (context, abilityitemIndex) {
                          final abilityitemItem = abilityitem[abilityitemIndex];
                          return AbilitystructWidget(
                            key: Key(
                                'Keynuf_${abilityitemIndex}_of_${abilityitem.length}'),
                            abilityTags: widget.abilityTags,
                            item: abilityitemItem,
                          );
                        },
                      );
                    },
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: SafeArea(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              FFAppState().Abilities = functions
                                  .getEmptyabilityList()
                                  .toList()
                                  .cast<AbilityStructStruct>();
                              FFAppState().emotions = functions
                                  .getEmptyEmotionList()
                                  .toList()
                                  .cast<EmotionStructStruct>();
                              safeSetState(() {});
                              context.safePop();
                            },
                            text: '',
                            icon: Icon(
                              Icons.auto_fix_high,
                              size: 25.0,
                            ),
                            options: FFButtonOptions(
                              width: 50.0,
                              height: 50.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconAlignment: IconAlignment.start,
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  7.0, 0.0, 0.0, 0.0),
                              iconColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              final selectedMedia =
                                  await selectMediaWithSourceBottomSheet(
                                context: context,
                                allowPhoto: true,
                              );
                              if (selectedMedia != null &&
                                  selectedMedia.every((m) => validateFileFormat(
                                      m.storagePath, context))) {
                                safeSetState(() => _model
                                    .isDataUploading_uploadability = true);
                                var selectedUploadedFiles = <FFUploadedFile>[];

                                var downloadUrls = <String>[];
                                try {
                                  selectedUploadedFiles = selectedMedia
                                      .map((m) => FFUploadedFile(
                                            name: m.storagePath.split('/').last,
                                            bytes: m.bytes,
                                            height: m.dimensions?.height,
                                            width: m.dimensions?.width,
                                            blurHash: m.blurHash,
                                            originalFilename:
                                                m.originalFilename,
                                          ))
                                      .toList();

                                  downloadUrls = (await Future.wait(
                                    selectedMedia.map(
                                      (m) async => await uploadData(
                                          m.storagePath, m.bytes),
                                    ),
                                  ))
                                      .where((u) => u != null)
                                      .map((u) => u!)
                                      .toList();
                                } finally {
                                  _model.isDataUploading_uploadability = false;
                                }
                                if (selectedUploadedFiles.length ==
                                        selectedMedia.length &&
                                    downloadUrls.length ==
                                        selectedMedia.length) {
                                  safeSetState(() {
                                    _model.uploadedLocalFile_uploadability =
                                        selectedUploadedFiles.first;
                                    _model.uploadedFileUrl_uploadability =
                                        downloadUrls.first;
                                  });
                                } else {
                                  safeSetState(() {});
                                  return;
                                }
                              }

                              FFAppState().addToAbilities(AbilityStructStruct(
                                ability: '',
                                imageUrl:
                                    _model.uploadedFileUrl_uploadabilityimage,
                              ));
                              safeSetState(() {});
                            },
                            text: '업로드',
                            options: FFButtonOptions(
                              width: 290.0,
                              height: 50.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
