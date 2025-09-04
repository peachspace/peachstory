import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'charactermain_widget.dart' show CharactermainWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CharactermainModel extends FlutterFlowModel<CharactermainWidget> {
  ///  Local state fields for this page.

  bool isHearted = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in charactermain widget.
  CharacterRecord? loadedCharacter;
  // Stores action output result for [Backend Call - Read Document] action in charactermain widget.
  UsersRecord? currentUserDoc;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
