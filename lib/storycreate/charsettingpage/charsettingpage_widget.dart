import '/backend/firebase_storage/storage.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'charsettingpage_model.dart';
export 'charsettingpage_model.dart';

class CharsettingpageWidget extends StatefulWidget {
  const CharsettingpageWidget({
    super.key,
    bool? isEdit,
    int? editIndex,
    this.storyContext,
    this.placeTags,
    this.initialCharName,
    this.initialCharSetting,
    this.initialCharAbility,
    this.initialCharIntroduce,
  })  : this.isEdit = isEdit ?? false,
        this.editIndex = editIndex ?? 0;

  final bool isEdit;
  final int editIndex;
  final String? storyContext;
  final List<String>? placeTags;
  final String? initialCharName;
  final String? initialCharSetting;
  final String? initialCharAbility;
  final String? initialCharIntroduce;

  static String routeName = 'charsettingpage';
  static String routePath = '/charsettingpage';

  @override
  State<CharsettingpageWidget> createState() => _CharsettingpageWidgetState();
}

class _CharsettingpageWidgetState extends State<CharsettingpageWidget>
    with TickerProviderStateMixin {
  late CharsettingpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAiGenerating = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CharsettingpageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final defaultChar = CharacterStructStruct(
        name: '',
        setting: '',
        introduce: '',
        seed: 0,
        profileimage: '',
        emotionStruct: functions.getEmptyEmotionList(),
        basePrompt: '',
        abilityStruct: functions.getEmptyabilityList(),
        appearance: '',
        ability: '',
      );
      if (widget.isEdit == true) {
        _model.editchar =
            FFAppState().Characters.elementAtOrNull(widget.editIndex) ??
                defaultChar;
      } else {
        _model.editchar = CharacterStructStruct(
          name: (widget.initialCharName ?? '').trim(),
          setting: (widget.initialCharSetting ?? '').trim(),
          introduce: (widget.initialCharIntroduce ?? '').trim(),
          seed: 0,
          profileimage: '',
          emotionStruct: functions.getEmptyEmotionList(),
          basePrompt: '',
          abilityStruct: functions.getEmptyabilityList(),
          appearance: '',
          ability: (widget.initialCharAbility ?? '').trim(),
        );
      }

      _model.charNameTextController?.text = _model.editchar?.name ?? '';
      _model.charSettingTextController?.text = _model.editchar?.setting ?? '';
      _model.charabilityTextController?.text = _model.editchar?.ability ?? '';
      _model.charintroduceTextController?.text =
          _model.editchar?.introduce ?? '';
      FFAppState().emotions =
          (_model.editchar?.emotionStruct ?? functions.getEmptyEmotionList())
              .toList()
              .cast<EmotionStructStruct>();
      FFAppState().Abilities =
          (_model.editchar?.abilityStruct ?? functions.getEmptyabilityList())
              .toList()
              .cast<AbilityStructStruct>();
      safeSetState(() {});
    });

    _model.charNameTextController ??= TextEditingController();
    _model.charNameFocusNode ??= FocusNode();

    _model.charSettingTextController ??= TextEditingController();
    _model.charSettingFocusNode ??= FocusNode();

    _model.charabilityTextController ??= TextEditingController();
    _model.charabilityFocusNode ??= FocusNode();

    _model.charintroduceTextController ??= TextEditingController();
    _model.charintroduceFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
        duration: const Duration(milliseconds: 2200),
        backgroundColor: FlutterFlowTheme.of(context).info,
      ),
    );
  }

  OutlineInputBorder _inputBorder() => OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(5.0),
      );

  Widget _buildSparkleLoadingOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: const Color(0x99000000),
          alignment: Alignment.center,
          child: Icon(
            Icons.auto_awesome,
            color: FlutterFlowTheme.of(context).primary,
            size: 110.0,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .fade(
                duration: 700.ms,
                begin: 0.35,
                end: 1.0,
              )
              .scaleXY(
                duration: 700.ms,
                begin: 0.9,
                end: 1.08,
              ),
        ),
      ),
    );
  }

  String _normalizeCharSettingTemplate(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').split('\n');
    String pick(String key) {
      final lowerKey = key.toLowerCase();
      for (final line in lines) {
        final trimmed = line.trim();
        final normalized =
            trimmed.startsWith('- ') ? trimmed.substring(2).trim() : trimmed;
        if (!normalized.contains(':')) continue;
        final name = normalized.split(':').first.trim().toLowerCase();
        if (name == lowerKey) {
          return normalized.substring(normalized.indexOf(':') + 1).trim();
        }
      }
      return '';
    }

    final rows = <String>[
      '나이: ${pick('나이')}',
      '성별: ${pick('성별')}',
      '성격: ${pick('성격')}',
      '말투: ${pick('말투')}',
      '- 예시대사 3개: ${pick('예시대사 3개')}',
      '습관: ${pick('습관')}',
      '역할: ${pick('역할')}',
      '관계: ${pick('관계')}',
      '목표: ${pick('목표')}',
      '약점: ${pick('약점')}',
      '금기: ${pick('금기')}',
      '비밀: ${pick('비밀')}',
    ];
    return rows.join('\n').trim();
  }

  String _normalizeAbilityLines(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').split('\n');
    final out = <String>[];
    final usedNames = <String>{};

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      line = line.replaceAll(RegExp(r'^[-*•\d\.\)\(]+\s*'), '').trim();
      if (!line.contains(':')) continue;

      final name = line.split(':').first.trim();
      final desc = line.substring(line.indexOf(':') + 1).trim();
      if (name.isEmpty || desc.isEmpty) continue;
      if (usedNames.add(name)) out.add('$name: $desc');
    }

    return out.isEmpty ? raw.trim() : out.join('\n').trim();
  }

  Map<String, String>? _parseCharAiOutput(String raw) {
    String cleaned = raw.trim();
    cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '').trim();

    dynamic parsed;
    try {
      parsed = jsonDecode(cleaned);
    } catch (_) {
      parsed = null;
    }

    String pick(dynamic value) => (value ?? '').toString().trim();

    String charName = '';
    String charSetting = '';
    String charAbility = '';
    String charIntroduce = '';

    if (parsed is Map) {
      charName =
          pick(parsed['charName'] ?? parsed['name'] ?? parsed['char_name']);
      charSetting = pick(
        parsed['charSetting'] ??
            parsed['setting'] ??
            parsed['characterSetting'],
      );
      final abilityValue =
          parsed['charability'] ?? parsed['ability'] ?? parsed['abilities'];
      if (abilityValue is List) {
        charAbility = abilityValue.map((e) => e.toString()).join('\n').trim();
      } else {
        charAbility = pick(abilityValue);
      }
      charIntroduce = pick(
        parsed['charintroduce'] ??
            parsed['introduce'] ??
            parsed['introduction'],
      );
    } else {
      final nameMatch = RegExp(
        r'(?:charName|name|이름)\s*[:：]\s*(.+)',
        multiLine: true,
      ).firstMatch(cleaned);
      final settingMatch = RegExp(
        r'(?:charSetting|setting|설정)\s*[:：]\s*([\s\S]*?)(?=\n(?:charability|ability|능력|charintroduce|introduce|소개)\s*[:：]|$)',
        multiLine: true,
      ).firstMatch(cleaned);
      final abilityMatch = RegExp(
        r'(?:charability|ability|능력)\s*[:：]\s*([\s\S]*?)(?=\n(?:charintroduce|introduce|소개)\s*[:：]|$)',
        multiLine: true,
      ).firstMatch(cleaned);
      final introduceMatch = RegExp(
        r'(?:charintroduce|introduce|소개)\s*[:：]\s*([\s\S]+)$',
        multiLine: true,
      ).firstMatch(cleaned);

      charName = (nameMatch?.group(1) ?? '').trim();
      charSetting = (settingMatch?.group(1) ?? '').trim();
      charAbility = (abilityMatch?.group(1) ?? '').trim();
      charIntroduce = (introduceMatch?.group(1) ?? '').trim();
    }

    charAbility = _normalizeAbilityLines(charAbility);
    if (charName.isEmpty ||
        charSetting.isEmpty ||
        charAbility.isEmpty ||
        charIntroduce.isEmpty) {
      return null;
    }

    return {
      'charName': charName,
      'charSetting': charSetting,
      'charability': charAbility,
      'charintroduce': charIntroduce,
    };
  }

  Future<void> _runCharAiGeneration(String userInstruction) async {
    if (_isAiGenerating) return;
    safeSetState(() => _isAiGenerating = true);

    try {
      final contextBlock = '''
[스토리 컨텍스트]
${widget.storyContext ?? ''}
[기존 캐릭터]
${functions.convertCharactersToString(FFAppState().Characters.toList())}
[현재 입력값]
이름: ${_model.charNameTextController.text}
설정: ${_model.charSettingTextController.text}
능력:
${_model.charabilityTextController.text}
소개: ${_model.charintroduceTextController.text}
''';

      final systemPrompt = '''
너는 웹소설 캐릭터 생성 assistant다.
출력은 반드시 JSON 객체 1개만 출력한다. 코드블록, 설명, 마크다운 금지.
JSON 스키마:
{
  "charName": "캐릭터 이름",
  "charSetting": "캐릭터 설정(여러 문단 가능)",
  "charability": "능력명: 설명\\n능력명: 설명\\n...",
  "charintroduce": "캐릭터 소개문"
}
규칙:
- charSetting은 반드시 아래 형식을 유지한다.
나이:
성별:
성격:
말투:
- 예시대사 3개:
습관:
역할:
관계:
목표:
약점:
금기:
비밀:
- charability는 각 줄이 "능력명: 설명" 형식을 따른다.
- 한국어로 작성.
- 4개 필드는 모두 비우지 마라.
''';

      final userPrompt = '''
$contextBlock

[사용자 지시]
${userInstruction.trim().isEmpty ? '기존 세계관과 어울리는 캐릭터를 자연스럽게 생성해줘.' : userInstruction.trim()}
''';

      final raw = await actions.callAiProxy(
        'gpt-4o-mini',
        systemPrompt,
        const [],
        userPrompt,
      );
      if (raw == null || raw.trim().isEmpty || raw.startsWith('ERROR:')) {
        throw Exception(raw ?? 'AI 응답이 비어 있습니다.');
      }

      final parsed = _parseCharAiOutput(raw);
      if (parsed == null) throw Exception('AI 응답 파싱 실패');

      _model.charNameTextController.text = parsed['charName']!;
      _model.charSettingTextController.text =
          _normalizeCharSettingTemplate(parsed['charSetting']!);
      _model.charabilityTextController.text = parsed['charability']!;
      _model.charintroduceTextController.text = parsed['charintroduce']!;
      safeSetState(() {});
    } catch (_) {
      _showMessage('캐릭터 AI 생성에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (!mounted) return;
      safeSetState(() => _isAiGenerating = false);
    }
  }

  Future<void> _openCharAiSheet() async {
    if (_isAiGenerating) return;
    final promptController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        final insetBottom = media.viewInsets.bottom;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              20.0,
              0.0,
              20.0,
              insetBottom + 20.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    10.0, 10.0, 10.0, 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        12.0, 12.0, 12.0, 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '프롬프트 입력하기',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                final userInstruction = promptController.text;
                                Navigator.pop(sheetContext);
                                await _runCharAiGeneration(userInstruction);
                              },
                              child: Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: promptController,
                          autofocus: true,
                          minLines: 8,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText:
                                '캐릭터의 이름, 설정, 소개 등을 자동으로 생성하기 위해 지시할 프롬프트를 입력해주세요.',
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: const Color(0xFF5D6A77),
                                  letterSpacing: 0.0,
                                ),
                            filled: true,
                            fillColor: const Color(0xFFE8EBEF),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            errorBorder: _inputBorder(),
                            focusedErrorBorder: _inputBorder(),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    12.0, 12.0, 12.0, 12.0),
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadProfileImage() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia == null ||
        selectedMedia.isEmpty ||
        !selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }

    final first = selectedMedia.first;
    final url = await uploadData(first.storagePath, first.bytes);
    if (url == null || url.isEmpty) {
      _showMessage('이미지 업로드에 실패했습니다.');
      return;
    }

    _model.updateEditcharStruct((e) => e.profileimage = url);
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryText,
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.safePop();
            },
            child: Icon(
              Icons.keyboard_arrow_left,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 24.0,
            ),
          ),
          title: Text(
            '캐릭터 생성하기',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              25.0, 0.0, 25.0, 0.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 30.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 20.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  -1.0, 0.0),
                                              child: Text(
                                                '프로필 이미지',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await _uploadProfileImage();
                                          },
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            children: [
                                              if (valueOrDefault<bool>(
                                                _model.editchar?.profileimage ==
                                                        null ||
                                                    _model.editchar
                                                            ?.profileimage ==
                                                        '',
                                                false,
                                              ))
                                                Container(
                                                  width: 200.0,
                                                  height: 200.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    30.0,
                                                                    0.0,
                                                                    10.0),
                                                        child: Icon(
                                                          Icons.upload,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 30.0,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Text(
                                                          '캐릭터의 프로필로 사용될 \n이미지를 업로드해주세요.',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (_model.editchar
                                                          ?.profileimage !=
                                                      null &&
                                                  _model.editchar
                                                          ?.profileimage !=
                                                      '')
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: safeNetworkImage(
                                                    imageUrl: functions
                                                        .stringToImagePath(
                                                      valueOrDefault<String>(
                                                        _model.editchar
                                                            ?.profileimage,
                                                        '\' \'',
                                                      ),
                                                    ),
                                                    width: 200.0,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 30.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Text(
                                            '이름',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.charNameTextController,
                                          focusNode: _model.charNameFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.charNameTextController',
                                            Duration(milliseconds: 2000),
                                            () async {
                                              safeSetState(() {});
                                            },
                                          ),
                                          autofocus: false,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: '캐릭터의 이름을 입력하세요.',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      letterSpacing: 0.0,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            filled: true,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 15.0, 10.0, 15.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          maxLines: null,
                                          minLines: 1,
                                          maxLength: 20,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              null,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          validator: _model
                                              .charNameTextControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 30.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Text(
                                            '설정',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.charSettingTextController,
                                          focusNode:
                                              _model.charSettingFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.charSettingTextController',
                                            Duration(milliseconds: 2000),
                                            () async {
                                              safeSetState(() {});
                                            },
                                          ),
                                          autofocus: false,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText:
                                                '캐릭터에 관한 정보를 입력하세요.\n\n[작성예시]\n\n나이: \n성별: \n성격: \n말투: \n- 예시대사 3개:\n습관: \n역할:\n관계: \n목표:\n약점:\n금기:\n비밀: ',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      letterSpacing: 0.0,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            filled: true,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 15.0, 10.0, 15.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          maxLines: null,
                                          minLines: 17,
                                          maxLength: 3000,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              null,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          validator: _model
                                              .charSettingTextControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 30.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Text(
                                            '능력',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller:
                                              _model.charabilityTextController,
                                          focusNode:
                                              _model.charabilityFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.charabilityTextController',
                                            Duration(milliseconds: 2000),
                                            () async {
                                              safeSetState(() {});
                                            },
                                          ),
                                          autofocus: false,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText:
                                                '- 캐릭터의 능력을 입력하세요.\n- 반드시 \"능력: 설명\"의 형식으로 입력하세요.\n\n[입력예시]\n\n파이어볼: 세린의 주요공격방법\n독심술: 지안이 상대의 마음을 읽어 내는 능력',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      letterSpacing: 0.0,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            filled: true,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 15.0, 10.0, 15.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          maxLines: null,
                                          minLines: 5,
                                          maxLength: 4000,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              null,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          validator: _model
                                              .charabilityTextControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 30.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Text(
                                            '소개',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: _model
                                              .charintroduceTextController,
                                          focusNode:
                                              _model.charintroduceFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.charintroduceTextController',
                                            Duration(milliseconds: 2000),
                                            () async {
                                              safeSetState(() {});
                                            },
                                          ),
                                          autofocus: false,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: '캐릭터에 대해  소개해주세요.',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      letterSpacing: 0.0,
                                                    ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            filled: true,
                                            contentPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 15.0, 10.0, 15.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          maxLines: null,
                                          minLines: 2,
                                          maxLength: 200,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              null,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          validator: _model
                                              .charintroduceTextControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 30.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Text(
                                              '감정 이미지',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    fontSize: 18.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (_model
                                                  .charabilityTextController
                                                  .text
                                                  .trim()
                                                  .isEmpty) {
                                                _showMessage(
                                                    '캐릭터능력을 먼저 입력해주세요.');
                                                return;
                                              }
                                              FFAppState().emotions = _model
                                                  .editchar!.emotionStruct
                                                  .toList()
                                                  .cast<EmotionStructStruct>();
                                              safeSetState(() {});
                                              context.pushNamed(
                                                EmotionimagelistWidget
                                                    .routeName,
                                              );
                                            },
                                            child: Icon(
                                              Icons.keyboard_arrow_right,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 30.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 10.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 70.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  -1.0, 0.0),
                                              child: Text(
                                                '능력 이미지',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (_model
                                                    .charabilityTextController
                                                    .text
                                                    .trim()
                                                    .isEmpty) {
                                                  _showMessage(
                                                      '캐릭터능력을 먼저 입력해주세요.');
                                                  return;
                                                }
                                                FFAppState().Abilities = _model
                                                    .editchar!.abilityStruct
                                                    .toList()
                                                    .cast<
                                                        AbilityStructStruct>();
                                                safeSetState(() {});
                                                context.pushNamed(
                                                  AbilityimagelistWidget
                                                      .routeName,
                                                  queryParameters: {
                                                    'abilityTags':
                                                        serializeParam(
                                                      functions
                                                          .extractTagsFromColonLines(
                                                              _model
                                                                  .charabilityTextController
                                                                  .text),
                                                      ParamType.String,
                                                      isList: true,
                                                    ),
                                                  }.withoutNulls,
                                                );
                                              },
                                              child: Icon(
                                                Icons.keyboard_arrow_right,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                size: 30.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(1.0, 1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 25.0, 25.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                await _openCharAiSheet();
                              },
                              child: Icon(
                                Icons.auto_fix_high,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(25.0, 0.0, 25.0, 0.0),
                      child: SafeArea(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF8F9),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: FFButtonWidget(
                            onPressed: () async {
                              final currentEmotionList =
                                  FFAppState().emotions.isNotEmpty
                                      ? FFAppState()
                                          .emotions
                                          .toList()
                                          .cast<EmotionStructStruct>()
                                      : (_model.editchar?.emotionStruct ??
                                              functions.getEmptyEmotionList())
                                          .toList()
                                          .cast<EmotionStructStruct>();
                              final currentAbilityStructList =
                                  FFAppState().Abilities.isNotEmpty
                                      ? FFAppState()
                                          .Abilities
                                          .toList()
                                          .cast<AbilityStructStruct>()
                                      : (_model.editchar?.abilityStruct ??
                                              functions.getEmptyabilityList())
                                          .toList()
                                          .cast<AbilityStructStruct>();

                              final savedCharacter = CharacterStructStruct(
                                name: _model.charNameTextController.text.trim(),
                                setting: _model.charSettingTextController.text
                                    .trim(),
                                introduce: _model
                                    .charintroduceTextController.text
                                    .trim(),
                                seed: _model.editchar?.seed ?? 0,
                                profileimage:
                                    _model.editchar?.profileimage ?? '',
                                emotionStruct: currentEmotionList,
                                basePrompt: _model.editchar?.basePrompt ?? '',
                                abilityStruct: currentAbilityStructList,
                                appearance: _model.editchar?.appearance ?? '',
                                ability: _model.charabilityTextController.text
                                    .trim(),
                              );

                              FFAppState().update(() {
                                final canEdit = widget.isEdit &&
                                    widget.editIndex >= 0 &&
                                    widget.editIndex <
                                        FFAppState().Characters.length;
                                if (canEdit) {
                                  FFAppState().updateCharactersAtIndex(
                                    widget.editIndex,
                                    (_) => savedCharacter,
                                  );
                                } else {
                                  FFAppState().addToCharacters(savedCharacter);
                                }
                              });

                              FFAppState().Abilities = functions
                                  .getEmptyabilityList()
                                  .toList()
                                  .cast<AbilityStructStruct>();
                              FFAppState().emotions = functions
                                  .getEmptyEmotionList()
                                  .toList()
                                  .cast<EmotionStructStruct>();
                              safeSetState(() {});
                              context.safePop();
                            },
                            text: '저장하기',
                            options: FFButtonOptions(
                              height: 50.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isAiGenerating) _buildSparkleLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
