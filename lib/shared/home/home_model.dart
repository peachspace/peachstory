import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
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

  // Stores action output result for [Custom Action - loadRankingPosts] action in home widget.
  List<CombinedListItemStructStruct>? rankingoutput;
  // Stores action output result for [Custom Action - loadNewPosts] action in home widget.
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
  // Stores action output result for [Custom Action - loadRankingData] action in Text widget.
  List<CombinedListItemStructStruct>? newRankingResult;
  // Stores action output result for [Custom Action - loadRankingData] action in Text widget.
  List<CombinedListItemStructStruct>? newRankingResult1;
  // Stores action output result for [Custom Action - loadRankingData] action in Text widget.
  List<CombinedListItemStructStruct>? newRankingResult2;
  // Stores action output result for [Custom Action - loadCategoryRanking] action in Tab widget.
  List<CombinedListItemStructStruct>? initialCategoryResult;
  // Stores action output result for [Custom Action - loadCategoryRanking] action in Container widget.
  List<CombinedListItemStructStruct>? categoryItemsResult;
  // Stores action output result for [Custom Action - loadCategoryRanking] action in Container widget.
  List<CombinedListItemStructStruct>? categoryItemsResult1;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Stores action output result for [Custom Action - loadCategoryRanking] action in DropDown widget.
  List<CombinedListItemStructStruct>? newItems;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
