import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'heartlistpage_model.dart';
export 'heartlistpage_model.dart';

class HeartlistpageWidget extends StatefulWidget {
  const HeartlistpageWidget({super.key});

  static String routeName = 'heartlistpage';
  static String routePath = '/heartlistpage';

  @override
  State<HeartlistpageWidget> createState() => _HeartlistpageWidgetState();
}

class _HeartlistpageWidgetState extends State<HeartlistpageWidget> {
  late HeartlistpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HeartlistpageModel());

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
