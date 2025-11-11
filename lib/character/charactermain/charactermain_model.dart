import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'charactermain_widget.dart' show CharactermainWidget;
import 'package:flutter/material.dart';

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
