import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'temphomepage_widget.dart' show TemphomepageWidget;
import 'package:flutter/material.dart';

class TemphomepageModel extends FlutterFlowModel<TemphomepageWidget> {
  ///  Local state fields for this page.

  String selectedCategory = '추천';

  String selectedSort = '인기순';

  DateTime? rankingStartDate;

  String rankPeriod = '일간';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
