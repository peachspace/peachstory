import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'abilitystruct_model.dart';
export 'abilitystruct_model.dart';

class AbilitystructWidget extends StatefulWidget {
  const AbilitystructWidget({
    super.key,
    this.abilityTags,
    this.item,
  });

  final List<String>? abilityTags;
  final AbilityStructStruct? item;

  @override
  State<AbilitystructWidget> createState() => _AbilitystructWidgetState();
}

class _AbilitystructWidgetState extends State<AbilitystructWidget> {
  late AbilitystructModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AbilitystructModel());

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
      height: 110.0,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              valueOrDefault<String>(
                functions.stringToImagePath(widget.item?.imageUrl),
                '\' \'',
              ),
              width: 80.0,
              height: 80.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
            child: FlutterFlowDropDown<String>(
              controller: _model.abilitytagDropDownValueController ??=
                  FormFieldController<String>(
                _model.abilitytagDropDownValue ??= widget.item?.ability,
              ),
              options: widget.abilityTags!,
              onChanged: (val) async {
                safeSetState(() => _model.abilitytagDropDownValue = val);
                FFAppState().Abilities = functions
                    .updateAbilityTagByPlaceAndUrl(
                        FFAppState().Abilities.toList(),
                        widget.item!.place,
                        widget.item!.imageUrl,
                        _model.abilitytagDropDownValue!)
                    .toList()
                    .cast<AbilityStructStruct>();
                safeSetState(() {});
              },
              width: 80.0,
              height: 20.0,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
              hintText: '능력 선택',
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 20.0,
              ),
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
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
