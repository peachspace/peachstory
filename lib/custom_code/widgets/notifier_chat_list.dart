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
  final List<CharacterStructStruct>? preDefinedCharacters;
  final List<BackgroundStructStruct>? backgroundList;
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

  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _messagesNotifier = ValueNotifier(List.from(widget.initialMessages ?? []));

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

    // 1. 메시지 리스트 업데이트 로직
    if (widget.initialMessages != null && !_isTyping) {
      final parentList = widget.initialMessages!;
      final currentList = _messagesNotifier.value;
      bool shouldUpdate = false;

      // [핵심 수정] "생각 중" 메시지가 떠있는 상태인지 확인
      bool isThinking = currentList.isNotEmpty &&
          (currentList.last.type == 'thinking' ||
              currentList.last.text == '생각 중');

      // 부모 리스트가 더 짧은 경우 (DB 로딩 지연 등으로 인해)
      // 단, "생각 중" 메시지를 지우고 진짜 메시지로 교체되는 순간이라면 업데이트를 허용해야 함
      if (parentList.length < currentList.length && !isThinking) {
        // 생각 중인 상황이 아닌데 리스트가 줄어들었다면 -> 로딩 에러로 간주하고 무시
        return;
      }

      if (parentList.length != currentList.length) {
        shouldUpdate = true;
      } else if (parentList.isNotEmpty && currentList.isNotEmpty) {
        final p = parentList.last;
        final c = currentList.last;
        // 내용이 바뀌었거나 타입이 바뀌었으면 업데이트
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
            // 마지막 메시지가 달라졌다면 새 메시지 추가로 간주
            if (parentList.last.text != currentList.last.text) {
              addedAtBottom = true;
            }
          }
        }

        _messagesNotifier.value = List.from(parentList);

        if (addedAtBottom || _isTyping) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
        }
      }
    }

    // 2. 타이핑(연출) 시작 트리거 로직
    if (widget.newResponseScript != oldWidget.newResponseScript &&
        widget.newResponseScript.isNotEmpty &&
        widget.newResponseScript != '""' &&
        !widget.newResponseScript.contains("BLOCKED_CONTENT")) {
      // 이미 타이핑 중이면 무시
      if (_isTyping) return;

      // [수정] 타이핑 시작 전 "생각 중" 메시지가 있다면 제거 (시각적 깔끔함)
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

    if (type == 'show_image') {
      final condition = scene['condition'] ?? '';
      final imageUrl = _findSituationalImageUrlByCondition(condition);

      if (imageUrl.isNotEmpty && imageUrl != 'null') {
        final imageMessage = createStoryChatMessageStructStruct(
          type: 'story_image',
          storyImageUrl: imageUrl,
          isStreaming: false,
          text: '',
          speakerName: '',
          actionText: '',
        );
        _messagesNotifier.value = [..._messagesNotifier.value, imageMessage];
        _jumpToBottom();
        await Future.delayed(const Duration(milliseconds: 800));
      }
      _processNextScene();
    } else if (type == 'narration' || type == 'dialogue') {
      await _animateTextScene(scene);
      if (mounted) _processNextScene();
    } else {
      _processNextScene();
    }
  }

  String _findSituationalImageUrlByCondition(String condition) {
    final target = condition.trim();
    if (target.isEmpty) return '';

    final bgList = widget.backgroundList ?? [];
    for (final bg in bgList) {
      if (bg.placeName.trim() == target) {
        return bg.imageUrl;
      }
    }

    final charList = widget.preDefinedCharacters ?? [];
    for (final char in charList) {
      for (final sit in char.situationImages) {
        if (sit.condition.trim() == target) {
          return sit.imageUrl;
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

    final String content = scene['content'] ?? '';
    // [속도 조절] 타이핑 속도를 약간 빠르게 (15ms -> 10ms)
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

  String? _resolveCharacterImageUrl(String speakerName, String? emotionKey) {
    final name = speakerName.trim();
    if (name.isEmpty) return null;
    final characters = widget.preDefinedCharacters ?? [];
    CharacterStructStruct? character;
    try {
      character = characters.firstWhere((c) => c.name.trim() == name);
    } catch (_) {
      return null;
    }

    final key = (emotionKey != null && emotionKey.trim().isNotEmpty)
        ? emotionKey.trim()
        : '무감정';
    final List<String> candidates = [];

    for (final e in character.emotionimages) {
      if (e.emotion == key) {
        if (e.imageurl != null && e.imageurl!.startsWith('http'))
          candidates.add(e.imageurl!);
      }
    }

    if (candidates.isNotEmpty)
      return candidates[Random().nextInt(candidates.length)];

    if (character.profileimage != null &&
        character.profileimage!.startsWith('http'))
      return character.profileimage;

    if (character.image != null && character.image!.isNotEmpty)
      return character.image;

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
            if (chatItem.type == 'user') {
              // 유저 메시지 뒤에 "생각 중" 표시는 따로 처리하므로 여기서는 일반 메시지로
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
          if (!isUser && imageUrl.isNotEmpty && imageUrl.startsWith('http'))
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink()),
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

  Widget _buildStoryImage(StoryChatMessageStructStruct chatItem) {
    if (chatItem.storyImageUrl == null ||
        chatItem.storyImageUrl.isEmpty ||
        chatItem.storyImageUrl == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(chatItem.storyImageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink()),
      ),
    );
  }

  Widget _buildAiMessage(StoryChatMessageStructStruct chatItem) {
    if (chatItem.type == 'narration')
      return _buildNarration(chatItem);
    else if (chatItem.type == 'dialogue')
      return _buildDialogueMessage(chatItem);
    else if (chatItem.type == 'story_image') return _buildStoryImage(chatItem);
    return const SizedBox.shrink();
  }

  List<dynamic> _parseScriptIntoScenes(String scriptText) {
    final List<dynamic> scenes = [];
    final RegExp exp = RegExp(
        r'(\[SHOW_IMAGE="(.*?)"\])|(\[NARRATION\](.*?)\[/NARRATION\])|(\[DIALOGUE SPEAKER="(.*?)"(?: ACTION="(.*?)")?\](.*?)\[/DIALOGUE\])',
        dotAll: true,
        multiLine: true);
    final matches = exp.allMatches(scriptText);
    if (matches.isNotEmpty) {
      for (final m in matches) {
        if (m.group(3) != null)
          scenes
              .add({"type": "narration", "content": m.group(4)?.trim() ?? ''});
        else if (m.group(5) != null)
          scenes.add({
            "type": "dialogue",
            "speaker": m.group(6)?.trim() ?? '',
            "action": m.group(7)?.trim(),
            "content": m.group(8)?.trim() ?? ''
          });
        else if (m.group(1) != null)
          scenes.add(
              {"type": "show_image", "condition": m.group(2)?.trim() ?? ''});
      }
    } else {
      scenes.add({"type": "narration", "content": scriptText});
    }
    return scenes;
  }
}
