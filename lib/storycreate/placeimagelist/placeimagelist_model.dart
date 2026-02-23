import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'placeimagelist_widget.dart' show PlaceimagelistWidget;
import 'package:flutter/material.dart';

class PlaceimagelistModel extends FlutterFlowModel<PlaceimagelistWidget> {
  ///  Local state fields for this page.

  List<PlaceStructStruct> places = [];
  void addToPlaces(PlaceStructStruct item) => places.add(item);
  void removeFromPlaces(PlaceStructStruct item) => places.remove(item);
  void removeAtIndexFromPlaces(int index) => places.removeAt(index);
  void insertAtIndexInPlaces(int index, PlaceStructStruct item) =>
      places.insert(index, item);
  void updatePlacesAtIndex(int index, Function(PlaceStructStruct) updateFn) =>
      places[index] = updateFn(places[index]);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
