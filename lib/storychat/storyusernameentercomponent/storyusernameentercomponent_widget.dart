import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storyusernameentercomponent_model.dart';
export 'storyusernameentercomponent_model.dart';

class StoryusernameentercomponentWidget extends StatefulWidget {
  const StoryusernameentercomponentWidget({
    super.key,
    required this.storydoc,
  });

  final StoriesRecord? storydoc;

  @override
  State<StoryusernameentercomponentWidget> createState() =>
      _StoryusernameentercomponentWidgetState();
}

class _StoryusernameentercomponentWidgetState
    extends State<StoryusernameentercomponentWidget> {
  late StoryusernameentercomponentModel _model;

  String _resolveGuideText(StoriesRecord? story) {
    if (story == null) return '';
    final candidateFields = <String>[
      'guideText',
      'guidetext',
      'guidetextfield',
      'guide',
      'guide_text',
    ];
    for (final field in candidateFields) {
      final dynamic rawGuide = story.snapshotData[field];
      final guideText = rawGuide is String ? rawGuide.trim() : '';
      if (guideText.isNotEmpty) {
        return guideText;
      }
    }
    return story.authorNotes.trim();
  }

  Future<bool> _shouldShowGuideForStory(DocumentReference? storyRef) async {
    if (storyRef == null) return false;
    final prefs = await SharedPreferences.getInstance();
    final key = 'guide_seen_${storyRef.path}';
    final seen = prefs.getBool(key) ?? false;
    if (!seen) {
      await prefs.setBool(key, true);
      return true;
    }
    return false;
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StoryusernameentercomponentModel());

    _model.usernameTextFieldTextController ??= TextEditingController();
    _model.usernameTextFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryText,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 25.0),
            child: Text(
              '이야기 속의 당신의 이름은?',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    fontSize: 15.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 5.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.usernameTextFieldTextController,
                          focusNode: _model.usernameTextFieldFocusNode,
                          autofocus: false,
                          enabled: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: false,
                            hintText: '이름을 입력하세요...',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
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
                                color: FlutterFlowTheme.of(context).alternate,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                          maxLength: 30,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                          cursorColor: FlutterFlowTheme.of(context).alternate,
                          enableInteractiveSelection: false,
                          validator: _model
                              .usernameTextFieldTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    ),
                    FlutterFlowIconButton(
                      borderRadius: 100.0,
                      buttonSize: 40.0,
                      icon: Icon(
                        Icons.check_sharp,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: 24.0,
                      ),
                      showLoadingIndicator: true,
                      onPressed: () async {
                        if (_model.usernameTextFieldTextController.text
                            .trim()
                            .isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '이름을 입력하세요.',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                              ),
                              duration: Duration(milliseconds: 2000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).info,
                            ),
                          );
                          return;
                        }
                        FFAppState().storyUserName =
                            _model.usernameTextFieldTextController.text;
                        safeSetState(() {});

                        var storychatsRecordReference =
                            StorychatsRecord.collection.doc();
                        await storychatsRecordReference
                            .set(createStorychatsRecordData(
                          storyRef: widget.storydoc?.reference,
                          userRef: currentUserReference,
                          userInChatName:
                              _model.usernameTextFieldTextController.text,
                          selectedAiModel: 'claude-3-haiku-20240307',
                          creatorRef: widget.storydoc?.creatorRef,
                        ));
                        _model.newChatDoc =
                            StorychatsRecord.getDocumentFromData(
                                createStorychatsRecordData(
                                  storyRef: widget.storydoc?.reference,
                                  userRef: currentUserReference,
                                  userInChatName: _model
                                      .usernameTextFieldTextController.text,
                                  selectedAiModel: 'claude-3-haiku-20240307',
                                  creatorRef: widget.storydoc?.creatorRef,
                                ),
                                storychatsRecordReference);

                        final shouldShowGuide =
                            await _shouldShowGuideForStory(
                          widget.storydoc?.reference,
                        );

                        if (shouldShowGuide) {
                          context.pushNamed(
                            GuidepageWidget.routeName,
                            queryParameters: {
                              'storyRef': serializeParam(
                                widget.storydoc?.reference,
                                ParamType.DocumentReference,
                              ),
                              'userInChatName': serializeParam(
                                _model.usernameTextFieldTextController.text,
                                ParamType.String,
                              ),
                              'storychatRef': serializeParam(
                                _model.newChatDoc?.reference,
                                ParamType.DocumentReference,
                              ),
                              'guideText': serializeParam(
                                _resolveGuideText(widget.storydoc),
                                ParamType.String,
                              ),
                            }.withoutNulls,
                          );
                        } else {
                          context.pushNamed(
                            VisualnovelpageWidget.routeName,
                            queryParameters: {
                              'storyRef': serializeParam(
                                widget.storydoc?.reference,
                                ParamType.DocumentReference,
                              ),
                              'userInChatName': serializeParam(
                                _model.usernameTextFieldTextController.text,
                                ParamType.String,
                              ),
                              'storychatRef': serializeParam(
                                _model.newChatDoc?.reference,
                                ParamType.DocumentReference,
                              ),
                            }.withoutNulls,
                          );
                        }

                        safeSetState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
