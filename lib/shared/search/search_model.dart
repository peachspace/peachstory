import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'search_widget.dart' show SearchWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchModel extends FlutterFlowModel<SearchWidget> {
  ///  Local state fields for this page.

  List<CombinedListItemStructStruct> searchResults = [];
  void addToSearchResults(CombinedListItemStructStruct item) =>
      searchResults.add(item);
  void removeFromSearchResults(CombinedListItemStructStruct item) =>
      searchResults.remove(item);
  void removeAtIndexFromSearchResults(int index) =>
      searchResults.removeAt(index);
  void insertAtIndexInSearchResults(
          int index, CombinedListItemStructStruct item) =>
      searchResults.insert(index, item);
  void updateSearchResultsAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      searchResults[index] = updateFn(searchResults[index]);

  String searchSortOption = '인기순';

  String conststory = 'story';

  String constcharacter = 'character';

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (apiSearchAll)] action in Icon widget.
  ApiCallResponse? apiResult;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Stores action output result for [Backend Call - API (apiSearchAll)] action in DropDown widget.
  ApiCallResponse? sortedApiResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
