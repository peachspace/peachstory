import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'paysuccess_model.dart';
export 'paysuccess_model.dart';

class PaysuccessWidget extends StatefulWidget {
  const PaysuccessWidget({super.key});

  static String routeName = 'paysuccess';
  static String routePath = '/paysuccess';

  @override
  State<PaysuccessWidget> createState() => _PaysuccessWidgetState();
}

class _PaysuccessWidgetState extends State<PaysuccessWidget> {
  late PaysuccessModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaysuccessModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        final result =
            await FirebaseFunctions.instanceFor(region: 'asia-northeast3')
                .httpsCallable('verifyKomojuPayment')
                .call({
          "sessionId": FFAppState().komojuSessionId,
        });
        _model.verifyResult = VerifyKomojuPaymentCloudFunctionCallResponse(
          data: result.data,
          succeeded: true,
          resultAsString: result.data.toString(),
          jsonBody: result.data,
        );
      } on FirebaseFunctionsException catch (error) {
        _model.verifyResult = VerifyKomojuPaymentCloudFunctionCallResponse(
          errorCode: error.code,
          succeeded: false,
        );
      }

      if (_model.verifyResult!.succeeded!) {
        var confirmDialogResponse = await showDialog<bool>(
              context: context,
              builder: (alertDialogContext) {
                return WebViewAware(
                  child: AlertDialog(
                    title: Text('충전 완료'),
                    content: Text('피치 충전을 완료하였습니다.'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext, true),
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
            ) ??
            false;
      } else {
        var confirmDialogResponse = await showDialog<bool>(
              context: context,
              builder: (alertDialogContext) {
                return WebViewAware(
                  child: AlertDialog(
                    title: Text('충전 실패'),
                    content: Text('피치 충전에 실패하였습니다.'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(alertDialogContext, true),
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
            ) ??
            false;
      }
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
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [],
          ),
        ),
      ),
    );
  }
}
