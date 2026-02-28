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

class _StatusValue {
  const _StatusValue({
    required this.name,
    required this.value,
  });

  final String name;
  final String value;
}

class _RuntimeResourceItem {
  const _RuntimeResourceItem({
    required this.kind,
    required this.resourceName,
    required this.currentValue,
    required this.increaseOrDecrease,
    required this.deltaValue,
    required this.condition,
    required this.operatorValue,
    required this.referenceValue,
    required this.effect,
  });

  final String kind;
  final String resourceName;
  final int currentValue;
  final String increaseOrDecrease;
  final int deltaValue;
  final String condition;
  final String operatorValue;
  final int referenceValue;
  final String effect;

  _RuntimeResourceItem copyWith({
    int? currentValue,
  }) {
    return _RuntimeResourceItem(
      kind: kind,
      resourceName: resourceName,
      currentValue: currentValue ?? this.currentValue,
      increaseOrDecrease: increaseOrDecrease,
      deltaValue: deltaValue,
      condition: condition,
      operatorValue: operatorValue,
      referenceValue: referenceValue,
      effect: effect,
    );
  }
}

class _RuntimeResourceCard {
  const _RuntimeResourceCard({
    required this.owner,
    required this.items,
  });

  final String owner;
  final List<_RuntimeResourceItem> items;
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
  bool _showFirstEnterCover = true;
  bool _showStatusPanel = false;

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
  List<String> _currentChoices = const [];
  bool _isInputActionMode = false;
  bool _isChoiceLoading = false;
  bool _isSubmittingSelection = false;
  String _submittedPreviewText = '';
  double _submittedPreviewOffsetY = 0.0;
  int _choiceRequestSerial = 0;
  String _lastChoiceSignature = '';
  List<_StatusValue> _userStatusValues = const [];
  List<_StatusValue> _userItemValues = const [];
  List<_StatusValue> _characterStatusValues = const [];
  List<_StatusValue> _characterItemValues = const [];
  String _characterPanelTitle = '';
  bool _runtimeResourcesInitialized = false;
  List<_RuntimeResourceCard> _runtimeResourceCards = const [];

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

  Future<bool> _showLoginSheet() async {
    final result = await showModalBottomSheet<bool>(
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
            child: const LoginpageWidget(
              navigateToCreateListOnSuccess: false,
            ),
          ),
        );
      },
    );
    if (mounted) {
      safeSetState(() {});
    }
    return result == true || loggedIn;
  }

  String _resolveSelectedModelId(String? rawModelId) {
    final value = (rawModelId ?? '').trim();
    return value.isEmpty ? _defaultAiModelId : value;
  }

  bool _isValidNetworkImageUrl(String? url) {
    final value = functions.stringToImagePath(url).trim();
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _extractChoiceKeyword(String rawText) {
    final tokens = rawText
        .replaceAll(RegExp(r'[^가-힣a-zA-Z0-9\\s]'), ' ')
        .split(RegExp(r'\\s+'))
        .map((part) => part.trim())
        .where((part) => part.length >= 2)
        .where((part) => !const <String>{
              '그리고',
              '하지만',
              '그러나',
              '그래서',
              '그녀',
              '그는',
              '이곳',
              '장면',
              '상황',
              '지금',
            }.contains(part))
        .toList();
    if (tokens.isEmpty) return '';
    tokens.sort((a, b) => b.length.compareTo(a.length));
    return tokens.first;
  }

  List<String> _defaultChoiceCandidates() {
    final paragraph =
        _paragraphs.isNotEmpty ? _paragraphs[_currentParagraphIndex] : null;
    final speaker = (paragraph?.speaker ?? '').trim();
    final place = (paragraph?.place ?? _currentPlace).trim();
    final keyword = _extractChoiceKeyword((paragraph?.text ?? '').trim());
    if (speaker.isNotEmpty && !(paragraph?.isNarration ?? true)) {
      return <String>[
        '${speaker}의 반응을 살핀다.',
        keyword.isNotEmpty ? '"${keyword}에 대해 자세히 묻는다."' : '"방금 말의 의미를 묻는다."',
        place.isNotEmpty ? '$place 주변을 더 조사한다.' : '주변 상황을 더 조사한다.',
      ];
    }
    return <String>[
      place.isNotEmpty ? '$place 안쪽을 천천히 살핀다.' : '주변 상황을 살핀다.',
      keyword.isNotEmpty ? '"${keyword}에 대해 묻는다."' : '"무슨 일이 있었는지 묻는다."',
      keyword.isNotEmpty ? '${keyword}와 관련된 단서를 찾는다.' : '다음 행동을 준비한다.',
    ];
  }

  String _choiceAt(int index) {
    if (index >= 0 && index < _currentChoices.length) {
      return _currentChoices[index];
    }
    final defaults = _defaultChoiceCandidates();
    if (index >= 0 && index < defaults.length) {
      return defaults[index];
    }
    return '';
  }

  String _normalizeChoiceText(String value) {
    var text = value.trim();
    if (text.isEmpty) return '';
    text = text.replaceAll(RegExp(r'^\d+\s*[\.\)]\s*'), '');
    text = text.replaceAll(RegExp(r'^[-*•]\s*'), '');
    text = text.trim();
    if (text.length > 90) {
      text = text.substring(0, 90).trim();
    }
    return text;
  }

  List<String> _parseChoicesFromAi(String rawText) {
    final fallback = _defaultChoiceCandidates();
    final choices = <String>[];

    String cleaned = rawText.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'```$'), '')
          .trim();
    }

    final normalizedError = cleaned.toLowerCase();
    if (cleaned.isEmpty ||
        normalizedError.startsWith('error:') ||
        normalizedError.contains('auth required') ||
        normalizedError.contains('firebase functions')) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is List) {
        for (final item in decoded) {
          final text = _normalizeChoiceText(item.toString());
          if (text.isNotEmpty && !choices.contains(text)) {
            choices.add(text);
          }
          if (choices.length == 3) break;
        }
      }
    } catch (_) {
      // Fallback to line parsing.
    }

    if (choices.length < 3) {
      final lineChoices = cleaned
          .split('\n')
          .map(_normalizeChoiceText)
          .where((e) => e.isNotEmpty)
          .toList();
      for (final item in lineChoices) {
        if (!choices.contains(item)) {
          choices.add(item);
        }
        if (choices.length == 3) break;
      }
    }

    for (final item in fallback) {
      final normalized = _normalizeChoiceText(item);
      if (normalized.isNotEmpty && !choices.contains(normalized)) {
        choices.add(normalized);
      }
      if (choices.length == 3) break;
    }

    while (choices.length < 3) {
      choices.add(_defaultChoices[choices.length]);
    }

    return choices.take(3).toList();
  }

  String _buildChoicePrompt(StoriesRecord story) {
    final paragraph = _paragraphs.isNotEmpty ? _paragraphs.last : null;
    final speaker = (paragraph?.speaker ?? '').trim();
    final place = (paragraph?.place ?? _currentPlace).trim();
    final sceneText = (paragraph?.text ?? '').trim();

    return '''
너는 비주얼노벨 선택지 생성기다.
아래 장면을 바탕으로 유저가 선택할 3개 선택지를 만들어라.

[규칙]
- 반드시 JSON 배열만 출력: ["...", "...", "..."]
- 배열 길이는 정확히 3개
- 각 선택지는 1문장
- 행동묘사면 일반 문장(예: 가방을 맨다.)
- 대사 선택지면 반드시 큰따옴표로 감싼다(예: "너 미친거야?")
- 장면과 개연성이 맞아야 하며 서로 다른 방향의 선택지여야 한다.
- 불필요한 설명/마크다운/코드블록 금지

[스토리]
제목: ${story.title}
세계관: ${story.worldview}
장소: $place
화자: ${speaker.isEmpty ? '내레이션' : speaker}
현재 문단: $sceneText
''';
  }

  Future<void> _refreshChoicesForCurrentTurn(
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) async {
    if (!_showActionPanel || _isGenerating || _isSubmittingSelection) return;
    final signature =
        '${valueOrDefault<int>(chatDoc.messageCount, 0)}|$_currentPlace|${_paragraphs.isNotEmpty ? _paragraphs.last.text.hashCode : 0}';
    if (_lastChoiceSignature == signature && _currentChoices.length == 3) {
      return;
    }
    _lastChoiceSignature = signature;

    final requestId = ++_choiceRequestSerial;
    safeSetState(() {
      _isChoiceLoading = true;
      _currentChoices = const [];
    });

    if (!loggedIn || currentUserReference == null) {
      if (!mounted || requestId != _choiceRequestSerial) return;
      safeSetState(() {
        _currentChoices = _defaultChoiceCandidates();
        _isChoiceLoading = false;
      });
      return;
    }

    try {
      final selectedModelId = _resolveSelectedModelId(chatDoc.selectedAiModel);
      final formattedHistory = await actions.getAndProcessHistory(
        widget.storychatRef,
      );
      final response = await actions.callAiProxy(
        selectedModelId,
        _buildChoicePrompt(story),
        formattedHistory.toList(),
        '',
      );
      final parsed = _parseChoicesFromAi((response ?? '').trim());
      if (!mounted ||
          requestId != _choiceRequestSerial ||
          !_showActionPanel ||
          _isSubmittingSelection) {
        return;
      }
      safeSetState(() {
        _currentChoices = parsed;
      });
    } catch (_) {
      if (!mounted || requestId != _choiceRequestSerial) return;
      safeSetState(() {
        _currentChoices = _defaultChoiceCandidates();
      });
    } finally {
      if (!mounted || requestId != _choiceRequestSerial) return;
      safeSetState(() {
        _isChoiceLoading = false;
      });
    }
  }

  String _buildUserInputForMode(String rawInput) {
    final raw = rawInput.trim();
    if (raw.isEmpty) return '';
    if (_isInputActionMode) return raw;
    if (raw.startsWith('"') && raw.endsWith('"')) return raw;
    return '"$raw"';
  }

  String _resolveStoryTextField(StoriesRecord story, String fieldName) {
    final dynamic raw = story.snapshotData[fieldName];
    if (raw is String) {
      return raw.trim();
    }
    return '';
  }

  String _resolveStatusSourceText(StoriesRecord story) {
    final sources = <String>[
      _resolveStoryTextField(story, 'userStateAndItemText'),
      _resolveStoryTextField(story, 'userstateanditemtextfield'),
      _resolveStoryTextField(story, 'user_state_and_item'),
      _resolveStoryTextField(story, 'charStateAndItemText'),
      _resolveStoryTextField(story, 'charstateanditemtextfield'),
      _resolveStoryTextField(story, 'char_state_and_item'),
      _resolveStoryTextField(story, 'stateRuleText'),
      _resolveStoryTextField(story, 'ruleText'),
      _resolveStoryTextField(story, 'ruletextfield'),
      _resolveStoryTextField(story, 'state_rule_text'),
      story.authorNotes.trim(),
      story.detailmode.trim(),
      story.event.trim(),
    ].where((e) => e.isNotEmpty).toList();
    return sources.join('\n\n');
  }

  bool _isUserOwnerLabel(String owner) {
    final normalized = owner.trim().toUpperCase();
    return normalized == 'USER' || owner.trim() == '유저';
  }

  int _parseIntValue(dynamic raw) => int.tryParse(raw?.toString() ?? '') ?? 0;

  String _normalizeIncreaseOrDecrease(String raw) =>
      raw.trim() == '감소' ? '감소' : '증가';

  String _normalizeOperatorValue(String raw) {
    switch (raw.trim()) {
      case '=':
      case '>':
      case '<':
      case '≥':
      case '≤':
        return raw.trim();
      case '>=':
        return '≥';
      case '<=':
        return '≤';
      default:
        return '=';
    }
  }

  _RuntimeResourceCard? _parseRuntimeResourceCard(dynamic rawCard) {
    if (rawCard is! Map) return null;
    final card = rawCard.map((key, value) => MapEntry(key.toString(), value));
    final owner = (card['charOrUser'] ?? '').toString().trim();
    final rawItems = card['items'];

    final items = <_RuntimeResourceItem>[];
    if (rawItems is List) {
      for (final rawItem in rawItems) {
        if (rawItem is! Map) continue;
        final item =
            rawItem.map((key, value) => MapEntry(key.toString(), value));
        final kind = (item['kind'] ?? 'stat').toString().trim().toLowerCase();
        final normalizedKind = kind == 'item' ? 'item' : 'stat';
        final name = (item['resourceName'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        items.add(
          _RuntimeResourceItem(
            kind: normalizedKind,
            resourceName: name,
            currentValue: _parseIntValue(item['firstValue']),
            increaseOrDecrease: _normalizeIncreaseOrDecrease(
              (item['increaseOrDecrease'] ??
                      item['increaseORdecreaseValue'] ??
                      item['deltaMode'] ??
                      '')
                  .toString(),
            ),
            deltaValue: _parseIntValue(item['deltaValue']),
            condition: (item['condition'] ?? '').toString().trim(),
            operatorValue: _normalizeOperatorValue(
              (item['operatorValue'] ?? item['operator'] ?? '=').toString(),
            ),
            referenceValue: _parseIntValue(item['referenceValue']),
            effect: (item['effect'] ?? '').toString().trim(),
          ),
        );
      }
    }

    return _RuntimeResourceCard(owner: owner, items: items);
  }

  List<_RuntimeResourceCard> _extractRuntimeResourceCards(StoriesRecord story) {
    final parsed = <_RuntimeResourceCard>[];
    final rawCards = story.resourceCards;
    for (final rawCard in rawCards) {
      final card = _parseRuntimeResourceCard(rawCard);
      if (card != null) parsed.add(card);
    }
    return parsed;
  }

  _RuntimeResourceCard? _pickRuntimeUserCard(List<_RuntimeResourceCard> cards) {
    for (final card in cards) {
      if (_isUserOwnerLabel(card.owner)) return card;
    }
    return null;
  }

  _RuntimeResourceCard? _pickRuntimeCharacterCard(
    List<_RuntimeResourceCard> cards, {
    String? currentSpeaker,
  }) {
    final characterCards =
        cards.where((card) => !_isUserOwnerLabel(card.owner)).toList();
    if (characterCards.isEmpty) return null;

    final speaker = (currentSpeaker ?? '').trim();
    if (speaker.isNotEmpty) {
      for (final card in characterCards) {
        if (card.owner.trim() == speaker) return card;
      }
    }
    return characterCards.first;
  }

  void _initializeRuntimeResourcesIfNeeded(StoriesRecord story) {
    if (_runtimeResourcesInitialized) return;
    _runtimeResourceCards = _extractRuntimeResourceCards(story);
    _runtimeResourcesInitialized = true;
  }

  List<_StatusValue> _statusValuesForKind(
    _RuntimeResourceCard? card, {
    required String kind,
  }) {
    if (card == null) {
      return kind == 'item'
          ? const [_StatusValue(name: '표시할 아이템 없음', value: '-')]
          : const [_StatusValue(name: '표시할 스탯 없음', value: '-')];
    }

    final values = card.items
        .where((item) => item.kind == kind)
        .map(
          (item) => _StatusValue(
            name: item.resourceName,
            value: kind == 'item'
                ? 'x${item.currentValue}'
                : item.currentValue.toString(),
          ),
        )
        .toList();

    if (values.isEmpty) {
      return kind == 'item'
          ? const [_StatusValue(name: '표시할 아이템 없음', value: '-')]
          : const [_StatusValue(name: '표시할 스탯 없음', value: '-')];
    }
    return values;
  }

  void _refreshStatusPanelFromRuntime({
    String? currentSpeaker,
  }) {
    if (_runtimeResourceCards.isEmpty) return;

    final userCard = _pickRuntimeUserCard(_runtimeResourceCards);
    final characterCard = _pickRuntimeCharacterCard(
      _runtimeResourceCards,
      currentSpeaker: currentSpeaker,
    );

    _userStatusValues = _statusValuesForKind(userCard, kind: 'stat');
    _userItemValues = _statusValuesForKind(userCard, kind: 'item');

    _characterPanelTitle = (characterCard?.owner ?? '').trim();
    if (characterCard == null) {
      _characterStatusValues = const [];
      _characterItemValues = const [];
      return;
    }
    _characterStatusValues = _statusValuesForKind(characterCard, kind: 'stat');
    _characterItemValues = _statusValuesForKind(characterCard, kind: 'item');
  }

  String _extractSectionBody(String source, String sectionTitle) {
    final exp = RegExp(
      '\\[${RegExp.escape(sectionTitle)}\\]\\s*([\\s\\S]*?)(?=\\n\\s*\\[[^\\]]+\\]|\$)',
      multiLine: true,
    );
    final match = exp.firstMatch(source);
    return (match?.group(1) ?? '').trim();
  }

  List<_StatusValue> _parseUserStats(String source) {
    final section = _extractSectionBody(source, '유저 스탯');
    if (section.isEmpty) return const [];

    final values = <_StatusValue>[];
    final lines = section.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final match = RegExp(
        r'^(.+?)\s*=\s*([+-]?\d+)\s*(?:\(([^)]*)\))?\s*$',
      ).firstMatch(trimmed);
      if (match == null) continue;
      final name = (match.group(1) ?? '').trim();
      final number = (match.group(2) ?? '').trim();
      final range = (match.group(3) ?? '').trim();
      if (name.isEmpty || number.isEmpty) continue;
      values.add(
        _StatusValue(
          name: name,
          value: range.isEmpty ? number : '$number ($range)',
        ),
      );
    }
    return values;
  }

  List<_StatusValue> _parseUserItems(String source) {
    final section = _extractSectionBody(source, '유저 아이템');
    if (section.isEmpty) return const [];

    final values = <_StatusValue>[];
    final lines = section.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final match = RegExp(r'^(.+?)\s*[xX]\s*(\d+)\s*$').firstMatch(trimmed);
      if (match == null) continue;
      final name = (match.group(1) ?? '').trim();
      final count = (match.group(2) ?? '').trim();
      if (name.isEmpty || count.isEmpty) continue;
      values.add(_StatusValue(name: name, value: 'x$count'));
    }
    return values;
  }

  void _refreshStatusPanelData(
    StoriesRecord story, {
    String? currentSpeaker,
  }) {
    _initializeRuntimeResourcesIfNeeded(story);
    if (_runtimeResourceCards.isNotEmpty) {
      _refreshStatusPanelFromRuntime(currentSpeaker: currentSpeaker);
      return;
    }

    final source = _resolveStatusSourceText(story);
    final stats = _parseUserStats(source);
    final items = _parseUserItems(source);
    _userStatusValues = stats.isEmpty
        ? const [_StatusValue(name: '표시할 스탯 없음', value: '-')]
        : stats;
    _userItemValues = items.isEmpty
        ? const [_StatusValue(name: '표시할 아이템 없음', value: '-')]
        : items;
    _characterPanelTitle = '';
    _characterStatusValues = const [];
    _characterItemValues = const [];
  }

  int _indexOfRuntimeUserCard(List<_RuntimeResourceCard> cards) {
    for (var i = 0; i < cards.length; i++) {
      if (_isUserOwnerLabel(cards[i].owner)) {
        return i;
      }
    }
    return -1;
  }

  int _indexOfRuntimeCharacterCard(
    List<_RuntimeResourceCard> cards, {
    String? currentSpeaker,
  }) {
    final speaker = (currentSpeaker ?? '').trim();
    if (speaker.isNotEmpty) {
      for (var i = 0; i < cards.length; i++) {
        final card = cards[i];
        if (_isUserOwnerLabel(card.owner)) continue;
        if (card.owner.trim() == speaker) return i;
      }
    }
    for (var i = 0; i < cards.length; i++) {
      if (!_isUserOwnerLabel(cards[i].owner)) return i;
    }
    return -1;
  }

  bool _containsConditionText(String source, String condition) {
    final trimmedCondition = condition.trim();
    if (trimmedCondition.isEmpty) return false;
    if (source.contains(trimmedCondition)) return true;
    return source.toLowerCase().contains(trimmedCondition.toLowerCase());
  }

  bool _matchesReference({
    required int value,
    required String operatorValue,
    required int referenceValue,
  }) {
    final op = _normalizeOperatorValue(operatorValue);
    switch (op) {
      case '=':
        return value == referenceValue;
      case '>':
        return value > referenceValue;
      case '<':
        return value < referenceValue;
      case '≥':
        return value >= referenceValue;
      case '≤':
        return value <= referenceValue;
      default:
        return value == referenceValue;
    }
  }

  String _extractPrimarySpeakerFromScenes(List<Map<String, dynamic>> scenes) {
    for (final scene in scenes) {
      if ((scene['type'] ?? '').toString().trim() != 'dialogue') continue;
      final speaker = (scene['speaker'] ?? '').toString().trim();
      if (speaker.isNotEmpty) return speaker;
    }
    return '';
  }

  String _buildRuleEvaluationText({
    required String userText,
    required String aiRawText,
    required List<Map<String, dynamic>> scenes,
  }) {
    final aiSceneText = scenes
        .where((scene) {
          final type = (scene['type'] ?? '').toString().trim();
          return type == 'narration' || type == 'dialogue';
        })
        .map((scene) => (scene['content'] ?? '').toString().trim())
        .where((text) => text.isNotEmpty)
        .join('\n');

    return <String>[userText.trim(), aiRawText.trim(), aiSceneText.trim()]
        .where((part) => part.isNotEmpty)
        .join('\n');
  }

  List<String> _applyRulesToRuntimeCardAt(
    List<_RuntimeResourceCard> cards,
    int cardIndex, {
    required String evaluationText,
  }) {
    if (cardIndex < 0 || cardIndex >= cards.length) return const [];
    final card = cards[cardIndex];
    if (card.items.isEmpty) return const [];

    final updatedItems = <_RuntimeResourceItem>[];
    final effects = <String>[];

    for (final item in card.items) {
      final condition = item.condition.trim();
      if (condition.isEmpty ||
          !_containsConditionText(evaluationText, condition)) {
        updatedItems.add(item);
        continue;
      }

      final previousValue = item.currentValue;
      final delta = item.deltaValue;
      if (delta <= 0) {
        updatedItems.add(item);
        continue;
      }

      print(
        '[RESOURCE_RULE_MATCH] owner=${card.owner} resource=${item.resourceName} condition="${item.condition}"',
      );

      final nextValue =
          _normalizeIncreaseOrDecrease(item.increaseOrDecrease) == '감소'
              ? previousValue - delta
              : previousValue + delta;

      final beforeMatched = _matchesReference(
        value: previousValue,
        operatorValue: item.operatorValue,
        referenceValue: item.referenceValue,
      );
      final afterMatched = _matchesReference(
        value: nextValue,
        operatorValue: item.operatorValue,
        referenceValue: item.referenceValue,
      );

      updatedItems.add(item.copyWith(currentValue: nextValue));

      if (!beforeMatched && afterMatched && item.effect.trim().isNotEmpty) {
        print(
          '[RESOURCE_EFFECT_TRIGGER] owner=${card.owner} resource=${item.resourceName} value=$nextValue op=${item.operatorValue} ref=${item.referenceValue} effect="${item.effect}"',
        );
        effects.add(item.effect.trim());
      }
    }

    cards[cardIndex] = _RuntimeResourceCard(
      owner: card.owner,
      items: updatedItems,
    );
    return effects;
  }

  void _showEffectMessage(List<String> effects) {
    if (effects.isEmpty) return;
    final uniqueEffects = effects
        .map((effect) => effect.trim())
        .where((effect) => effect.isNotEmpty)
        .toSet()
        .toList();
    if (uniqueEffects.isEmpty) return;

    final message = uniqueEffects.map((effect) => '효과: $effect').join('\n');
    final media = MediaQuery.of(context);
    final centerBottomMargin = (media.size.height * 0.45).clamp(120.0, 420.0);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xE0000000),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          24.0,
          0.0,
          24.0,
          centerBottomMargin,
        ),
      ),
    );
  }

  void _applyResourceRulesForTurn({
    required StoriesRecord story,
    required String userText,
    required String aiRawText,
    required List<Map<String, dynamic>> scenes,
    String? currentSpeaker,
  }) {
    _initializeRuntimeResourcesIfNeeded(story);
    if (_runtimeResourceCards.isEmpty) return;

    final evaluationText = _buildRuleEvaluationText(
      userText: userText,
      aiRawText: aiRawText,
      scenes: scenes,
    );
    if (evaluationText.trim().isEmpty) return;

    final workingCards = _runtimeResourceCards.toList();
    final targets = <int>{};

    final userIndex = _indexOfRuntimeUserCard(workingCards);
    if (userIndex >= 0) targets.add(userIndex);

    final characterIndex = _indexOfRuntimeCharacterCard(
      workingCards,
      currentSpeaker: currentSpeaker,
    );
    if (characterIndex >= 0) targets.add(characterIndex);

    if (targets.isEmpty) return;

    final triggeredEffects = <String>[];
    for (final index in targets) {
      triggeredEffects.addAll(
        _applyRulesToRuntimeCardAt(
          workingCards,
          index,
          evaluationText: evaluationText,
        ),
      );
    }

    _runtimeResourceCards = workingCards;
    _refreshStatusPanelFromRuntime(currentSpeaker: currentSpeaker);
    if (triggeredEffects.isNotEmpty) {
      _showEffectMessage(triggeredEffects);
    }
  }

  Widget _buildFirstEnterCover(BuildContext context) {
    return Opacity(
      opacity: 0.7,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700.0;
            final iconSize = isCompact ? 96.0 : 150.0;
            final fontSize = isCompact ? 18.0 : 36.0;
            final spacing = isCompact ? 40.0 : 80.0;

            Widget buildGuide({
              required IconData icon,
              required String text,
            }) {
              return Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: FlutterFlowTheme.of(context).primary,
                      size: iconSize,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            fontSize: fontSize,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 32.0 : 48.0,
                vertical: 32.0,
              ),
              child: Center(
                child: isCompact
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildGuide(
                            icon: Icons.keyboard_double_arrow_left,
                            text: '화면의 왼쪽을 클릭하면\n이전으로 돌아갑니다.',
                          ),
                          SizedBox(height: spacing),
                          buildGuide(
                            icon: Icons.keyboard_double_arrow_right,
                            text: '화면의 오른쪽을 클릭하면\n다음으로 넘어갑니다.',
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildGuide(
                            icon: Icons.keyboard_double_arrow_left,
                            text: '화면의 왼쪽을 클릭하면\n이전으로 돌아갑니다.',
                          ),
                          SizedBox(width: spacing),
                          buildGuide(
                            icon: Icons.keyboard_double_arrow_right,
                            text: '화면의 오른쪽을 클릭하면\n다음으로 넘어갑니다.',
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusValuesColumn({
    required BuildContext context,
    required String title,
    required Color titleColor,
    required List<_StatusValue> values,
  }) {
    return SizedBox(
      width: 150.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
            child: Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: titleColor,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                final item = values[index];
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).tertiary,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection({
    required BuildContext context,
    required String title,
    required List<_StatusValue> stats,
    required List<_StatusValue> items,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          child: Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).warning,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
        ),
        Divider(
          thickness: 1.0,
          color: FlutterFlowTheme.of(context).alternate,
        ),
        SizedBox(
          height: 170.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusValuesColumn(
                context: context,
                title: '스탯',
                titleColor: const Color(0xFF8B97FF),
                values: stats,
              ),
              _buildStatusValuesColumn(
                context: context,
                title: '아이템',
                titleColor: const Color(0xFF0BEF44),
                values: items,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPanel(BuildContext context) {
    final hasCharacterSection = _characterPanelTitle.trim().isNotEmpty;
    return Opacity(
      opacity: 0.7,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(25.0, 40.0, 25.0, 0.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(15.0, 15.0, 15.0, 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasCharacterSection) ...[
                  _buildStatusSection(
                    context: context,
                    title: _characterPanelTitle,
                    stats: _characterStatusValues,
                    items: _characterItemValues,
                  ),
                  const SizedBox(height: 8.0),
                ],
                _buildStatusSection(
                  context: context,
                  title: '유저',
                  stats: _userStatusValues,
                  items: _userItemValues,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitWithSelectionAnimation({
    required String submitValue,
    required String previewValue,
    required int sourceIndex,
    required StoriesRecord story,
    required StorychatsRecord chatDoc,
  }) async {
    final input = submitValue.trim();
    if (input.isEmpty) {
      _showMessage('메시지를 입력해주세요.');
      return;
    }
    if (_isGenerating || _isSubmittingSelection) return;

    safeSetState(() {
      _isSubmittingSelection = true;
      _submittedPreviewText =
          previewValue.trim().isEmpty ? input : previewValue;
      _submittedPreviewOffsetY = sourceIndex.toDouble();
      _isChoiceLoading = false;
      _choiceRequestSerial++;
    });

    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted) return;
    safeSetState(() {
      _submittedPreviewOffsetY = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    safeSetState(() {
      _showActionPanel = false;
      _isSubmittingSelection = false;
      _submittedPreviewText = '';
      _submittedPreviewOffsetY = 0.0;
    });

    await _requestNextTurn(
      input,
      story,
      chatDoc,
    );

    if (!mounted) return;
    safeSetState(() {
      _model.usertextFieldTextController?.clear();
    });
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
      final url =
          functions.stringToImagePath((place.imageUrl).toString()).trim();
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
      final url =
          functions.stringToImagePath((event.imageurl).toString()).trim();
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
        final url =
            functions.stringToImagePath((emotion.imageurl).toString()).trim();
        if (url.isNotEmpty) {
          emotionUrl = url;
          break;
        }
      }
    }

    if (emotionUrl != null && emotionUrl.isNotEmpty) return emotionUrl;

    for (final emotion in character.emotionStruct) {
      final url =
          functions.stringToImagePath((emotion.imageurl).toString()).trim();
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
        final condition =
            _normalizeImageTag((scene['condition'] ?? '').toString());
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
      _isChoiceLoading = false;
      _isSubmittingSelection = false;
      _submittedPreviewText = '';
      _submittedPreviewOffsetY = 0.0;
      _currentChoices = const [];
      _choiceRequestSerial++;
      _lastChoiceSignature = '';
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
        final imageUrl = functions
            .stringToImagePath((message.storyImageUrl).toString())
            .trim();
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
      _isChoiceLoading = false;
      _isSubmittingSelection = false;
      _submittedPreviewText = '';
      _submittedPreviewOffsetY = 0.0;
      _currentChoices = const [];
      _choiceRequestSerial++;
      _lastChoiceSignature = '';
    });
  }

  void _onTapPrevious() {
    if (_isGenerating || _paragraphs.isEmpty || _isSubmittingSelection) return;

    safeSetState(() {
      if (_showActionPanel) {
        _showActionPanel = false;
        _isChoiceLoading = false;
        _choiceRequestSerial++;
        return;
      }

      if (_currentParagraphIndex > 0) {
        _currentParagraphIndex--;
      }
    });
  }

  Future<void> _onTapNext(
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) async {
    if (_isGenerating || _paragraphs.isEmpty || _isSubmittingSelection) return;

    safeSetState(() {
      if (_showActionPanel) return;

      if (_currentParagraphIndex < _paragraphs.length - 1) {
        _currentParagraphIndex++;
      } else {
        _showActionPanel = true;
        _currentChoices = const [];
        _isChoiceLoading = false;
      }
    });

    if (_showActionPanel) {
      await _refreshChoicesForCurrentTurn(story, chatDoc);
    }
  }

  Future<void> _requestNextTurn(
    String userInput,
    StoriesRecord story,
    StorychatsRecord chatDoc,
  ) async {
    if (_isGenerating) return;

    if (!loggedIn || currentUserReference == null) {
      final didLogin = await _showLoginSheet();
      if (!didLogin || !loggedIn || currentUserReference == null) {
        return;
      }
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
      final sceneSpeaker = _extractPrimarySpeakerFromScenes(scenes);
      final runtimeSpeaker = sceneSpeaker.isNotEmpty
          ? sceneSpeaker
          : (_paragraphs.isNotEmpty
              ? _paragraphs[_currentParagraphIndex].speaker
              : '');

      _applyResourceRulesForTurn(
        story: story,
        userText: userInput,
        aiRawText: aiRawText,
        scenes: scenes,
        currentSpeaker: runtimeSpeaker,
      );

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
      final didLogin = await _showLoginSheet();
      if (!didLogin || !loggedIn || currentUserReference == null) {
        return;
      }
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
                  final hasReadyChoices = _showActionPanel &&
                      !_isSubmittingSelection &&
                      !_isChoiceLoading &&
                      _currentChoices.length == 3;
                  final choice1 = hasReadyChoices ? _choiceAt(0) : '';
                  final choice2 = hasReadyChoices ? _choiceAt(1) : '';
                  final choice3 = hasReadyChoices ? _choiceAt(2) : '';
                  final topTitle = visualnovelpageStoriesRecord.title;
                  final topPlace =
                      (currentParagraph?.place ?? _currentPlace).trim();
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
                  _refreshStatusPanelData(
                    visualnovelpageStoriesRecord,
                    currentSpeaker: currentParagraph?.speaker,
                  );

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
                      if (_showActionPanel &&
                          !_isGenerating &&
                          !_isSubmittingSelection &&
                          !_isChoiceLoading) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          if (!mounted) return;
                          await _refreshChoicesForCurrentTurn(
                            visualnovelpageStoriesRecord,
                            visualChatDoc,
                          );
                        });
                      }

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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 50.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (hasReadyChoices || _isSubmittingSelection)
                                  Stack(
                                    children: [
                                      Opacity(
                                        opacity: 0.5,
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
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
                                                begin: AlignmentDirectional(
                                                    1.0, 0.0),
                                                end: AlignmentDirectional(
                                                    -1.0, 0),
                                              ),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(0.0),
                                                bottomRight:
                                                    Radius.circular(0.0),
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
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (!_showActionPanel ||
                                                  _isSubmittingSelection ||
                                                  _isChoiceLoading) return;
                                              await _submitWithSelectionAnimation(
                                                submitValue: choice1,
                                                previewValue: choice1,
                                                sourceIndex: 0,
                                                story:
                                                    visualnovelpageStoriesRecord,
                                                chatDoc: visualChatDoc,
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 0.0, 20.0, 0.0),
                                              child: AnimatedSlide(
                                                duration: const Duration(
                                                    milliseconds: 260),
                                                curve: Curves.easeOutCubic,
                                                offset: Offset(
                                                  0.0,
                                                  _isSubmittingSelection
                                                      ? _submittedPreviewOffsetY
                                                      : 0.0,
                                                ),
                                                child: AutoSizeText(
                                                  _isSubmittingSelection
                                                      ? _submittedPreviewText
                                                      : (hasReadyChoices
                                                          ? choice1
                                                          : ''),
                                                  maxLines: 3,
                                                  textAlign: TextAlign.center,
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
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (hasReadyChoices)
                                  Stack(
                                    children: [
                                      Opacity(
                                        opacity: 0.5,
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
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
                                                begin: AlignmentDirectional(
                                                    1.0, 0.0),
                                                end: AlignmentDirectional(
                                                    -1.0, 0),
                                              ),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(0.0),
                                                bottomRight:
                                                    Radius.circular(0.0),
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
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (!_showActionPanel ||
                                                  _isSubmittingSelection ||
                                                  _isChoiceLoading) return;
                                              await _submitWithSelectionAnimation(
                                                submitValue: choice2,
                                                previewValue: choice2,
                                                sourceIndex: 1,
                                                story:
                                                    visualnovelpageStoriesRecord,
                                                chatDoc: visualChatDoc,
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 0.0, 20.0, 0.0),
                                              child: AutoSizeText(
                                                choice2,
                                                maxLines: 3,
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
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (hasReadyChoices)
                                  Stack(
                                    children: [
                                      Opacity(
                                        opacity: 0.5,
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
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
                                                begin: AlignmentDirectional(
                                                    1.0, 0.0),
                                                end: AlignmentDirectional(
                                                    -1.0, 0),
                                              ),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(0.0),
                                                bottomRight:
                                                    Radius.circular(0.0),
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
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if (!_showActionPanel ||
                                                  _isSubmittingSelection ||
                                                  _isChoiceLoading) return;
                                              await _submitWithSelectionAnimation(
                                                submitValue: choice3,
                                                previewValue: choice3,
                                                sourceIndex: 2,
                                                story:
                                                    visualnovelpageStoriesRecord,
                                                chatDoc: visualChatDoc,
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 0.0, 20.0, 0.0),
                                              child: AutoSizeText(
                                                choice3,
                                                maxLines: 3,
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
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (hasReadyChoices)
                                  Stack(
                                    children: [
                                      Opacity(
                                        opacity: 0.3,
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
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
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          10.0, 0.0, 6.0, 0.0),
                                                  child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      safeSetState(() {
                                                        _isInputActionMode =
                                                            !_isInputActionMode;
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.change_circle,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 22.0,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    child: TextFormField(
                                                      controller: _model
                                                          .usertextFieldTextController,
                                                      focusNode: _model
                                                          .usertextFieldFocusNode,
                                                      autofocus: false,
                                                      enabled: true,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        isDense: true,
                                                        labelStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                        hintText: _isInputActionMode
                                                            ? '당신의 행동을 입력하세요.'
                                                            : '당신의 대사를 입력하세요.',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                      ),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                                                    .secondaryBackground,
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
                                                      maxLines: null,
                                                      minLines: 1,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      enableInteractiveSelection:
                                                          true,
                                                      onFieldSubmitted:
                                                          (_) async {
                                                        final typedRaw = _model
                                                                .usertextFieldTextController
                                                                ?.text ??
                                                            '';
                                                        final submitText =
                                                            _buildUserInputForMode(
                                                                typedRaw);
                                                        await _submitWithSelectionAnimation(
                                                          submitValue:
                                                              submitText,
                                                          previewValue:
                                                              typedRaw.trim(),
                                                          sourceIndex: 3,
                                                          story:
                                                              visualnovelpageStoriesRecord,
                                                          chatDoc:
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
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          10.0, 0.0, 0.0, 0.0),
                                                  child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      final typedRaw = _model
                                                              .usertextFieldTextController
                                                              ?.text ??
                                                          '';
                                                      final submitText =
                                                          _buildUserInputForMode(
                                                              typedRaw);
                                                      await _submitWithSelectionAnimation(
                                                        submitValue: submitText,
                                                        previewValue:
                                                            typedRaw.trim(),
                                                        sourceIndex: 3,
                                                        story:
                                                            visualnovelpageStoriesRecord,
                                                        chatDoc: visualChatDoc,
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.send,
                                                      color: FlutterFlowTheme
                                                              .of(context)
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
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
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
                                            if (speakerText.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 0.0, 10.0),
                                                child: Text(
                                                  speakerText,
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
                                            Expanded(
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, -1.0),
                                                child: AutoSizeText(
                                                  dialogueText,
                                                  maxLines: 7,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                        color: (currentParagraph
                                                                    ?.isNarration ??
                                                                true)
                                                            ? Color(0xFFE0E3E7)
                                                            : Color(0xFFFFFFFF),
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
                            bottom: (_showActionPanel ||
                                    _isSubmittingSelection ||
                                    _isChoiceLoading)
                                ? 340.0
                                : 0.0,
                            child: IgnorePointer(
                              ignoring: _isGenerating ||
                                  _showActionPanel ||
                                  _isSubmittingSelection,
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
                                      onTap: () async {
                                        await _onTapNext(
                                          visualnovelpageStoriesRecord,
                                          visualChatDoc,
                                        );
                                      },
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 8.0),
                                              child: Text(
                                                topTitle,
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
                                                              .secondaryBackground,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                              topPlace.isEmpty
                                                  ? '어딘가'
                                                  : topPlace,
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                                .warning,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 22.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 10.0, 0.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  safeSetState(() {
                                                    _showStatusPanel =
                                                        !_showStatusPanel;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons
                                                      .auto_awesome_mosaic_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 22.0,
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
                                                scaffoldKey.currentState!
                                                    .openEndDrawer();
                                              },
                                              child: Icon(
                                                Icons.menu,
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                          if (_showStatusPanel)
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  safeSetState(() {
                                    _showStatusPanel = false;
                                  });
                                },
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {},
                                    child: _buildStatusPanel(context),
                                  ),
                                ),
                              ),
                            ),
                          if (_showFirstEnterCover)
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  safeSetState(() {
                                    _showFirstEnterCover = false;
                                  });
                                },
                                child: _buildFirstEnterCover(context),
                              ),
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
