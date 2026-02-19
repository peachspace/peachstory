// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart'; // Imports other custom actions

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/scheduler.dart';
import '/auth/firebase_auth/auth_util.dart';

class NotifierChatList extends StatefulWidget {
  const NotifierChatList({
    super.key,
    this.width,
    this.height,
    this.initialMessages,
    required this.newResponseScript,
    this.userInChatName,
    this.preDefinedCharacters,
    this.backgroundList,
    this.onTurnComplete,
    this.onLoadOlderMessages,
    this.isNovelMode,
  });

  final double? width;
  final double? height;
  final List<StoryChatMessageStructStruct>? initialMessages;
  final String newResponseScript;
  final String? userInChatName;

  // ✅ Character list
  final List<CharacterStructStruct>? preDefinedCharacters;

  // ✅ backgroundList 타입을 PlaceStructStruct로 고정
  final List<PlaceStructStruct>? backgroundList;

  final Future<dynamic> Function(List<dynamic>? scenes)? onTurnComplete;
  final Future<dynamic> Function()? onLoadOlderMessages;
  final bool? isNovelMode;

  @override
  State<NotifierChatList> createState() => _NotifierChatListState();
}

class _NotifierChatListState extends State<NotifierChatList>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<List<StoryChatMessageStructStruct>> _messagesNotifier;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _scenes = [];
  int _currentSceneIndex = 0;
  bool _isTyping = false;
  bool _isLoadingHistory = false;

  String? _lastShownImageUrl;

  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  // ✅ 감정 7개만 허용
  final Set<String> _allowedEmotions = const {
    '무감정',
    '기쁨',
    '슬픔',
    '혐오',
    '두려움',
    '놀람',
    '분노',
  };

  String _normalizeEmotionKey(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '무감정';
    if (_allowedEmotions.contains(r)) return r;

    final compact = r.replaceAll(' ', '');

    if (compact.contains('공포') || compact.contains('두려')) return '두려움';
    if (compact.contains('화') ||
        compact.contains('분노') ||
        compact.contains('화남')) return '분노';
    if (compact.contains('혐오') ||
        compact.contains('역겹') ||
        compact.contains('메스꺼')) return '혐오';
    if (compact.contains('놀라') || compact.contains('경악')) return '놀람';
    if (compact.contains('기쁘') ||
        compact.contains('행복') ||
        compact.contains('웃')) return '기쁨';
    if (compact.contains('슬프') ||
        compact.contains('울') ||
        compact.contains('눈물')) return '슬픔';

    return '무감정';
  }

  @override
  void initState() {
    super.initState();
    _messagesNotifier = ValueNotifier(List.from(widget.initialMessages ?? []));

    if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
      for (var msg in widget.initialMessages!.reversed) {
        if (msg.type == 'story_image' &&
            (msg.storyImageUrl ?? '').toString().isNotEmpty) {
          _lastShownImageUrl = msg.storyImageUrl;
          break;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());

    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.position.atEdge &&
          _scrollController.position.pixels <= 0) {
        if (widget.onLoadOlderMessages != null && !_isLoadingHistory) {
          _isLoadingHistory = true;
          widget.onLoadOlderMessages!().then((_) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) _isLoadingHistory = false;
            });
          });
        }
      }
    });

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _loadingAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant NotifierChatList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialMessages != null && !_isTyping) {
      final parentList = widget.initialMessages!;
      final currentList = _messagesNotifier.value;
      bool shouldUpdate = false;

      bool isThinking = currentList.isNotEmpty &&
          (currentList.last.type == 'thinking' ||
              currentList.last.text == '생각 중');

      if (parentList.length < currentList.length && !isThinking) {
        return;
      }

      if (parentList.length != currentList.length) {
        shouldUpdate = true;
      } else if (parentList.isNotEmpty && currentList.isNotEmpty) {
        final p = parentList.last;
        final c = currentList.last;
        if (p.text != c.text ||
            p.type != c.type ||
            p.storyImageUrl != c.storyImageUrl) {
          shouldUpdate = true;
        }
      }

      if (shouldUpdate) {
        bool addedAtBottom = false;
        if (parentList.isNotEmpty) {
          if (currentList.isEmpty) {
            addedAtBottom = true;
          } else {
            if (parentList.last.text != currentList.last.text) {
              addedAtBottom = true;
            }
          }
        }

        _messagesNotifier.value = List.from(parentList);

        if (parentList.isNotEmpty && parentList.last.type == 'story_image') {
          _lastShownImageUrl = parentList.last.storyImageUrl;
        }

        if (addedAtBottom || _isTyping) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
        }
      }
    }

    if (widget.newResponseScript != oldWidget.newResponseScript &&
        widget.newResponseScript.isNotEmpty &&
        widget.newResponseScript != '""' &&
        !widget.newResponseScript.contains("BLOCKED_CONTENT")) {
      if (_isTyping) return;

      final currentList =
          List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
      if (currentList.isNotEmpty && currentList.last.type == 'thinking') {
        currentList.removeLast();
        _messagesNotifier.value = currentList;
      }

      SchedulerBinding.instance.addPostFrameCallback((_) => _startDirecting());
    }
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    _scrollController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _startDirecting() {
    if (!mounted) return;
    setState(() => _isTyping = true);

    String script = widget.newResponseScript
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    _scenes = [];

    try {
      int bracketIndex = script.indexOf('[');
      if (bracketIndex != -1) {
        String jsonPart = script.substring(bracketIndex).trim();
        try {
          int lastBracket = jsonPart.lastIndexOf(']');
          if (lastBracket != -1)
            jsonPart = jsonPart.substring(0, lastBracket + 1);
          final dynamic decoded = jsonDecode(jsonPart);
          if (decoded is List) _scenes = decoded;
        } catch (_) {}
      }
      if (_scenes.isEmpty) _scenes = _parseScriptIntoScenes(script);
    } catch (e) {
      _scenes = _parseScriptIntoScenes(script);
    }

    if (_scenes.isEmpty && script.isNotEmpty) {
      _scenes.add({"type": "narration", "content": script});
    }

    _currentSceneIndex = 0;
    _processNextScene();
  }

  void _processNextScene() async {
    if (!mounted || _currentSceneIndex >= _scenes.length) {
      setState(() => _isTyping = false);
      if (widget.onTurnComplete != null) await widget.onTurnComplete!(_scenes);
      _animateToBottom();
      return;
    }

    final scene = _scenes[_currentSceneIndex];
    _currentSceneIndex++;
    final type = scene['type'] ?? 'narration';
    _jumpToBottom();

    if (type == 'turn_header') {
      final headerText = (scene['content'] ?? '').toString();

      final headerMessage = createStoryChatMessageStructStruct(
        type: 'turn_header',
        text: headerText,
        isStreaming: false,
        speakerName: '',
        actionText: '',
        storyImageUrl: '',
      );

      _messagesNotifier.value = [..._messagesNotifier.value, headerMessage];
      _jumpToBottom();

      await Future.delayed(const Duration(milliseconds: 60));
      _processNextScene();
      return;
    }

    if (type == 'show_image') {
      final condition = (scene['condition'] ?? '').toString();
      final imageUrl = _findSituationalImageUrlByCondition(condition);

      if (imageUrl.isNotEmpty && imageUrl != 'null') {
        if (imageUrl != _lastShownImageUrl) {
          final imageMessage = createStoryChatMessageStructStruct(
            type: 'story_image',
            storyImageUrl: imageUrl,
            isStreaming: false,
            text: '',
            speakerName: '',
            actionText: '',
          );
          _messagesNotifier.value = [..._messagesNotifier.value, imageMessage];

          _lastShownImageUrl = imageUrl;

          _jumpToBottom();
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
      _processNextScene();
    } else if (type == 'narration' || type == 'dialogue') {
      await _animateTextScene(scene);
      if (mounted) _processNextScene();
    } else {
      _processNextScene();
    }
  }

  // ✅ 장소 단독 태그(place) + 조합 태그(place__tag) 둘 다 지원
  String _findSituationalImageUrlByCondition(String condition) {
    final target = condition.trim();
    if (target.isEmpty) return '';

    // 1) 배경(장소 단독 태그)
    final bgList = widget.backgroundList ?? [];
    for (final bg in bgList) {
      if ((bg.place).toString().trim() == target) {
        return (bg.imageUrl).toString().trim();
      }
    }

    // 2) 조합 태그: PLACE__TAG (능력/감정)
    if (target.contains('__')) {
      final charList = widget.preDefinedCharacters ?? [];
      for (final char in charList) {
        // 능력 조합: abilityStruct(place + ability)
        for (final a in (char.abilityStruct ?? <AbilityStructStruct>[])) {
          final key =
              '${(a.place).toString().trim()}__${(a.ability).toString().trim()}';
          if (key == target) return (a.imageUrl).toString().trim();
        }

        // 감정 조합: emotionStruct(place + emotion)
        for (final e in (char.emotionStruct ?? <EmotionStructStruct>[])) {
          final key =
              '${(e.place).toString().trim()}__${(e.emotion).toString().trim()}';
          if (key == target) return (e.imageurl).toString().trim();
        }
      }
    }

    return '';
  }

  Future<void> _animateTextScene(dynamic scene) async {
    final String speaker = (scene['speaker'] ?? '').toString();
    final String action = (scene['action'] ?? '').toString();

    final String fixedImageUrl =
        _resolveCharacterImageUrl(speaker, action) ?? '';

    final placeholder = _createStructFromScene(scene, '', true, fixedImageUrl);
    if (placeholder == null) return;

    _messagesNotifier.value = [..._messagesNotifier.value, placeholder];
    _jumpToBottom();

    final String content = (scene['content'] ?? '').toString();

    for (int i = 0; i <= content.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 10));
      final currentList =
          List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
      if (currentList.isEmpty) return;

      final updatedMessage = _createStructFromScene(
          scene, content.substring(0, i), true, fixedImageUrl);
      if (updatedMessage != null) {
        currentList[currentList.length - 1] = updatedMessage;
        _messagesNotifier.value = currentList;
        if (i % 20 == 0) _jumpToBottom();
      }
    }

    final currentList =
        List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
    final finalMessage =
        _createStructFromScene(scene, content, false, fixedImageUrl);
    if (finalMessage != null) {
      currentList[currentList.length - 1] = finalMessage;
      _messagesNotifier.value = currentList;
    }
    _jumpToBottom();
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _jumpToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _animateToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  StoryChatMessageStructStruct? _createStructFromScene(
      dynamic scene, String text, bool isStreaming, String fixedImageUrl) {
    if (scene == null) return null;
    final String type = (scene['type'] ?? 'narration').toString();
    final String speaker = (scene['speaker'] ?? '').toString();
    final String action = (scene['action'] ?? '').toString();
    return createStoryChatMessageStructStruct(
      type: type,
      speakerName: speaker,
      actionText: action,
      text: text,
      isStreaming: isStreaming,
      storyImageUrl: '',
    );
  }

  // ✅ 감정 키를 7개로 강제 + emotionStruct에서 매칭
  String? _resolveCharacterImageUrl(String speakerName, String? emotionKey) {
    final name = speakerName.trim();
    if (name.isEmpty) return null;

    final characters = widget.preDefinedCharacters ?? [];
    CharacterStructStruct? character;
    try {
      character =
          characters.firstWhere((c) => (c.name).toString().trim() == name);
    } catch (_) {
      return null;
    }

    final key = _normalizeEmotionKey(emotionKey ?? '');

    final List<String> candidates = [];
    for (final e in (character.emotionStruct ?? <EmotionStructStruct>[])) {
      if ((e.emotion).toString().trim() == key) {
        final url = stringToImagePath((e.imageurl).toString().trim());
        if (isValidNetworkImageUrl(url)) candidates.add(url);
      }
    }

    if (candidates.isNotEmpty) {
      return candidates[Random().nextInt(candidates.length)];
    }

    // ✅ 프로필 이미지 필드명이 다르면 여기만 너 필드명으로 바꿔서 쓰면 됨
    final p = stringToImagePath((character.profileimage ?? '').toString());
    if (isValidNetworkImageUrl(p)) return p;

    return null;
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FadeTransition(
          opacity: _loadingAnimation,
          child: Text("생각하는 중...",
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<StoryChatMessageStructStruct>>(
      valueListenable: _messagesNotifier,
      builder: (context, chatMessages, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
          itemCount: chatMessages.length,
          itemBuilder: (context, index) {
            final chatItem = chatMessages[index];

            if (chatItem.type == 'turn_header') {
              return _buildTurnHeader(chatItem);
            }

            if (chatItem.type == 'user') {
              return _buildDialogueMessage(chatItem, isUser: true);
            } else if (chatItem.type == 'thinking' || chatItem.text == '생각 중') {
              return _buildThinkingIndicator();
            } else {
              return _buildAiMessage(chatItem);
            }
          },
        );
      },
    );
  }

  Widget _buildDialogueMessage(StoryChatMessageStructStruct chatItem,
      {bool isUser = false}) {
    final speaker =
        isUser ? (widget.userInChatName ?? '나') : chatItem.speakerName;
    final nameColor = isUser ? Colors.red : Colors.black87;
    String imageUrl = '';

    if (!isUser) {
      imageUrl = _resolveCharacterImageUrl(
              chatItem.speakerName, chatItem.actionText) ??
          '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && isValidNetworkImageUrl(imageUrl))
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: safeNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: "$speaker ",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: nameColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.0)),
                TextSpan(
                    text: "| ",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0)),
                TextSpan(
                    text: chatItem.text,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: Colors.black87,
                        fontSize: 15.0,
                        lineHeight: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarration(StoryChatMessageStructStruct message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        width: double.infinity,
        child: Text(message.text,
            textAlign: TextAlign.start,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                color: const Color(0xFF666666),
                fontSize: 15.0,
                lineHeight: 1.8)),
      ),
    );
  }

  Widget _buildTurnHeader(StoryChatMessageStructStruct message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, top: 6.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          message.text,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                color: Colors.grey.shade600,
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                lineHeight: 1.3,
              ),
        ),
      ),
    );
  }

  Widget _buildStoryImage(StoryChatMessageStructStruct chatItem) {
    final url = stringToImagePath((chatItem.storyImageUrl ?? '').toString());
    if (!isValidNetworkImageUrl(url)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: safeNetworkImage(
          imageUrl: url,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAiMessage(StoryChatMessageStructStruct chatItem) {
    if (chatItem.type == 'turn_header') return _buildTurnHeader(chatItem);
    if (chatItem.type == 'narration') return _buildNarration(chatItem);
    if (chatItem.type == 'dialogue') return _buildDialogueMessage(chatItem);
    if (chatItem.type == 'story_image') return _buildStoryImage(chatItem);
    return const SizedBox.shrink();
  }

  List<dynamic> _parseScriptIntoScenes(String scriptText) {
    final List<dynamic> scenes = [];

    final RegExp exp = RegExp(
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
            "type": "turn_header",
            "content": (m.group(2) ?? '').trim(),
          });
          continue;
        }

        if (m.group(5) != null) {
          scenes.add({
            "type": "narration",
            "content": (m.group(6) ?? '').trim(),
          });
          continue;
        }

        if (m.group(7) != null) {
          scenes.add({
            "type": "dialogue",
            "speaker": (m.group(8) ?? '').trim(),
            "action": (m.group(9) ?? '').trim(),
            "content": (m.group(10) ?? '').trim(),
          });
          continue;
        }

        if (m.group(3) != null) {
          scenes.add({
            "type": "show_image",
            "condition": (m.group(4) ?? '').trim(),
          });
          continue;
        }
      }
    } else {
      scenes.add({"type": "narration", "content": scriptText});
    }

    return scenes;
  }
}
