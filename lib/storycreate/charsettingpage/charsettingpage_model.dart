import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'charsettingpage_widget.dart' show CharsettingpageWidget;
import 'package:flutter/material.dart';

class CharsettingpageModel extends FlutterFlowModel<CharsettingpageWidget> {
  ///  Local state fields for this page.

  CharacterStructStruct? editchar;
  void updateEditcharStruct(Function(CharacterStructStruct) updateFn) {
    updateFn(editchar ??= CharacterStructStruct());
  }

  ///  State fields for stateful widgets in this page.

  // State field(s) for emotionplacedropdown widget.
  String? emotionplacedropdownValue;
  FormFieldController<String>? emotionplacedropdownValueController;
  // State field(s) for abbilitynametextField widget.
  FocusNode? abbilitynametextFieldFocusNode;
  TextEditingController? abbilitynametextFieldTextController;
  String? Function(BuildContext, String?)?
      abbilitynametextFieldTextControllerValidator;
  // State field(s) for abilityexplanationtextField widget.
  FocusNode? abilityexplanationtextFieldFocusNode;
  TextEditingController? abilityexplanationtextFieldTextController;
  String? Function(BuildContext, String?)?
      abilityexplanationtextFieldTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    abbilitynametextFieldFocusNode?.dispose();
    abbilitynametextFieldTextController?.dispose();

    abilityexplanationtextFieldFocusNode?.dispose();
    abilityexplanationtextFieldTextController?.dispose();
  }
}
