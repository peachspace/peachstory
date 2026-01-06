import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'homepage_widget.dart' show HomepageWidget;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomepageModel extends FlutterFlowModel<HomepageWidget> {
  ///  Local state fields for this page.

  List<CombinedListItemStructStruct> combinedList = [];
  void addToCombinedList(CombinedListItemStructStruct item) =>
      combinedList.add(item);
  void removeFromCombinedList(CombinedListItemStructStruct item) =>
      combinedList.remove(item);
  void removeAtIndexFromCombinedList(int index) => combinedList.removeAt(index);
  void insertAtIndexInCombinedList(
          int index, CombinedListItemStructStruct item) =>
      combinedList.insert(index, item);
  void updateCombinedListAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      combinedList[index] = updateFn(combinedList[index]);

  List<CombinedListItemStructStruct> rankinglist = [];
  void addToRankinglist(CombinedListItemStructStruct item) =>
      rankinglist.add(item);
  void removeFromRankinglist(CombinedListItemStructStruct item) =>
      rankinglist.remove(item);
  void removeAtIndexFromRankinglist(int index) => rankinglist.removeAt(index);
  void insertAtIndexInRankinglist(
          int index, CombinedListItemStructStruct item) =>
      rankinglist.insert(index, item);
  void updateRankinglistAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      rankinglist[index] = updateFn(rankinglist[index]);

  List<CombinedListItemStructStruct> newlist = [];
  void addToNewlist(CombinedListItemStructStruct item) => newlist.add(item);
  void removeFromNewlist(CombinedListItemStructStruct item) =>
      newlist.remove(item);
  void removeAtIndexFromNewlist(int index) => newlist.removeAt(index);
  void insertAtIndexInNewlist(int index, CombinedListItemStructStruct item) =>
      newlist.insert(index, item);
  void updateNewlistAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      newlist[index] = updateFn(newlist[index]);

  List<CombinedListItemStructStruct> hotlist = [];
  void addToHotlist(CombinedListItemStructStruct item) => hotlist.add(item);
  void removeFromHotlist(CombinedListItemStructStruct item) =>
      hotlist.remove(item);
  void removeAtIndexFromHotlist(int index) => hotlist.removeAt(index);
  void insertAtIndexInHotlist(int index, CombinedListItemStructStruct item) =>
      hotlist.insert(index, item);
  void updateHotlistAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      hotlist[index] = updateFn(hotlist[index]);

  List<CombinedListItemStructStruct> recommendlist = [];
  void addToRecommendlist(CombinedListItemStructStruct item) =>
      recommendlist.add(item);
  void removeFromRecommendlist(CombinedListItemStructStruct item) =>
      recommendlist.remove(item);
  void removeAtIndexFromRecommendlist(int index) =>
      recommendlist.removeAt(index);
  void insertAtIndexInRecommendlist(
          int index, CombinedListItemStructStruct item) =>
      recommendlist.insert(index, item);
  void updateRecommendlistAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      recommendlist[index] = updateFn(recommendlist[index]);

  String selectedCategory = '추천';

  String selectedSort = '인기순';

  List<CombinedListItemStructStruct> categoryItemList = [];
  void addToCategoryItemList(CombinedListItemStructStruct item) =>
      categoryItemList.add(item);
  void removeFromCategoryItemList(CombinedListItemStructStruct item) =>
      categoryItemList.remove(item);
  void removeAtIndexFromCategoryItemList(int index) =>
      categoryItemList.removeAt(index);
  void insertAtIndexInCategoryItemList(
          int index, CombinedListItemStructStruct item) =>
      categoryItemList.insert(index, item);
  void updateCategoryItemListAtIndex(
          int index, Function(CombinedListItemStructStruct) updateFn) =>
      categoryItemList[index] = updateFn(categoryItemList[index]);

  String selectedRankingPeriod = '일간';

  String constCharacterType = 'character';

  String constStoryType = 'story';

  String selectedCategoryType = 'character';

  String selectedCategoryName = '로맨스';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - loadRankingPosts] action in homepage widget.
  List<CombinedListItemStructStruct>? rankingoutput;
  // Stores action output result for [Custom Action - loadNewPosts] action in homepage widget.
  List<CombinedListItemStructStruct>? newoutput;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 1;

  // Stores action output result for [Custom Action - loadRankingData] action in Tab widget.
  List<CombinedListItemStructStruct>? initialRankingResult;
  // Stores action output result for [Custom Action - loadRankingData] action in dailybutton widget.
  List<CombinedListItemStructStruct>? newRankingResult;
  // Stores action output result for [Custom Action - loadRankingData] action in weeklybutton widget.
  List<CombinedListItemStructStruct>? newRankingResult1;
  // Stores action output result for [Custom Action - loadRankingData] action in monthlybutton widget.
  List<CombinedListItemStructStruct>? newRankingResult2;
  // Stores action output result for [Custom Action - loadCategoryRanking] action in Tab widget.
  List<CombinedListItemStructStruct>? initialCategoryResult;
  // Stores action output result for [Custom Action - loadCategoryRanking] action in Container widget.
  List<CombinedListItemStructStruct>? categoryItemsResult1;
  // State field(s) for categoryDropDown widget.
  String? categoryDropDownValue;
  FormFieldController<String>? categoryDropDownValueController;
  // Stores action output result for [Custom Action - loadCategoryRanking] action in categoryDropDown widget.
  List<CombinedListItemStructStruct>? newItems;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
