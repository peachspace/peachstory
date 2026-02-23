import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/home/loginpage/loginpage_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'visualnovelpage_model.dart';
export 'visualnovelpage_model.dart';

class _AiModelOption {
  const _AiModelOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

class _VisualParagraph {
  const _VisualParagraph({
    required this.text,
    required this.speaker,
    required this.isNarration,
    required this.place,
    required this.backgroundUrl,
    required this.characterUrl,
  });

  final String text;
  final String speaker;
  final bool isNarration;
  final String place;
  final String? backgroundUrl;
  final String? characterUrl;
}

class VisualnovelpageWidget extends StatefulWidget {
  const VisualnovelpageWidget({
    super.key,
    this.storyRef,
    this.storychatRef,
    required this.userInChatName,
  });

  final DocumentReference? storyRef;
  final DocumentReference? storychatRef;
  final String? userInChatName;

  static String routeName = 'visualnovelpage';
  static String routePath = '/visualnovelpage';

  @override
  State<VisualnovelpageWidget> createState() => _VisualnovelpageWidgetState();
}

class _VisualnovelpageWidgetState extends State<VisualnovelpageWidget> {
  static const String _defaultAiModelId = 'claude-3-haiku-20240307';
  static const List<_AiModelOption> _aiModelOptions = [
    _AiModelOption(
      id: 'claude-3-haiku-20240307',
      label: 'Claude Haiku 4.5',
    ),
    _AiModelOption(
      id: 'gpt-4o',
      label: 'GPT-4o',
    ),
    _AiModelOption(
      id: 'gemini-2.5-pro',
      label: 'Gemini 2.5 Pro',
    ),
    _AiModelOption(
      id: 'gemini-2.5-flash',
      label: 'Gemini 2.5 Flash',
    ),
  ];

  late VisualnovelpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isInitializing = true;
  bool _isGenerating = false;
  bool _isChatMode = false;
  bool _didBackfillDefaultModel = false;

  String _currentPlace = '어딘가';
  String? _currentBackgroundImageUrl;
  String? _currentCharacterImageUrl;

  List<_VisualParagraph> _paragraphs = const [];
  int _currentParagraphIndex = 0;
  bool _showActionPanel = false;

  final List<String> _defaultChoices = const [
    '상황을 지켜본다',
    '질문을 던진다',
    '다른 행동을 시도한다',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VisualnovelpageModel());

    _model.usertextFieldTextController ??= TextEditingController();
    _model.usertextFieldFocusNode ??= FocusNode();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _initializeVisualNovel();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _isValidNetworkImageUrl(String? url) {
    final value = functions.stringToImagePath(url).trim();
    return value.startsWith('http://') || value.startsWith('https://');
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

  Future<void> _showLoginSheet() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: LoginpageWidget(),
          ),
        );
      },
    ).then((value) => safeSetState(() {}));
  }

  String _resolveSelectedModelId(String? rawModelId) {
    final value = (rawModelId ?? '').trim();
    if (value.isEmpty) return _defaultAiModelId;
    return value;
  }

  String _resolveSelectedModelLabel(String? rawModelId) {
    final modelId = _resolveSelectedModelId(rawModelId);
    for (final option in _aiModelOptions) {
      if (option.id == modelId) {
        return option.label;
      }
    }
    if (modelId == _defaultAiModelId) {
      return 'Claude Haiku 4.5';
    }
    return modelId;
  }

  Future<void> _updateSelectedModel(
    StorychatsRecord chatDoc,
    String modelId,
  ) async {
    await chatDoc.reference.update(
      createStorychatsRecordData(
        selectedAiModel: modelId,
      ),
    );
  }

  Future<void> _updateUserNote(
    StorychatsRecord chatDoc,
    String note,
  ) async {
    await chatDoc.reference.update(
      createStorychatsRecordData(
        userNote: note,
      ),
    );
  }

  Future<void> _openSettingsSheet(StorychatsRecord chatDoc) async {
    final noteController = TextEditingController(text: chatDoc.userNote);
    var selectedModelId = _resolveSelectedModelId(chatDoc.selectedAiModel);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Container(
                  height: 420.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            16.0,
                            12.0,
                            16.0,
                            0.0,
                          ),
                          child: Container(
                            width: 42.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).alternate,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        ),
                        TabBar(
                          labelColor: FlutterFlowTheme.of(context).primary,
                          unselectedLabelColor:
                              FlutterFlowTheme.of(context).alternate,
                          indicatorColor: FlutterFlowTheme.of(context).primary,
                          tabs: const [
                            Tab(text: '모델선택'),
                            Tab(text: '유저노트'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ListView.builder(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  20.0,
                                  16.0,
                                  20.0,
                                  16.0,
                                ),
                                itemCount: _aiModelOptions.length,
                                itemBuilder: (context, index) {
                                  final option = _aiModelOptions[index];
                                  final isSelected =
                                      selectedModelId == option.id;
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      setSheetState(() {
                                        selectedModelId = option.id;
                                      });
                                      await _updateSelectedModel(
                                        chatDoc,
                                        option.id,
                                      );
                                      if (mounted) {
                                        safeSetState(() {});
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                        0.0,
                                        8.0,
                                        0.0,
                                        8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.circle_outlined,
                                            color: isSelected
                                                ? Colors.red
                                                : FlutterFlowTheme.of(context)
                                                    .alternate,
                                            size: 20.0,
                                          ),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: Text(
                                              option.label,
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    color: isSelected
                                                        ? Colors.red
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primaryBackground,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0,
                                  16.0,
                                  16.0,
                                  16.0,
                                ),
                                child: TextFormField(
                                  controller: noteController,
                                  autofocus: false,
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        letterSpacing: 0.0,
                                      ),
                                  decoration: InputDecoration(
                                    hintText: 'AI가 계속 기억해야 할 설정을 입력하세요.',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FlutterFlowTheme.of(
                                                    context)
                                                .labelMedium
                                                .fontWeight,
                                            fontStyle: FlutterFlowTheme.of(
                                                    context)
                                                .labelMedium
                                                .fontStyle,
                                          ),
                                          color:
                                              FlutterFlowTheme.of(context).alternate,
                                          letterSpacing: 0.0,
                                        ),
                                    filled: true,
                                    fillColor: const Color(0x22000000),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).alternate,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).alternate,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                  minLines: 6,
                                  maxLines: 10,
                                  onChanged: (value) async {
                                    await _updateUserNote(chatDoc, value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    await _updateUserNote(chatDoc, noteController.text);
    noteController.dispose();
  }

  Future<void> _initializeVisualNovel() async {
    if (widget.storyRef == null || widget.storychatRef == null) {
      if (!mounted) return;
      safeSetState(() {
        _isInitializing = false;
      });
      return;
    }

    try {
      final story = await StoriesRecord.getDocumentOnce(widget.storyRef!);
      _model.loadedStory = story;

      _model.messagesAsJson = await actions.getRecentHistoryAsJson(
        widget.storychatRef!,
        30,
      );
      _model.chatMessages = functions
          .mapJsonToStoryChatStructs(_model.messagesAsJson!.toList())
          .toList()
          .cast<StoryChatMessageStructStruct>();

      if (_model.chatMessages.isEmpty) {
        _model.pageloadformat = await actions.formatStoryTurnHeaderAndBg(
          functions.prologueTextToTagScript(
            story.prologuetext,
            story.characters.toList(),
            story.places.toList(),
          ),
          _model.chatMessages.toList(),
          story.places.toList(),
          story.characters.toList(),
          widget.userInChatName,
          true,
        );

        final initialScript = _model.pageloadformat ?? '';
        final scenes = _parseScriptIntoScenes(initialScript);
        if (scenes.isNotEmpty) {
          final savedMessages = await actions.processAndSaveChatTurn(
            scenes,
            widget.storychatRef!,
            story.places.toList(),
            story.characters.toList(),
            story.events.toList(),
          );

          _model.chatMessages = functions
              .mergeChatLists(_model.chatMessages.toList(), savedMessages.toList())
              .toList()
              .cast<StoryChatMessageStructStruct>();

          await widget.storychatRef!.update({
            ...mapToFirestore(
              {
                'messageCount': FieldValue.increment(1),
              },
            ),
          });
        }

        _applyScenesToVisualTurn(scenes, story);
      } else {
        _restoreLatestTurnFromSavedMessages(story);
      }
    } catch (_) {
      _showMessage('스토리를 불러오지 못했습니다.');
    } finally {
      if (!mounted) return;
      safeSetState(() {
        _isInitializing = false;
      });
    }
  }

  Map<String, String> _buildPlaceImageMap(StoriesRecord story) {
    final map = <String, String>{};
    for (final place in story.places) {
      final tag = (place.place).toString().trim();
      final url = functions.stringToImagePath((place.imageUrl).toString()).trim();
      if (tag.isNotEmpty && url.isNotEmpty) {
        map.putIfAbsent(tag, () => url);
      }
    }
    return map;
  }

  Map<String, String> _buildEventImageMap(StoriesRecord story) {
    final map = <String, String>{};
    for (final event in story.events) {
      final tag = (event.event).toString().trim();
      final url = functions.stringToImagePath((event.imageurl).toString()).trim();
      if (tag.isNotEmpty && url.isNotEmpty) {
        map.putIfAbsent(tag, () => url);
      }
    }
    return map;
  }

  Map<String, String> _buildAbilityEmotionImageMap(StoriesRecord story) {
    final map = <String, String>{};

    void addTag(String rawTag, String rawUrl) {
      final tag = rawTag.trim();
      final url = functions.stringToImagePath(rawUrl).trim();
      if (tag.isNotEmpty && url.isNotEmpty) {
        map.putIfAbsent(tag, () => url);
      }
    }

    for (final character in story.characters) {
      for (final ability in (character.abilityStruct)) {
        addTag((ability.ability).toString(), (ability.imageUrl).toString());
      }
      for (final emotion in (character.emotionStruct)) {
        addTag((emotion.emotion).toString(), (emotion.imageurl).toString());
      }
    }

    return map;
  }

  String _normalizeImageTag(String raw) {
    final value = raw.trim();
    if (value.contains('__')) {
      final parts = value.split('__');
      return parts.last.trim();
    }
    return value;
  }

  String? _extractPlaceFromHeader(String headerText) {
    final match = RegExp(r'\|\s*(.*?)\s*\]$').firstMatch(headerText.trim());
    final place = (match?.group(1) ?? '').trim();
    if (place.isEmpty) return null;
    return place;
  }

  String? _findPlaceByImageUrl(Map<String, String> placeMap, String imageUrl) {
    for (final entry in placeMap.entries) {
      if (entry.value == imageUrl) return entry.key;
    }
    return null;
  }

  String? _resolveDefaultCharacterImage(StoriesRecord story, String speaker) {
    final speakerName = speaker.trim();
    if (speakerName.isEmpty) return null;

    CharacterStructStruct? character;
    for (final item in story.characters) {
      if ((item.name).toString().trim() == speakerName) {
        character = item;
        break;
      }
    }

    if (character == null) return null;

    String? emotionUrl;
    for (final emotion in character.emotionStruct) {
      if ((emotion.emotion).toString().trim() == '무감정') {
        final url = functions.stringToImagePath((emotion.imageurl).toString()).trim();
        if (url.isNotEmpty) {
          emotionUrl = url;
          break;
        }
      }
    }

    if (emotionUrl != null && emotionUrl.isNotEmpty) return emotionUrl;

    for (final emotion in character.emotionStruct) {
      final url = functions.stringToImagePath((emotion.imageurl).toString()).trim();
      if (url.isNotEmpty) return url;
    }

    final profile = functions.stringToImagePath((character.profileimage).toString()).trim();
    if (profile.isNotEmpty) return profile;

    return null;
  }

  List<Map<String, dynamic>> _parseScriptIntoScenes(String scriptText) {
    final scenes = <Map<String, dynamic>>[];

    final exp = RegExp(
      r'(\[TURN_HEADER\](.*?)\[/TURN_HEADER\])'
      r'|(\[SHOW_IMAGE="(.*?)"\])'
      r'|(\[NARRATION\](.*?)\[/NARRATION\])'
      r'|(\[DIALOGUE SPEAKER="(.*?)"(?: ACTION="(.*?)")?\](.*?)\[/DIALOGUE\])',
      dotAll: true,
      multiLine: true,
    );

    final matches = exp.allMatches(scriptText);
    if (matches.isNotEmpty) {
      for (final m in matches) {
        if (m.group(1) != null) {
          scenes.add({
            'type': 'turn_header',
            'content': (m.group(2) ?? '').trim(),
          });
          continue;
        }

        if (m.group(3) != null) {
          scenes.add({
            'type': 'show_image',
            'condition': (m.group(4) ?? '').trim(),
          });
          continue;
        }

        if (m.group(5) != null) {
          scenes.add({
            'type': 'narration',
            'content': (m.group(6) ?? '').trim(),
          });
          continue;
        }

        if (m.group(7) != null) {
          scenes.add({
            'type': 'dialogue',
            'speaker': (m.group(8) ?? '').trim(),
            'action': (m.group(9) ?? '').trim(),
            'content': (m.group(10) ?? '').trim(),
          });
          continue;
        }
      }
    }

    if (scenes.isEmpty && scriptText.trim().isNotEmpty) {
      scenes.add(
        {
          'type': 'narration',
          'content': scriptText.trim(),
        },
      );
    }

    return scenes;
  }

  void _applyScenesToVisualTurn(
    List<Map<String, dynamic>> scenes,
    StoriesRecord story,
  ) {
    final placeMap = _buildPlaceImageMap(story);
    final eventMap = _buildEventImageMap(story);
    final comboMap = _buildAbilityEmotionImageMap(story);

    var workingPlace = _currentPlace;
    var workingBackground = _currentBackgroundImageUrl;
    String? workingCharacter = _currentCharacterImageUrl;

    final paragraphs = <_VisualParagraph>[];

    for (final scene in scenes) {
      final type = (scene['type'] ?? '').toString().trim();

      if (type == 'turn_header') {
        final headerText = (scene['content'] ?? '').toString();
        final placeFromHeader = _extractPlaceFromHeader(headerText);
        if (placeFromHeader != null && placeFromHeader.isNotEmpty) {
          final placeChanged = placeFromHeader != workingPlace;
          workingPlace = placeFromHeader;

          if (placeChanged) {
            workingCharacter = null;
            workingBackground = placeMap[placeFromHeader];
          } else {
            workingBackground ??= placeMap[placeFromHeader];
          }
        }
        continue;
      }

      if (type == 'show_image') {
        final condition = _normalizeImageTag((scene['condition'] ?? '').toString());
        if (condition.isEmpty) continue;

        if (placeMap.containsKey(condition)) {
          workingBackground = placeMap[condition];
          continue;
        }

        final eventImage = eventMap[condition];
        if (eventImage != null && eventImage.isNotEmpty) {
          workingCharacter = eventImage;
          continue;
        }

        final comboImage = comboMap[condition];
        if (comboImage != null && comboImage.isNotEmpty) {
          workingCharacter = comboImage;
          continue;
        }

        continue;
      }

      if (type == 'narration' || type == 'dialogue') {
        final content = (scene['content'] ?? '').toString().trim();
        if (content.isEmpty) continue;

        final speaker = (scene['speaker'] ?? '').toString().trim();
        final isNarration = type == 'narration' || speaker.isEmpty;

        if (!isNarration && (workingCharacter == null || workingCharacter.isEmpty)) {
          workingCharacter = _resolveDefaultCharacterImage(story, speaker);
        }

        paragraphs.add(
          _VisualParagraph(
            text: content,
            speaker: speaker,
            isNarration: isNarration,
            place: workingPlace,
            backgroundUrl: workingBackground,
            characterUrl: workingCharacter,
          ),
        );
      }
    }

    final normalizedParagraphs = paragraphs.isNotEmpty
        ? paragraphs
        : <_VisualParagraph>[
            _VisualParagraph(
              text: '다음 이야기를 준비하고 있습니다.',
              speaker: '',
              isNarration: true,
              place: workingPlace,
              backgroundUrl: workingBackground,
              characterUrl: null,
            ),
          ];

    safeSetState(() {
      _currentPlace = workingPlace;
      _currentBackgroundImageUrl = workingBackground;
      _currentCharacterImageUrl = workingCharacter;
      _paragraphs = normalizedParagraphs;
      _currentParagraphIndex = 0;
      _showActionPanel = false;
    });
  }

  void _restoreLatestTurnFromSavedMessages(StoriesRecord story) {
    final messages = _model.chatMessages.toList();
    if (messages.isEmpty) {
      _applyScenesToVisualTurn(const [], story);
      return;
    }

    var startIndex = 0;
    for (var i = messages.length - 1; i >= 0; i--) {
      if ((messages[i].type).toString() == 'turn_header') {
        startIndex = i;
        break;
      }
    }

    final turnMessages = messages.sublist(startIndex);
    final placeMap = _buildPlaceImageMap(story);

    var workingPlace = _currentPlace;
    var workingBackground = _currentBackgroundImageUrl;
    String? workingCharacter = _currentCharacterImageUrl;

    final paragraphs = <_VisualParagraph>[];

    for (final message in turnMessages) {
      final type = (message.type).toString();

      if (type == 'turn_header') {
        final parsedPlace = _extractPlaceFromHeader(message.text);
        if (parsedPlace != null && parsedPlace.isNotEmpty) {
          final changed = parsedPlace != workingPlace;
          workingPlace = parsedPlace;
          if (changed) {
            workingCharacter = null;
            workingBackground = placeMap[parsedPlace];
          } else {
            workingBackground ??= placeMap[parsedPlace];
          }
        }
        continue;
      }

      if (type == 'story_image') {
        final imageUrl = functions.stringToImagePath((message.storyImageUrl).toString()).trim();
        if (imageUrl.isEmpty) continue;

        final placeByImage = _findPlaceByImageUrl(placeMap, imageUrl);
        if (placeByImage != null) {
          workingBackground = imageUrl;
          workingPlace = placeByImage;
        } else {
          workingCharacter = imageUrl;
        }
        continue;
      }

      if (type == 'narration' || type == 'dialogue') {
        final text = (message.text).toString().trim();
        if (text.isEmpty) continue;

        final speaker = (message.speakerName).toString().trim();
        final isNarration = type == 'narration' || speaker.isEmpty;

        if (!isNarration && (workingCharacter == null || workingCharacter.isEmpty)) {
          workingCharacter = _resolveDefaultCharacterImage(story, speaker);
        }

        paragraphs.add(
          _VisualParagraph(
            text: text,
            speaker: speaker,
            isNarration: isNarration,
            place: workingPlace,
            backgroundUrl: workingBackground,
            characterUrl: workingCharacter,
          ),
        );
      }
    }

    if (paragraphs.isEmpty) {
      _applyScenesToVisualTurn(const [], story);
      return;
    }

    safeSetState(() {
      _currentPlace = workingPlace;
      _currentBackgroundImageUrl = workingBackground;
      _currentCharacterImageUrl = workingCharacter;
      _paragraphs = paragraphs;
      _currentParagraphIndex = paragraphs.length - 1;
      _showActionPanel = true;
    });
  }

  void _onTapPrevious() {
    if (_isGenerating || _paragraphs.isEmpty) return;

    safeSetState(() {
      if (_showActionPanel) {
        _showActionPanel = false;
        return;
      }

      if (_currentParagraphIndex > 0) {
        _currentParagraphIndex--;
      }
    });
  }

  void _onTapNext() {
    if (_isGenerating || _paragraphs.isEmpty) return;

    safeSetState(() {
      if (_showActionPanel) return;

      if (_currentParagraphIndex < _paragraphs.length - 1) {
        _currentParagraphIndex++;
      } else {
        _showActionPanel = true;
      }
    });
  }

  Future<void> _handleChoiceOrSend(
    String userInput,
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) async {
    final input = userInput.trim();
    if (input.isEmpty) {
      _showMessage('메시지를 입력해주세요.');
      return;
    }

    await _requestNextTurn(
      input,
      story,
      chatDoc,
    );
  }

  Future<void> _requestNextTurn(
    String userInput,
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) async {
    if (_isGenerating) return;

    if (!loggedIn || currentUserReference == null) {
      await _showLoginSheet();
      return;
    }

    final selectedModelId = _resolveSelectedModelId(chatDoc.selectedAiModel);

    final pointCost = await actions.getPointCostAction(
      selectedModelId,
    );

    if (valueOrDefault(currentUserDocument?.points, 0) < pointCost) {
      final moveToCharge = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('포인트 부족'),
                content: const Text('포인트가 부족합니다. 충전페이지로 이동할까요?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('이동하기'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('취소하기'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (moveToCharge && mounted) {
        context.pushNamed(PointchargepageWidget.routeName);
      }
      return;
    }

    final batch = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: '(default)',
    ).batch();

    var shouldCommit = false;
    final nextMessageCount = valueOrDefault<int>(chatDoc.messageCount, 0) + 1;

    safeSetState(() {
      _isGenerating = true;
    });

    try {
      _model.userinput = userInput;

      batch.set(
        StorymessagesRecord.createDoc(chatDoc.reference),
        createStorymessagesRecordData(
          timestamp: getCurrentTimestamp,
          text: userInput,
          type: 'user',
          speakerName: widget.userInChatName,
          userRef: currentUserReference,
        ),
      );

      batch.update(currentUserReference!, {
        ...mapToFirestore(
          {
            'points': FieldValue.increment(-(pointCost)),
          },
        ),
      });

      final creatorShare = await actions.calculateCreatorEarningAction(
        selectedModelId,
      );

      if (chatDoc.creatorRef != null && currentUserReference != chatDoc.creatorRef) {
        batch.update(chatDoc.creatorRef!, {
          ...mapToFirestore(
            {
              'earnings': FieldValue.increment(creatorShare),
            },
          ),
        });
      }

      final formattedHistory = await actions.getAndProcessHistory(
        widget.storychatRef,
      );

      final aiRaw = await actions.callAiProxy(
        selectedModelId,
        functions.buildStoryPrompt(
          story.title,
          story.worldview,
          story.characters.toList(),
          story.userRole,
          story.places.toList(),
          chatDoc.userNote,
          widget.userInChatName ?? '',
          functions.dynamicContextByOutlineMode(
            valueOrDefault<bool>(
              story.outlineMode,
              false,
            ),
            story.outlineText,
            valueOrDefault<int>(
              chatDoc.turnCount,
              0,
            ),
            valueOrDefault<int>(
              chatDoc.chapterIndex,
              1,
            ),
            chatDoc.storyBible,
            chatDoc.chapterState,
            chatDoc.summary,
          ),
          story.place,
          story.event,
          story.events.toList(),
        ),
        formattedHistory.toList(),
        userInput,
      );
      final aiRawText = (aiRaw ?? '').trim();

      if (aiRawText == 'BLOCKED_CONTENT') {
        _showMessage('부적절한 내용이라 답변할 수 없습니다.');
        return;
      }

      if (aiRawText.isEmpty || aiRawText.startsWith('ERROR:')) {
        _showMessage('다음 턴 생성에 실패했습니다. 다시 시도해주세요.');
        return;
      }

      final formattedScript = await actions.formatStoryTurnHeaderAndBg(
        aiRawText,
        _model.chatMessages.toList(),
        story.places.toList(),
        story.characters.toList(),
        widget.userInChatName,
        false,
      );

      final scenes = _parseScriptIntoScenes(formattedScript);
      final savedMessages = await actions.processAndSaveChatTurn(
        scenes,
        chatDoc.reference,
        story.places.toList(),
        story.characters.toList(),
        story.events.toList(),
      );

      _model.addToChatMessages(
        StoryChatMessageStructStruct(
          text: userInput,
          type: 'user',
          speakerName: widget.userInChatName,
        ),
      );
      _model.chatMessages = functions
          .mergeChatLists(_model.chatMessages.toList(), savedMessages.toList())
          .toList()
          .cast<StoryChatMessageStructStruct>();

      batch.update(chatDoc.reference, {
        ...mapToFirestore(
          {
            'messageCount': FieldValue.increment(1),
          },
        ),
      });

      shouldCommit = true;

      _applyScenesToVisualTurn(scenes, story);

      safeSetState(() {
        _model.usertextFieldTextController?.clear();
      });
    } catch (_) {
      _showMessage('다음 턴 생성에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (shouldCommit) {
        await batch.commit();

        if (functions.isSummaryTurn(nextMessageCount)) {
          await chatDoc.reference.update(
            createStorychatsRecordData(
              lastSummaryMessageCount: nextMessageCount,
            ),
          );
        }

        await actions.updateStoryMemory(
          chatDoc.reference,
          story.outlineMode,
          story.outlineText,
        );
      }

      if (!mounted) return;
      safeSetState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _handleChatModeSend(
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) async {
    if (_isGenerating) return;
    final text = (_model.messageTextFieldTextController?.text ?? '').trim();
    if (text.isEmpty) {
      _showMessage('메시지를 입력해주세요.');
      return;
    }

    safeSetState(() {
      _model.messageTextFieldTextController?.clear();
    });

    await _requestNextTurn(
      text,
      story,
      chatDoc,
    );
  }

  Widget _buildChatMessageBubble(
    BuildContext context,
    StoryChatMessageStructStruct message,
  ) {
    final type = (message.type).toString();

    if (type == 'turn_header') {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
          child: Text(
            (message.text).toString(),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FlutterFlowTheme.of(context)
                        .labelMedium
                        .fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).alternate,
                  letterSpacing: 0.0,
                ),
          ),
        ),
      );
    }

    if (type == 'story_image') {
      final imageUrl = functions.stringToImagePath((message.storyImageUrl).toString()).trim();
      if (!_isValidNetworkImageUrl(imageUrl)) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: safeNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: 180.0,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final isUser = type == 'user';
    final speaker = (message.speakerName).toString().trim();
    final bubbleText = (message.text).toString().trim();
    if (bubbleText.isEmpty) {
      return const SizedBox.shrink();
    }

    final titleText = !isUser && speaker.isNotEmpty && speaker != 'null'
        ? speaker
        : (isUser ? (widget.userInChatName ?? '나') : '');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 6.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.82,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFFFD1BA) : const Color(0x22131A24),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isUser
                    ? const Color(0xFFFFD1BA)
                    : FlutterFlowTheme.of(context).alternate,
              ),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titleText.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                    child: Text(
                      titleText,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                            ),
                            color: isUser
                                ? const Color(0xFF5A2E16)
                                : FlutterFlowTheme.of(context).primaryBackground,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                Text(
                  bubbleText,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: isUser
                            ? const Color(0xFF2A150B)
                            : FlutterFlowTheme.of(context).primaryBackground,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatModeBody(
    BuildContext context,
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) {
    final messages = _model.chatMessages.toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildChatMessageBubble(
                context,
                message,
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xE612161D),
              border: Border(
                top: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _model.messageTextFieldTextController,
                    focusNode: _model.messageTextFieldFocusNode,
                    autofocus: false,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight:
                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle:
                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          letterSpacing: 0.0,
                        ),
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).alternate,
                            letterSpacing: 0.0,
                          ),
                      filled: true,
                      fillColor: const Color(0x1AFFFFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(
                        12.0,
                        10.0,
                        12.0,
                        10.0,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) async {
                      await _handleChatModeSend(
                        story,
                        chatDoc,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: FlutterFlowTheme.of(context).primaryBackground,
                  ),
                  onPressed: _isGenerating
                      ? null
                      : () async {
                          await _handleChatModeSend(
                            story,
                            chatDoc,
                          );
                        },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storyRef == null || widget.storychatRef == null) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        body: Center(
          child: Text(
            '스토리 정보를 찾을 수 없습니다.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  letterSpacing: 0.0,
                ),
          ),
        ),
      );
    }

    final currentParagraph = _paragraphs.isNotEmpty
        ? _paragraphs[_currentParagraphIndex]
        : null;

    final paragraphPlace = (currentParagraph?.place ?? _currentPlace).trim();
    final placeText = paragraphPlace.isEmpty ? '어딘가' : paragraphPlace;

    final backgroundImageUrl = functions
        .stringToImagePath(
          currentParagraph?.backgroundUrl ?? _currentBackgroundImageUrl,
        )
        .trim();

    final characterImageUrl =
        functions.stringToImagePath(currentParagraph?.characterUrl).trim();

    return StreamBuilder<StoriesRecord>(
      stream: StoriesRecord.getDocument(widget.storyRef!),
      builder: (context, storySnapshot) {
        if (!storySnapshot.hasData || _isInitializing) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryText,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final story = storySnapshot.data!;

        return StreamBuilder<StorychatsRecord>(
          stream: StorychatsRecord.getDocument(widget.storychatRef!),
          builder: (context, chatSnapshot) {
            if (!chatSnapshot.hasData) {
              return Scaffold(
                backgroundColor: FlutterFlowTheme.of(context).primaryText,
                body: Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                ),
              );
            }

            final chatDoc = chatSnapshot.data!;
            final selectedModelLabel =
                _resolveSelectedModelLabel(chatDoc.selectedAiModel);

            if (!_didBackfillDefaultModel &&
                (chatDoc.selectedAiModel).toString().trim().isEmpty) {
              _didBackfillDefaultModel = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                try {
                  await _updateSelectedModel(chatDoc, _defaultAiModelId);
                } catch (_) {}
              });
            }

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0.0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    onPressed: () async {
                      context.pushNamed(ChatlistpageWidget.routeName);
                    },
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w700,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        placeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).alternate,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                      onPressed: () async {
                        await _openSettingsSheet(chatDoc);
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        safeSetState(() {
                          _isChatMode = !_isChatMode;
                        });
                      },
                      child: Text(
                        _isChatMode ? 'visualmode' : 'changemode',
                        style: FlutterFlowTheme.of(context).labelMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primaryBackground,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    if (_isGenerating)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                        child: Center(
                          child: SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                              ),
                            ),
                          ),
                      ),
                  ],
                ),
                body: _isChatMode
                    ? _buildChatModeBody(
                        context,
                        story,
                        chatDoc,
                      )
                    : Stack(
                        children: [
                    Positioned.fill(
                      child: _isValidNetworkImageUrl(backgroundImageUrl)
                          ? safeNetworkImage(
                              imageUrl: backgroundImageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF13161D),
                                    Color(0xFF1C222C),
                                    Color(0xFF101317),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '배경 이미지 없음',
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
                                          FlutterFlowTheme.of(context).alternate,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                    ),
                    if (_isValidNetworkImageUrl(characterImageUrl))
                      Align(
                        alignment: AlignmentDirectional(0.0, 1.0),
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 170.0),
                          child: safeNetworkImage(
                            imageUrl: characterImageUrl,
                            width: double.infinity,
                            height: MediaQuery.sizeOf(context).height * 0.62,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    Positioned.fill(
                      bottom: _showActionPanel ? 250.0 : 170.0,
                      child: IgnorePointer(
                        ignoring: _showActionPanel || _isGenerating,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: _onTapPrevious,
                                child: const SizedBox.expand(),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: _onTapNext,
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 1.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0x00000000),
                              const Color(0xBF000000),
                              const Color(0xE6000000),
                            ],
                            stops: const [0.0, 0.25, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                        ),
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!(currentParagraph?.isNarration ?? true))
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 8.0),
                                  child: Text(
                                    currentParagraph?.speaker ?? '',
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w700,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: const Color(0xFFFFD58F),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              Text(
                                currentParagraph?.text ?? '스토리를 준비중입니다.',
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
                                      color: (currentParagraph?.isNarration ?? true)
                                          ? const Color(0xFFE0E3E7)
                                          : const Color(0xFFFFFFFF),
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              if (!_showActionPanel)
                                Align(
                                  alignment: AlignmentDirectional(1.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 0.0),
                                    child: Text(
                                      _paragraphs.isEmpty
                                          ? '0/0'
                                          : '${_currentParagraphIndex + 1}/${_paragraphs.length}',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FlutterFlowTheme.of(
                                                      context)
                                                  .labelSmall
                                                  .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ),
                              if (_showActionPanel)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 14.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ..._defaultChoices.map(
                                        (choiceText) => Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 8.0),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: _isGenerating
                                                  ? null
                                                  : () async {
                                                      await _handleChoiceOrSend(
                                                        choiceText,
                                                        story,
                                                        chatDoc,
                                                      );
                                                    },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .alternate,
                                                ),
                                                padding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                            12.0,
                                                            10.0,
                                                            12.0,
                                                            10.0)
                                                        .resolve(
                                                            Directionality.of(
                                                                context)),
                                              ),
                                              child: Text(
                                                choiceText,
                                                style: FlutterFlowTheme.of(
                                                        context)
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
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0x26000000),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: _model
                                                    .usertextFieldTextController,
                                                focusNode:
                                                    _model.usertextFieldFocusNode,
                                                autofocus: false,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
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
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          letterSpacing: 0.0,
                                                        ),
                                                decoration: InputDecoration(
                                                  hintText: '직접 입력...',
                                                  hintStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .labelMedium
                                                          .override(
                                                            font:
                                                                GoogleFonts.inter(
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
                                                                .alternate,
                                                            letterSpacing: 0.0,
                                                          ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(12.0, 10.0,
                                                              12.0, 10.0),
                                                ),
                                                maxLength: 200,
                                                maxLengthEnforcement:
                                                    MaxLengthEnforcement.enforced,
                                                buildCounter: (context,
                                                        {required currentLength,
                                                        required isFocused,
                                                        maxLength}) =>
                                                    null,
                                                onFieldSubmitted: (_) async {
                                                  if (_isGenerating) return;
                                                  await _handleChoiceOrSend(
                                                    _model.usertextFieldTextController
                                                        .text,
                                                    story,
                                                    chatDoc,
                                                  );
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.send,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                              ),
                                              onPressed: _isGenerating
                                                  ? null
                                                  : () async {
                                                      await _handleChoiceOrSend(
                                                        _model
                                                            .usertextFieldTextController
                                                            .text,
                                                        story,
                                                        chatDoc,
                                                      );
                                                    },
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
                    ),
                    if (_isGenerating)
                      Positioned.fill(
                        child: Container(
                          color: const Color(0x66000000),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 36.0,
                                height: 36.0,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 0.0),
                                child: Text(
                                  '다음 턴 생성 중...',
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                      ),
                    ),
                    Positioned(
                      top: 16.0,
                      right: 16.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          10.0,
                          6.0,
                          10.0,
                          6.0,
                        ),
                        child: Text(
                          selectedModelLabel,
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                ),
                                color: Colors.red,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
