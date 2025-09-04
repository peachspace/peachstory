import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/story1/storyusername/storyusername_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'storymain_widget.dart' show StorymainWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class StorymainModel extends FlutterFlowModel<StorymainWidget> {
  ///  Local state fields for this page.

  bool isHearted = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in storymain widget.
  StoriesRecord? loadedStory;
  // Stores action output result for [Backend Call - Read Document] action in storymain widget.
  UsersRecord? currentUserDoc;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
