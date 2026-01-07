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

import 'index.dart'; // Imports other custom widgets
import 'dart:async';
import 'dart:convert';
import 'dart:math'; // ★ 랜덤 기능을 위해 추가
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
    this.situationalImageList,
    this.onTurnComplete,
    this.isNovelMode,
  });

  final double? width;
  final double? height;
  final List<StoryChatMessageStructStruct>? initialMessages;
  final String newResponseScript;
  final String? userInChatName;
  final List<CharacterStructStruct>? preDefinedCharacters;
  final List<SituationalImageStructStruct>? situationalImageList;
  final Future<dynamic> Function(List<dynamic>? scenes)? onTurnComplete;
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

  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _messagesNotifier = ValueNotifier(List.from(widget.initialMessages ?? []));
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());

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

      if (parentList.length != currentList.length) {
        shouldUpdate = true;
      } else if (parentList.isNotEmpty && currentList.isNotEmpty) {
        final p = parentList.last;
        final c = currentList.last;
        if (p.text != c.text ||
            p.type != c.type ||
            p.storyImageUrl != c.storyImageUrl ||
            p.speakerName != c.speakerName ||
            p.speakerImage != c.speakerImage) {
          shouldUpdate = true;
        }
      }

      if (shouldUpdate) {
        _messagesNotifier.value = List.from(parentList);
        WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
      }
    }

    if (widget.newResponseScript != oldWidget.newResponseScript &&
        widget.newResponseScript.isNotEmpty &&
        widget.newResponseScript != '""' &&
        widget.newResponseScript != '" "' &&
        !widget.newResponseScript.contains("BLOCKED_CONTENT")) {
      if (_isTyping) return;
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
          if (lastBracket != -1) {
            jsonPart = jsonPart.substring(0, lastBracket + 1);
          }
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
      if (widget.onTurnComplete != null) {
        await widget.onTurnComplete!(_scenes);
      }
      if (widget.initialMessages != null) {
        _messagesNotifier.value = List.from(widget.initialMessages!);
      }
      _animateToBottom();
      return;
    }

    final scene = _scenes[_currentSceneIndex];
    _currentSceneIndex++;
    final type = scene['type'] ?? 'narration';
    _jumpToBottom();

    if (type == 'show_image') {
      final imageUrl = _findSituationalImageUrlByCondition(
          scene['condition'] ?? '', widget.situationalImageList ?? []);

      if (imageUrl.isNotEmpty && imageUrl != 'null') {
        final imageMessage = createStoryChatMessageStructStruct(
          type: 'story_image',
          storyImageUrl: imageUrl,
          isStreaming: false,
          text: '',
          speakerName: '',
          actionText: '',
          speakerImage: '',
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

  Future<void> _animateTextScene(dynamic scene) async {
    final placeholder = _createStructFromScene(scene, '', true);
    if (placeholder == null) return;

    _messagesNotifier.value = [..._messagesNotifier.value, placeholder];
    _jumpToBottom();

    final String content = scene['content'] ?? '';

    for (int i = 0; i <= content.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 15));

      final currentList =
          List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
      if (currentList.isEmpty) return;

      final updatedMessage =
          _createStructFromScene(scene, content.substring(0, i), true);

      if (updatedMessage != null) {
        currentList[currentList.length - 1] = updatedMessage;
        _messagesNotifier.value = currentList;
        if (i % 20 == 0) _jumpToBottom();
      }
    }

    final currentList =
        List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
    final finalMessage = _createStructFromScene(scene, content, false);
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
              if (chatItem.text == '생각 중' || chatItem.type == 'thinking') {
                return _buildThinkingIndicator();
              }
              return _buildDialogueMessage(chatItem, isUser: true);
            } else if (chatItem.type == 'thinking') {
              return _buildThinkingIndicator();
            } else {
              return _buildAiMessage(chatItem);
            }
          },
        );
      },
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FadeTransition(
          opacity: _loadingAnimation,
          child: Text(
            "생각하는 중...",
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
      ),
    );
  }

  StoryChatMessageStructStruct? _createStructFromScene(
      dynamic scene, String text, bool isStreaming) {
    if (scene == null) return null;

    final String type = (scene['type'] ?? 'narration').toString();
    final String speaker = (scene['speaker'] ?? '').toString();
    final String action = (scene['action'] ?? '').toString();

    // 이미지 찾기
    final String resolvedImage =
        _resolveCharacterImageUrl(speaker, action) ?? '';

    return createStoryChatMessageStructStruct(
      type: type,
      speakerName: speaker,
      actionText: action,
      text: text,
      isStreaming: isStreaming,
      storyImageUrl: '',
      speakerImage: resolvedImage,
    );
  }

  // ★ [수정됨] 랜덤 이미지 선택 로직 적용
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

    // 감정 키가 없으면 '무감정'을 기본값으로 설정
    final key = (emotionKey != null && emotionKey.trim().isNotEmpty)
        ? emotionKey.trim()
        : '무감정';

    // 1. 해당 감정에 맞는 이미지들을 모두 찾습니다.
    final List<String> candidates = [];

    for (final e in character.emotionImages) {
      if (e.emotion != null && e.emotion!.trim() == key) {
        if (e.image != null && e.image!.startsWith('http')) {
          candidates.add(e.image!);
        }
      }
    }

    // 2. 후보가 있다면 랜덤으로 하나 선택
    if (candidates.isNotEmpty) {
      return candidates[Random().nextInt(candidates.length)];
    }

    // 3. 감정 이미지가 없으면 기본 프로필 이미지 반환
    if (character.imageUrl != null && character.imageUrl!.startsWith('http')) {
      return character.imageUrl;
    }
    return character.image;
  }

  // ★ [수정됨] 구분자 '|' 적용 및 스타일 변경
  Widget _buildDialogueMessage(StoryChatMessageStructStruct chatItem,
      {bool isUser = false}) {
    final speaker =
        isUser ? (widget.userInChatName ?? '나') : chatItem.speakerName;
    final nameColor = isUser ? Colors.red : Colors.black87;

    String imageUrl = '';
    if (!isUser) {
      imageUrl = chatItem.speakerImage;
      if (imageUrl.isEmpty) {
        imageUrl = _resolveCharacterImageUrl(
                chatItem.speakerName, chatItem.actionText) ??
            '';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. [이미지] 감정 이미지 출력
          if (!isUser && imageUrl.isNotEmpty && imageUrl.startsWith('http'))
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),

          // 2. [텍스트] 이름 | 대사 형식으로 변경
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$speaker ",
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: nameColor,
                        fontWeight: FontWeight.w900, // 이름 더 굵게
                        fontSize: 15.0,
                      ),
                ),
                TextSpan(
                  text: "| ", // ★ 구분자 변경
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: Colors.grey.shade400, // 연한 회색
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                ),
                TextSpan(
                  text: chatItem.text,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: Colors.black87,
                        fontSize: 15.0,
                        lineHeight: 1.6,
                      ),
                ),
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
        child: Text(
          message.text,
          textAlign: TextAlign.start,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                color: const Color(0xFF666666),
                fontSize: 15.0,
                lineHeight: 1.8,
              ),
        ),
      ),
    );
  }

  Widget _buildStoryImage(StoryChatMessageStructStruct chatItem) {
    if (chatItem.storyImageUrl == null ||
        chatItem.storyImageUrl.isEmpty ||
        chatItem.storyImageUrl == 'null') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          chatItem.storyImageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildAiMessage(StoryChatMessageStructStruct chatItem) {
    if (chatItem.type == 'narration') {
      return _buildNarration(chatItem);
    } else if (chatItem.type == 'dialogue') {
      return _buildDialogueMessage(chatItem);
    } else if (chatItem.type == 'story_image') {
      return _buildStoryImage(chatItem);
    }
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
        if (m.group(3) != null) {
          scenes
              .add({"type": "narration", "content": m.group(4)?.trim() ?? ''});
        } else if (m.group(5) != null) {
          scenes.add({
            "type": "dialogue",
            "speaker": m.group(6)?.trim() ?? '',
            "action": m.group(7)?.trim(),
            "content": m.group(8)?.trim() ?? ''
          });
        } else if (m.group(1) != null) {
          scenes.add(
              {"type": "show_image", "condition": m.group(2)?.trim() ?? ''});
        }
      }
    } else {
      scenes.add({"type": "narration", "content": scriptText});
    }
    return scenes;
  }

  String _findSituationalImageUrlByCondition(
      String condition, List<SituationalImageStructStruct> imageList) {
    for (final img in imageList) {
      if (img.condition == condition) {
        return img.imageUrl;
      }
    }
    return '';
  }
}
