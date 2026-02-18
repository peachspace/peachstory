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

  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadabilityimage = false;
  FFUploadedFile uploadedLocalFile_uploadabilityimage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadabilityimage = '';

  bool isDataUploading_uploadability = false;
  FFUploadedFile uploadedLocalFile_uploadability =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadability = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
