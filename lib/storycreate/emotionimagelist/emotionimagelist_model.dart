import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'emotionimagelist_widget.dart' show EmotionimagelistWidget;
import 'package:flutter/material.dart';

class EmotionimagelistModel extends FlutterFlowModel<EmotionimagelistWidget> {
  ///  Local state fields for this page.

  List<EmotionStructStruct> emotions = [];
  void addToEmotions(EmotionStructStruct item) => emotions.add(item);
  void removeFromEmotions(EmotionStructStruct item) => emotions.remove(item);
  void removeAtIndexFromEmotions(int index) => emotions.removeAt(index);
  void insertAtIndexInEmotions(int index, EmotionStructStruct item) =>
      emotions.insert(index, item);
  void updateEmotionsAtIndex(
          int index, Function(EmotionStructStruct) updateFn) =>
      emotions[index] = updateFn(emotions[index]);

  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploademotion = false;
  FFUploadedFile uploadedLocalFile_uploademotion =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploademotion = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
