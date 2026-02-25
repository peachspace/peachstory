import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/home/loginpage/loginpage_widget.dart';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'visualnovelpage_model.dart';
export 'visualnovelpage_model.dart';

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
    this.isNovelMode,
  });

  final DocumentReference? storyRef;
  final DocumentReference? storychatRef;
  final String? userInChatName;
  final bool? isNovelMode;

  static String routeName = 'visualnovelpage';
  static String routePath = '/visualnovelpage';

  @override
  State<VisualnovelpageWidget> createState() => _VisualnovelpageWidgetState();
}

class _VisualnovelpageWidgetState extends State<VisualnovelpageWidget> {
  static const String _defaultAiModelId = 'claude-3-haiku-20240307';
  late VisualnovelpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSendingTurn = false;
  bool _isInitializing = true;
  bool _isGenerating = false;

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
    _model.currentDocRef = widget.storychatRef;

    _model.usertextFieldTextController ??= TextEditingController();
    _model.usertextFieldFocusNode ??= FocusNode();

    _model.messageTextFieldTextController ??= TextEditingController();
    _model.messageTextFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _initializeVisualNovel();
    });
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
    return value.isEmpty ? _defaultAiModelId : value;
  }

  bool _isValidNetworkImageUrl(String? url) {
    final value = functions.stringToImagePath(url).trim();
    return value.startsWith('http://') || value.startsWith('https://');
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
      _model.messagesAsJson ??= <dynamic>[];
      _model.messageAsJson = _model.messagesAsJson!.toList();

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
              .mergeChatLists(
                _model.chatMessages.toList(),
                savedMessages.toList(),
              )
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

    final profile =
        functions.stringToImagePath((character.profileimage).toString()).trim();
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

        if (!isNarration &&
            (workingCharacter == null || workingCharacter.isEmpty)) {
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
        final imageUrl =
            functions.stringToImagePath((message.storyImageUrl).toString()).trim();
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

        if (!isNarration &&
            (workingCharacter == null || workingCharacter.isEmpty)) {
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
    final pointCost = await actions.getPointCostAction(selectedModelId);
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

    safeSetState(() {
      _isGenerating = true;
    });

    final nextMessageCount = valueOrDefault<int>(chatDoc.messageCount, 0) + 1;

    try {
      await StorymessagesRecord.createDoc(chatDoc.reference).set(
        createStorymessagesRecordData(
          timestamp: getCurrentTimestamp,
          text: userInput,
          type: 'user',
          speakerName: widget.userInChatName,
          userRef: currentUserReference,
        ),
      );

      await currentUserReference!.update({
        ...mapToFirestore({
          'points': FieldValue.increment(-(pointCost)),
        }),
      });

      final creatorShare = await actions.calculateCreatorEarningAction(
        selectedModelId,
      );
      if (chatDoc.creatorRef != null &&
          currentUserReference != chatDoc.creatorRef) {
        await chatDoc.creatorRef!.update({
          ...mapToFirestore({
            'earnings': FieldValue.increment(creatorShare),
          }),
        });
      }

      final formattedHistory = await actions.getAndProcessHistory(
        widget.storychatRef,
      );
      final hybridMemory = await actions.buildHybridMemoryContext(
        widget.storychatRef,
        userInput,
      );
      final promptMemory = [
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
        hybridMemory,
      ].where((part) => part.trim().isNotEmpty).join('\n\n');

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
          promptMemory,
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

      await chatDoc.reference.update({
        ...mapToFirestore(
          {
            'messageCount': FieldValue.increment(1),
          },
        ),
      });

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

      _applyScenesToVisualTurn(scenes, story);
      _model.usertextFieldTextController?.clear();
      safeSetState(() {});
    } catch (_) {
      _showMessage('다음 턴 생성에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (!mounted) return;
      safeSetState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _handleChatSend(
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) async {
    if (_isSendingTurn) return;

    final userInput = _model.messageTextFieldTextController.text.trim();
    if (userInput.isEmpty) {
      _showMessage('메시지를 입력해주세요.');
      return;
    }

    if (!loggedIn || currentUserReference == null) {
      await _showLoginSheet();
      return;
    }

    final selectedModelId = _resolveSelectedModelId(chatDoc.selectedAiModel);
    final pointCost = await actions.getPointCostAction(selectedModelId);
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

    safeSetState(() {
      _isSendingTurn = true;
    });

    try {
      await StorymessagesRecord.createDoc(chatDoc.reference).set(
        createStorymessagesRecordData(
          timestamp: getCurrentTimestamp,
          text: userInput,
          type: 'user',
          speakerName: widget.userInChatName,
          userRef: currentUserReference,
        ),
      );

      await currentUserReference!.update({
        ...mapToFirestore({
          'points': FieldValue.increment(-(pointCost)),
        }),
      });

      final creatorShare = await actions.calculateCreatorEarningAction(
        selectedModelId,
      );
      if (chatDoc.creatorRef != null &&
          currentUserReference != chatDoc.creatorRef) {
        await chatDoc.creatorRef!.update({
          ...mapToFirestore({
            'earnings': FieldValue.increment(creatorShare),
          }),
        });
      }

      final formattedHistory = await actions.getAndProcessHistory(
        widget.storychatRef,
      );
      final hybridMemory = await actions.buildHybridMemoryContext(
        widget.storychatRef,
        userInput,
      );
      final promptMemory = [
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
        hybridMemory,
      ].where((part) => part.trim().isNotEmpty).join('\n\n');

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
          promptMemory,
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

      _model.aiResponseScript = await actions.formatStoryTurnHeaderAndBg(
        aiRawText,
        _model.chatMessages.toList(),
        story.places.toList(),
        story.characters.toList(),
        widget.userInChatName,
        false,
      );
      _model.messageTextFieldTextController?.clear();
      safeSetState(() {});
    } catch (_) {
      _showMessage('다음 턴 생성에 실패했습니다. 다시 시도해주세요.');
    } finally {
      if (!mounted) return;
      safeSetState(() {
        _isSendingTurn = false;
      });
    }
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

    return StreamBuilder<StoriesRecord>(
      stream: StoriesRecord.getDocument(widget.storyRef!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData || _isInitializing) {
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

        final visualnovelpageStoriesRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryText,
            body: Builder(
              builder: (context) {
                if (_model.isvisualmode == true) {
                  final currentParagraph = _paragraphs.isNotEmpty
                      ? _paragraphs[_currentParagraphIndex]
                      : null;
                  final choice1 = _defaultChoices.isNotEmpty
                      ? _defaultChoices[0]
                      : '';
                  final choice2 = _defaultChoices.length > 1
                      ? _defaultChoices[1]
                      : '';
                  final choice3 = _defaultChoices.length > 2
                      ? _defaultChoices[2]
                      : '';
                  final topTitle = visualnovelpageStoriesRecord.title;
                  final topPlace =
                      (currentParagraph?.place ?? _currentPlace).trim();
                  final pageLabel = _paragraphs.isEmpty
                      ? '0/0'
                      : '${_currentParagraphIndex + 1}/${_paragraphs.length}';

                  final bgImageUrl = functions
                      .stringToImagePath(
                        currentParagraph?.backgroundUrl ??
                            _currentBackgroundImageUrl,
                      )
                      .trim();
                  final charImageUrl = functions
                      .stringToImagePath(
                        currentParagraph?.characterUrl ??
                            _currentCharacterImageUrl,
                      )
                      .trim();

                  final dialogueText =
                      _showActionPanel ? '' : (currentParagraph?.text ?? '');
                  final speakerText = _showActionPanel ||
                          (currentParagraph?.isNarration ?? true)
                      ? ''
                      : (currentParagraph?.speaker ?? '');

                  return StreamBuilder<StorychatsRecord>(
                    stream: StorychatsRecord.getDocument(widget.storychatRef!),
                    builder: (context, chatSnapshot) {
                      if (!chatSnapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final visualChatDoc = chatSnapshot.data!;

                      return Stack(
                        children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _isValidNetworkImageUrl(bgImageUrl)
                            ? Image.network(
                                bgImageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: double.infinity,
                                  height: double.infinity,
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
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: double.infinity,
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
                              ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _isValidNetworkImageUrl(charImageUrl)
                            ? Image.network(
                                charImageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              )
                            : const SizedBox.shrink(),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 50.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 7.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x26000000),
                                            Color(0x73000000),
                                            Color(0x8C000000),
                                            Color(0x8C000000),
                                            Color(0x73000000),
                                            Color(0x26000000)
                                          ],
                                          stops: [
                                            0.0,
                                            0.08,
                                            0.2,
                                            0.8,
                                            0.92,
                                            1.0
                                          ],
                                          begin: AlignmentDirectional(1.0, 0.0),
                                          end: AlignmentDirectional(-1.0, 0),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(0.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 0.0, 25.0, 7.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0),
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (!_showActionPanel) return;
                                        await _handleChoiceOrSend(
                                          choice1,
                                          visualnovelpageStoriesRecord,
                                          visualChatDoc,
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 20.0, 0.0),
                                        child: AutoSizeText(
                                          _showActionPanel ? choice1 : '',
                                          maxLines: 3,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
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
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 7.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x26000000),
                                            Color(0x73000000),
                                            Color(0x8C000000),
                                            Color(0x8C000000),
                                            Color(0x73000000),
                                            Color(0x26000000)
                                          ],
                                          stops: [
                                            0.0,
                                            0.08,
                                            0.2,
                                            0.8,
                                            0.92,
                                            1.0
                                          ],
                                          begin: AlignmentDirectional(1.0, 0.0),
                                          end: AlignmentDirectional(-1.0, 0),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(0.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 0.0, 25.0, 7.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0),
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (!_showActionPanel) return;
                                        await _handleChoiceOrSend(
                                          choice2,
                                          visualnovelpageStoriesRecord,
                                          visualChatDoc,
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 20.0, 0.0),
                                        child: AutoSizeText(
                                          _showActionPanel ? choice2 : '',
                                          maxLines: 3,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
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
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 7.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x26000000),
                                            Color(0x73000000),
                                            Color(0x8C000000),
                                            Color(0x8C000000),
                                            Color(0x73000000),
                                            Color(0x26000000)
                                          ],
                                          stops: [
                                            0.0,
                                            0.08,
                                            0.2,
                                            0.8,
                                            0.92,
                                            1.0
                                          ],
                                          begin: AlignmentDirectional(1.0, 0.0),
                                          end: AlignmentDirectional(-1.0, 0),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(0.0),
                                          topLeft: Radius.circular(0.0),
                                          topRight: Radius.circular(0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 0.0, 25.0, 7.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0),
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (!_showActionPanel) return;
                                        await _handleChoiceOrSend(
                                          choice3,
                                          visualnovelpageStoriesRecord,
                                          visualChatDoc,
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 20.0, 0.0),
                                        child: AutoSizeText(
                                          _showActionPanel ? choice3 : pageLabel,
                                          maxLines: 3,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
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
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.3,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              width: 290.0,
                                              child: TextFormField(
                                                controller: _model
                                                    .usertextFieldTextController,
                                                focusNode: _model
                                                    .usertextFieldFocusNode,
                                                autofocus: false,
                                                enabled: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
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
                                                            .secondaryBackground,
                                                        letterSpacing: 0.0,
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
                                                  hintText: '직접 입력...',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
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
                                                            .secondaryBackground,
                                                        letterSpacing: 0.0,
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
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                ),
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
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
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
                                                maxLines: null,
                                                minLines: 1,
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                enableInteractiveSelection:
                                                    true,
                                                onFieldSubmitted: (_) async {
                                                  await _handleChoiceOrSend(
                                                    _model.usertextFieldTextController
                                                            ?.text ??
                                                        '',
                                                    visualnovelpageStoriesRecord,
                                                    visualChatDoc,
                                                  );
                                                },
                                                validator: _model
                                                    .usertextFieldTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 0.0, 0.0, 0.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await _handleChoiceOrSend(
                                                  _model
                                                          .usertextFieldTextController
                                                          ?.text ??
                                                      '',
                                                  visualnovelpageStoriesRecord,
                                                  visualChatDoc,
                                                );
                                              },
                                              child: Icon(
                                                Icons.send,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 20.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 200.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0x33000000)
                                      ],
                                      stops: [0.0, 0.25],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 200.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        40.0, 20.0, 40.0, 50.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Text(
                                            speakerText,
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .warning,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
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
                                          ),
                                        ),
                                        Text(
                                          dialogueText,
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
                                                color: (currentParagraph
                                                                ?.isNarration ??
                                                            true)
                                                    ? Color(0xFFE0E3E7)
                                                    : Color(0xFFFFFFFF),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned.fill(
                        bottom: _showActionPanel ? 250.0 : 170.0,
                        child: IgnorePointer(
                          ignoring: _isGenerating,
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
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0x33000000)
                                      ],
                                      stops: [0.0, 0.25],
                                      begin: AlignmentDirectional(0.0, 1.0),
                                      end: AlignmentDirectional(0, -1.0),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                      topLeft: Radius.circular(0.0),
                                      topRight: Radius.circular(0.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        60.0, 40.0, 40.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 8.0),
                                          child: Text(
                                            topTitle,
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
                                                      .secondaryBackground,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          topPlace.isEmpty ? '어딘가' : topPlace,
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
                                                        .warning,
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
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    25.0, 50.0, 25.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          ChatlistpageWidget.routeName,
                                        );
                                      },
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        size: 22.0,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 10.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor:
                                                Colors.transparent,
                                            onTap: () async {
                                              safeSetState(() {
                                                _model.isvisualmode = false;
                                              });
                                            },
                                            child: Icon(
                                              Icons.cached,
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                              size: 22.0,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            scaffoldKey.currentState!
                                                .openEndDrawer();
                                          },
                                          child: Icon(
                                            Icons.menu,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 25.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                        ],
                      );
                    },
                  );
                } else {
                  return StreamBuilder<StorychatsRecord>(
                    stream: StorychatsRecord.getDocument(widget.storychatRef!),
                    builder: (context, snapshot) {
                      // Customize what your widget looks like when it's loading.
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final stackStorychatsRecord = snapshot.data!;

                      return Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 70.0,
                                height: 70.0,
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      25.0, 0.0, 25.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        visualnovelpageStoriesRecord.title,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              fontSize: 18.0,
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
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          safeSetState(() {
                                            _model.isvisualmode = true;
                                          });
                                        },
                                        child: Icon(
                                          Icons.cached,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          size: 24.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        25.0, 0.0, 25.0, 0.0),
                                    child: custom_widgets.NotifierChatList(
                                      width: double.infinity,
                                      height: double.infinity,
                                      newResponseScript:
                                          _model.aiResponseScript,
                                      userInChatName: widget.userInChatName,
                                      initialMessages: _model.chatMessages,
                                      preDefinedCharacters:
                                          visualnovelpageStoriesRecord
                                              .characters,
                                      backgroundList:
                                          visualnovelpageStoriesRecord.places,
                                      onTurnComplete: (scenes) async {
                                        _model.newMessages = await actions
                                            .processAndSaveChatTurn(
                                          scenes!.toList(),
                                          stackStorychatsRecord.reference,
                                          visualnovelpageStoriesRecord.places
                                              .toList(),
                                          visualnovelpageStoriesRecord
                                              .characters
                                              .toList(),
                                          visualnovelpageStoriesRecord.events
                                              .toList(),
                                        );
                                        _model.chatMessages = functions
                                            .mergeChatLists(
                                                _model.chatMessages.toList(),
                                                _model.newMessages?.toList())
                                            .toList()
                                            .cast<
                                                StoryChatMessageStructStruct>();
                                        safeSetState(() {});

                                        await stackStorychatsRecord.reference
                                            .update({
                                          ...mapToFirestore(
                                            {
                                              'messageCount':
                                                  FieldValue.increment(1),
                                            },
                                          ),
                                        });
                                        await actions.updateStoryMemory(
                                          _model.currentDocRef!,
                                          visualnovelpageStoriesRecord
                                              .outlineMode,
                                          visualnovelpageStoriesRecord
                                              .outlineText,
                                        );
                                        if (functions
                                            .isSummaryTurn(valueOrDefault<int>(
                                                  stackStorychatsRecord
                                                      .messageCount,
                                                  0,
                                                ) +
                                                1)) {
                                          await stackStorychatsRecord.reference
                                              .update(
                                                  createStorychatsRecordData(
                                            lastSummaryMessageCount:
                                                valueOrDefault<int>(
                                                      stackStorychatsRecord
                                                          .messageCount,
                                                      0,
                                                    ) +
                                                    1,
                                          ));
                                        }
                                        _model.aiResponseScript = '';
                                        safeSetState(() {});

                                        safeSetState(() {});
                                      },
                                      onLoadOlderMessages: () async {
                                        _model.olderMessages = await actions
                                            .getPreviousChatHistory(
                                          stackStorychatsRecord.reference,
                                          _model.messageAsJson.toList(),
                                          30,
                                        );
                                        _model.messageAsJson = functions
                                            .combineJsonLists(
                                                _model.olderMessages?.toList(),
                                                _model.messageAsJson.toList())
                                            .toList()
                                            .cast<dynamic>();
                                        safeSetState(() {});

                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: SafeArea(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                        topLeft: Radius.circular(30.0),
                                        topRight: Radius.circular(30.0),
                                      ),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 1.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  25.0, 0.0, 25.0, 0.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 50.0,
                                            decoration: BoxDecoration(),
                                            child: Container(
                                              width: double.infinity,
                                              child: TextFormField(
                                                controller: _model
                                                    .messageTextFieldTextController,
                                                focusNode: _model
                                                    .messageTextFieldFocusNode,
                                                autofocus: false,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      '캐릭터의 대사나 행동을 입력하세요.',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  focusedErrorBorder:
                                                      InputBorder.none,
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                maxLines: null,
                                                maxLength: 200,
                                                maxLengthEnforcement:
                                                    MaxLengthEnforcement
                                                        .enforced,
                                                buildCounter: (context,
                                                        {required currentLength,
                                                        required isFocused,
                                                        maxLength}) =>
                                                    null,
                                                validator: _model
                                                    .messageTextFieldTextControllerValidator
                                                    .asValidator(context),
                                                inputFormatters: [
                                                  if (!isAndroid && !isiOS)
                                                    TextInputFormatter
                                                        .withFunction((oldValue,
                                                            newValue) {
                                                      return TextEditingValue(
                                                        selection:
                                                            newValue.selection,
                                                        text: newValue.text
                                                            .toCapitalization(
                                                                TextCapitalization
                                                                    .sentences),
                                                      );
                                                    }),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 25.0, 0.0),
                                                child: FlutterFlowIconButton(
                                                  borderRadius: 10.0,
                                                  buttonSize: 35.0,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                  icon: Icon(
                                                    Icons.send,
                                                    color: Colors.white,
                                                    size: 20.0,
                                                  ),
                                                  showLoadingIndicator: true,
                                                  onPressed: () async {
                                                    await _handleChatSend(
                                                      visualnovelpageStoriesRecord,
                                                      stackStorychatsRecord,
                                                    );
                                                  },
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
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
