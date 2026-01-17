import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'searchpage_widget.dart' show SearchpageWidget;
import 'package:flutter/material.dart';

class SearchpageModel extends FlutterFlowModel<SearchpageWidget> {
  ///  Local state fields for this page.

  String searchSortOption = '인기순';

  List<StoriesRecord> searchResultList = [];
  void addToSearchResultList(StoriesRecord item) => searchResultList.add(item);
  void removeFromSearchResultList(StoriesRecord item) =>
      searchResultList.remove(item);
  void removeAtIndexFromSearchResultList(int index) =>
      searchResultList.removeAt(index);
  void insertAtIndexInSearchResultList(int index, StoriesRecord item) =>
      searchResultList.insert(index, item);
  void updateSearchResultListAtIndex(
          int index, Function(StoriesRecord) updateFn) =>
      searchResultList[index] = updateFn(searchResultList[index]);

  ///  State fields for stateful widgets in this page.

  // State field(s) for searchTextField widget.
  FocusNode? searchTextFieldFocusNode;
  TextEditingController? searchTextFieldTextController;
  String? Function(BuildContext, String?)?
      searchTextFieldTextControllerValidator;
  // Algolia Search Results from action on searchbutton
  List<StoriesRecord>? algoliaSearchResults = [];
  // State field(s) for searchDropDown widget.
  String? searchDropDownValue;
  FormFieldController<String>? searchDropDownValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    searchTextFieldFocusNode?.dispose();
    searchTextFieldTextController?.dispose();
  }
}
