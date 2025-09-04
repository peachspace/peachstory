import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'heartlist_model.dart';
export 'heartlist_model.dart';

class HeartlistWidget extends StatefulWidget {
  const HeartlistWidget({super.key});

  static String routeName = 'heartlist';
  static String routePath = '/heartlist';

  @override
  State<HeartlistWidget> createState() => _HeartlistWidgetState();
}

class _HeartlistWidgetState extends State<HeartlistWidget> {
  late HeartlistModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HeartlistModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.currentUserDoc =
          await UsersRecord.getDocumentOnce(currentUserReference!);
      _model.heartedItems = await actions.getHeartedPosts(
        _model.currentUserDoc!.heartedPostPaths.toList(),
      );
      _model.myHeartedList =
          _model.heartedItems!.toList().cast<CombinedListItemStructStruct>();
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Builder(
                builder: (context) {
                  final item = _model.myHeartedList.toList();

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: item.length,
                    itemBuilder: (context, itemIndex) {
                      final itemItem = item[itemIndex];
                      return Container(
                          width: 100, height: 100, color: Colors.green);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
