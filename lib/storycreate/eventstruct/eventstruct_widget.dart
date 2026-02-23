import '/backend/schema/structs/index.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'eventstruct_model.dart';
export 'eventstruct_model.dart';

class EventstructWidget extends StatefulWidget {
  const EventstructWidget({
    super.key,
    this.eventTags,
    this.item,
  });

  final List<String>? eventTags;
  final EventStructStruct? item;

  @override
  State<EventstructWidget> createState() => _EventstructWidgetState();
}

class _EventstructWidgetState extends State<EventstructWidget> {
  late EventstructModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EventstructModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      height: 200.0,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              valueOrDefault<String>(
                functions.stringToImagePath(widget.item?.imageurl),
                '\' \'',
              ),
              width: 150.0,
              height: 150.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
            child: FlutterFlowDropDown<String>(
              controller: _model.eventtagDropDownValueController ??=
                  FormFieldController<String>(
                _model.eventtagDropDownValue ??= widget.item?.event,
              ),
              options: widget.eventTags ?? const [],
              onChanged: (val) async {
                safeSetState(() => _model.eventtagDropDownValue = val);
                FFAppState().events = functions
                    .updateEventTagByUrl(
                      FFAppState().events.toList(),
                      widget.item!.imageurl,
                      val ?? '',
                    )
                    .toList()
                    .cast<EventStructStruct>();
                safeSetState(() {});
              },
              width: 150.0,
              height: 30.0,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).alternate,
                    fontSize: 15.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
              hintText: '이벤트 선택',
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: FlutterFlowTheme.of(context).primaryBackground,
                size: 25.0,
              ),
              elevation: 2.0,
              borderColor: Colors.transparent,
              borderWidth: 0.0,
              borderRadius: 0.0,
              margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              hidesUnderline: true,
              isOverButton: false,
              isSearchable: false,
              isMultiSelect: false,
            ),
          ),
        ],
      ),
    );
  }
}
