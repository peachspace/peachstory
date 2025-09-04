import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_web_view.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'payweb_model.dart';
export 'payweb_model.dart';

class PaywebWidget extends StatefulWidget {
  const PaywebWidget({
    super.key,
    this.checkoutUrl,
  });

  final String? checkoutUrl;

  static String routeName = 'payweb';
  static String routePath = '/payweb';

  @override
  State<PaywebWidget> createState() => _PaywebWidgetState();
}

class _PaywebWidgetState extends State<PaywebWidget> {
  late PaywebModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaywebModel());

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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: Icon(
            Icons.arrow_back,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 24.0,
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: FlutterFlowWebView(
            content: widget!.checkoutUrl!,
            bypass: false,
            height: 500.0,
            verticalScroll: false,
            horizontalScroll: false,
          ),
        ),
      ),
    );
  }
}
