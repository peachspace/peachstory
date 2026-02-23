import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'placestruct_model.dart';
export 'placestruct_model.dart';

class PlacestructWidget extends StatefulWidget {
  const PlacestructWidget({
    super.key,
    this.placeTags,
    this.item,
  });

  final List<String>? placeTags;
  final PlaceStructStruct? item;

  @override
  State<PlacestructWidget> createState() => _PlacestructWidgetState();
}

class _PlacestructWidgetState extends State<PlacestructWidget> {
  late PlacestructModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PlacestructModel());

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
<<<<<<< HEAD
            child: safeNetworkImage(
              imageUrl: functions.stringToImagePath(widget.item?.imageUrl),
              width: 80.0,
              height: 80.0,
=======
            child: Image.network(
              valueOrDefault<String>(
                functions.stringToImagePath(widget.item?.imageUrl),
                '\' \'',
              ),
              width: 150.0,
              height: 150.0,
>>>>>>> origin/flutterflow
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
            child: FlutterFlowDropDown<String>(
              controller: _model.placetagDropDownValueController ??=
                  FormFieldController<String>(
                _model.placetagDropDownValue ??= widget.item?.place,
              ),
              options: widget.placeTags!,
              onChanged: (val) async {
                safeSetState(() => _model.placetagDropDownValue = val);
                FFAppState().places = functions
                    .updatePlaceTagByImageUrl(FFAppState().places.toList(),
                        widget.item!.imageUrl, _model.placetagDropDownValue!)
                    .toList()
                    .cast<PlaceStructStruct>();
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
              hintText: '장소 선택',
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
