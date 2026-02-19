import '/backend/backend.dart';
import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'createlisteditanddeletesheet_model.dart';
export 'createlisteditanddeletesheet_model.dart';

class CreatelisteditanddeletesheetWidget extends StatefulWidget {
  const CreatelisteditanddeletesheetWidget({
    super.key,
    required this.storyDoc,
  });

  final StoriesRecord? storyDoc;

  @override
  State<CreatelisteditanddeletesheetWidget> createState() =>
      _CreatelisteditanddeletesheetWidgetState();
}

class _CreatelisteditanddeletesheetWidgetState
    extends State<CreatelisteditanddeletesheetWidget> {
  late CreatelisteditanddeletesheetModel _model;

  void _closeSheetIfPossible() {
    if (!mounted) {
      return;
    }
    final navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreatelisteditanddeletesheetModel());

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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 25.0, 0.0),
          child: FFButtonWidget(
            onPressed: () async {
              final rootContext = appNavigatorKey.currentContext;
              _closeSheetIfPossible();
              if (rootContext == null) {
                return;
              }

              GoRouter.of(rootContext).pushNamed(
                StorycreatepageWidget.routeName,
                queryParameters: {
                  'storyDoc': serializeParam(
                    widget.storyDoc,
                    ParamType.Document,
                  ),
                  'storyToEdit': serializeParam(
                    widget.storyDoc,
                    ParamType.Document,
                  ),
                }.withoutNulls,
                extra: <String, dynamic>{
                  'storyDoc': widget.storyDoc,
                  'storyToEdit': widget.storyDoc,
                },
              );
            },
            text: '수정하기',
            options: FFButtonOptions(
              width: double.infinity,
              height: 60.0,
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).secondaryBackground,
              textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.normal,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                    ),
                    color: Color(0xFF14181B),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.normal,
                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                  ),
              elevation: 2.0,
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 1.0,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 25.0, 0.0),
          child: FFButtonWidget(
            onPressed: () async {
              var confirmDialogResponse = await showDialog<bool>(
                    context: context,
                    builder: (alertDialogContext) {
                      return AlertDialog(
                        title: Text('삭제'),
                        content: Text('정말 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(alertDialogContext, false),
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(alertDialogContext, true),
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;
              if (confirmDialogResponse) {
                try {
                  final result =
                      await FirebaseFunctions.instanceFor(region: 'us-central1')
                          .httpsCallable('deleteStoryWithData')
                          .call({
                    "storyPath": widget.storyDoc!.reference.path,
                  });
                  _model.cloudFunction =
                      DeleteStoryWithDataCloudFunctionCallResponse(
                    data: result.data,
                    succeeded: true,
                    resultAsString: result.data.toString(),
                    jsonBody: result.data,
                  );
                } on FirebaseFunctionsException catch (error) {
                  _model.cloudFunction =
                      DeleteStoryWithDataCloudFunctionCallResponse(
                    errorCode: error.code,
                    succeeded: false,
                  );
                }
              }
              _closeSheetIfPossible();

              safeSetState(() {});
            },
            text: '삭제하기',
            options: FFButtonOptions(
              width: double.infinity,
              height: 60.0,
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: Color(0xFFF1F4F8),
              textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.normal,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                    ),
                    color: Color(0xFF14181B),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.normal,
                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                  ),
              elevation: 2.0,
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 1.0,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
                topLeft: Radius.circular(0.0),
                topRight: Radius.circular(0.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
