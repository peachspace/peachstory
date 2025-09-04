import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'paysuccess_widget.dart' show PaysuccessWidget;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class PaysuccessModel extends FlutterFlowModel<PaysuccessWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Cloud Function - verifyKomojuPayment] action in paysuccess widget.
  VerifyKomojuPaymentCloudFunctionCallResponse? verifyResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
