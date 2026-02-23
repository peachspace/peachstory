import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'eventimagelist_widget.dart' show EventimagelistWidget;
import 'package:flutter/material.dart';

class EventimagelistModel extends FlutterFlowModel<EventimagelistWidget> {
  ///  Local state fields for this page.

  List<EventStructStruct> events = [];
  void addToEvents(EventStructStruct item) => events.add(item);
  void removeFromEvents(EventStructStruct item) => events.remove(item);
  void removeAtIndexFromEvents(int index) => events.removeAt(index);
  void insertAtIndexInEvents(int index, EventStructStruct item) =>
      events.insert(index, item);
  void updateEventsAtIndex(int index, Function(EventStructStruct) updateFn) =>
      events[index] = updateFn(events[index]);

  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadevent = false;
  FFUploadedFile uploadedLocalFile_uploadevent =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadevent = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
