import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/storycreate/imagecreatebottomsheet/imagecreatebottomsheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'source_select_sheet_model.dart';
export 'source_select_sheet_model.dart';

class SourceSelectSheetWidget extends StatefulWidget {
  const SourceSelectSheetWidget({
    super.key,
    required this.imageMode,
    this.receivedBasePrompt,
    this.isSourceEmpty,
    this.warningMessage,
    this.receivedworldview,
    this.receivedcharsettings,
    this.charList,
    this.receivedSeed,
    this.receivedBaseimage,
    this.receivedevent,
    this.receivedcharappearance,
  });

  final String? imageMode;
  final String? receivedBasePrompt;
  final bool? isSourceEmpty;
  final String? warningMessage;
  final String? receivedworldview;
  final String? receivedcharsettings;
  final List<CharacterStructStruct>? charList;
  final int? receivedSeed;
  final String? receivedBaseimage;
  final String? receivedevent;
  final String? receivedcharappearance;

  @override
  State<SourceSelectSheetWidget> createState() =>
      _SourceSelectSheetWidgetState();
}

class _SourceSelectSheetWidgetState extends State<SourceSelectSheetWidget> {
  late SourceSelectSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SourceSelectSheetModel());

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
        Stack(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 25.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {},
                text: 'AI생성',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 60.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                        ),
                        color: Color(0xFF14181B),
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyLarge.fontStyle,
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
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                child: Text(
                  '추후 업데이트될 예정이에요.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).error,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 25.0, 0.0),
          child: FFButtonWidget(
            onPressed: () async {
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                enableDrag: false,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: ImagecreatebottomsheetWidget(
                      imageMode: widget.imageMode!,
                      isSourceEmpty: widget.isSourceEmpty!,
                      warningMessage: widget.warningMessage!,
                      receivedSeed: widget.receivedSeed,
                      receivedBasePrompt: widget.receivedBasePrompt,
                      receivedworldview: widget.receivedworldview,
                      receivedcharsettings: widget.receivedcharsettings,
                      charList: widget.charList,
                      receivedbaseimage: '',
                      isUploadMode: true,
                      receivedevent: widget.receivedevent,
                      receivedcharappearance: widget.receivedcharappearance,
                    ),
                  );
                },
              ).then(
                  (value) => safeSetState(() => _model.uploadResult = value));

              Navigator.pop(
                  context,
                  GenResultStructStruct(
                    imageurl: _model.uploadResult?.imageurl,
                    seed: _model.uploadResult?.seed,
                    text: _model.uploadResult?.text,
                  ));

              safeSetState(() {});
            },
            text: '업로드',
            options: FFButtonOptions(
              width: double.infinity,
              height: 60.0,
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).secondaryBackground,
              textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                    ),
                    color: Color(0xFF14181B),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
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
        ),
      ],
    );
  }
}
