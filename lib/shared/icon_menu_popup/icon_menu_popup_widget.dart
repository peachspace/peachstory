import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'icon_menu_popup_model.dart';
export 'icon_menu_popup_model.dart';

class IconMenuPopupWidget extends StatefulWidget {
  const IconMenuPopupWidget({super.key});

  @override
  State<IconMenuPopupWidget> createState() => _IconMenuPopupWidgetState();
}

class _IconMenuPopupWidgetState extends State<IconMenuPopupWidget> {
  late IconMenuPopupModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IconMenuPopupModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FFButtonWidget(
          onPressed: () {
            print('Button pressed ...');
          },
          text: 'Edit Post',
          options: FFButtonOptions(
            width: double.infinity,
            height: 60.0,
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: Color(0xFFF1F4F8),
            textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.normal,
                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                  ),
                  color: Color(0xFF14181B),
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.normal,
                  fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                ),
            elevation: 2.0,
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0.0),
              bottomRight: Radius.circular(0.0),
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
        ),
        FFButtonWidget(
          onPressed: () {
            print('Button pressed ...');
          },
          text: 'Delete Story',
          options: FFButtonOptions(
            width: double.infinity,
            height: 60.0,
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: Color(0xFFF1F4F8),
            textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.normal,
                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                  ),
                  color: Color(0xFF14181B),
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.normal,
                  fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                ),
            elevation: 2.0,
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(0.0),
            ),
          ),
        ),
      ],
    );
  }
}
