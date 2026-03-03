import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'abilityimagelist_widget.dart' show AbilityimagelistWidget;
import 'package:flutter/material.dart';

class AbilityimagelistModel extends FlutterFlowModel<AbilityimagelistWidget> {
  ///  Local state fields for this page.

  List<AbilityStructStruct> abilities = [];
  void addToAbilities(AbilityStructStruct item) => abilities.add(item);
  void removeFromAbilities(AbilityStructStruct item) => abilities.remove(item);
  void removeAtIndexFromAbilities(int index) => abilities.removeAt(index);
  void insertAtIndexInAbilities(int index, AbilityStructStruct item) =>
      abilities.insert(index, item);
  void updateAbilitiesAtIndex(
          int index, Function(AbilityStructStruct) updateFn) =>
      abilities[index] = updateFn(abilities[index]);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
