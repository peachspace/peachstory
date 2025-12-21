import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'chatsheet_model.dart';
export 'chatsheet_model.dart';

class ChatsheetWidget extends StatefulWidget {
  const ChatsheetWidget({
    super.key,
    this.chatRef,
  });

  final DocumentReference? chatRef;

  @override
  State<ChatsheetWidget> createState() => _ChatsheetWidgetState();
}

class _ChatsheetWidgetState extends State<ChatsheetWidget> {
  late ChatsheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatsheetModel());

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
              Navigator.pop(context);
              var confirmDialogResponse = await showDialog<bool>(
                    context: context,
                    builder: (alertDialogContext) {
                      return WebViewAware(
                        child: AlertDialog(
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
                        ),
                      );
                    },
                  ) ??
                  false;
              if (confirmDialogResponse) {
                try {
                  final result =
                      await FirebaseFunctions.instanceFor(region: 'us-central1')
                          .httpsCallable('deleteChatWithMessages')
                          .call({
                    "chatDocPath": widget.chatRef!.path,
                  });
                  _model.delete =
                      DeleteChatWithMessagesCloudFunctionCallResponse(
                    data: result.data,
                    succeeded: true,
                    resultAsString: result.data.toString(),
                    jsonBody: result.data,
                  );
                } on FirebaseFunctionsException catch (error) {
                  _model.delete =
                      DeleteChatWithMessagesCloudFunctionCallResponse(
                    errorCode: error.code,
                    succeeded: false,
                  );
                }
              }
              Navigator.pop(context);

              safeSetState(() {});
            },
            text: '삭제하기',
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
      ],
    );
  }
}
