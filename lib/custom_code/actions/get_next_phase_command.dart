// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

String getNextPhaseCommand(int currentCount) {
  String phase = "";
  if (currentCount < 50) {
    phase = "Phase 1: Introduction (Ep 1~5). Introduce characters and setting.";
  } else if (currentCount < 150) {
    phase = "Phase 2: Development (Ep 6~15). Events begin to unfold.";
  } else if (currentCount < 350) {
    phase = "Phase 3: Rising Action (Ep 16~35). Deepen the conflict.";
  } else if (currentCount < 450) {
    phase = "Phase 4: Climax (Ep 36~45). The biggest conflict occurs!";
  } else {
    phase = "Phase 5: Conclusion (Ep 46~50). Start wrapping up the story.";
  }

  return "[SYSTEM: Next Scene. ${phase}. Keep writing vividly.]";
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
