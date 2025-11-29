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

import '/flutter_flow/custom_functions.dart';

import 'dart:async';
import 'dart:convert';
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
  });

  final double? width;
  final double? height;
  final List<StoryChatMessageStructStruct>? initialMessages;
  final String newResponseScript;
  final String? userInChatName;
  final List<CharacterStructStruct>? preDefinedCharacters;
  final List<SituationalImageStructStruct>? situationalImageList;
  final Future<dynamic> Function(List<dynamic>? scenes)? onTurnComplete;

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

    if (widget.initialMessages != null) {
      final parentList = widget.initialMessages!;
      final currentList = _messagesNotifier.value;

      bool shouldUpdate = false;
      if (parentList.length != currentList.length) {
        shouldUpdate = true;
      } else if (parentList.isNotEmpty && currentList.isNotEmpty) {
        if (parentList.last.text != currentList.last.text ||
            parentList.last.type != currentList.last.type) {
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
        widget.newResponseScript != '" "') {
      if (widget.newResponseScript.contains("BLOCKED_CONTENT")) return;
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

    // [수정 1] 마크다운 제거 및 공백 제거
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
          if (decoded is List) {
            _scenes = decoded;
          }
        } catch (_) {}
      } else {
        _scenes = _parseScriptIntoScenes(script);
      }
    } catch (e) {
      print("JSON Parse Error: $e");
      _scenes = _parseScriptIntoScenes(script);
    }

    if (_scenes.isEmpty && script.isNotEmpty) {
      _scenes.add({"type": "narration", "content": script});
    }

    // [수정 2] 중복 씬 제거 (AI 반복 말하기 방지)
    if (_scenes.length > 1) {
      // 간단한 중복 제거
      var uniqueScenes = <dynamic>[];
      for (var s in _scenes) {
        if (uniqueScenes.isEmpty ||
            uniqueScenes.last['content'] != s['content']) {
          uniqueScenes.add(s);
        }
      }
      _scenes = uniqueScenes;
    }

    _currentSceneIndex = 0;
    _processNextScene();
  }

  void _processNextScene() async {
    if (!mounted || _currentSceneIndex >= _scenes.length) {
      setState(() => _isTyping = false);
      if (widget.onTurnComplete != null) {
        widget.onTurnComplete!(_scenes);
      }
      _animateToBottom();
      return;
    }

    final scene = _scenes[_currentSceneIndex];
    _currentSceneIndex++;
    final type = scene['type'] ?? 'narration';

    _smartJumpToBottom(); // 씬 시작 시엔 스마트 점프

    if (type == 'show_image') {
      final imageUrl = _findSituationalImageUrlByCondition(
          scene['condition'] ?? '', widget.situationalImageList ?? []);

      if (imageUrl.isNotEmpty) {
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
        _jumpToBottom(); // 이미지는 높이가 크므로 강제 점프
        await Future.delayed(const Duration(milliseconds: 300));
      }
      _processNextScene();
    } else if (type == 'narration' || type == 'dialogue') {
      await _animateTextScene(scene);
      if (mounted) {
        _processNextScene();
      }
    } else {
      _processNextScene();
    }
  }

  Future<void> _animateTextScene(dynamic scene) async {
    final placeholder = _createStructFromScene(scene, '', true);
    if (placeholder == null) return;

    _messagesNotifier.value = [..._messagesNotifier.value, placeholder];
    _smartJumpToBottom();

    final String content = scene['content'] ?? '';

    for (int i = 0; i <= content.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 10));

      final currentList =
          List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
      if (currentList.isEmpty) return;

      final updatedMessage =
          _createStructFromScene(scene, content.substring(0, i), true);
      if (updatedMessage != null) {
        currentList[currentList.length - 1] = updatedMessage;
        _messagesNotifier.value = currentList;

        // [수정 3] 20글자마다 스마트 스크롤 (흔들림 방지 핵심)
        if (i % 20 == 0) _smartJumpToBottom();
      }
    }

    final currentList =
        List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
    final finalMessage = _createStructFromScene(scene, content, false);
    if (finalMessage != null) {
      currentList[currentList.length - 1] = finalMessage;
      _messagesNotifier.value = currentList;
    }
    _smartJumpToBottom();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // [핵심] 화면이 맨 아래에 가까울 때만 스크롤 (흔들림 방지)
  void _smartJumpToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        // 150px 이내의 오차범위에 있을 때만 이동
        if ((maxScroll - currentScroll) < 150) {
          _scrollController.jumpTo(maxScroll);
        }
      }
    });
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
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 150),
          itemCount: chatMessages.length,
          itemBuilder: (context, index) {
            final chatItem = chatMessages[index];

            if (chatItem.type == 'user') {
              if (chatItem.speakerName == '독자' ||
                  chatItem.text.startsWith('[SYSTEM') ||
                  chatItem.text.trim().isEmpty) {
                return SizedBox.shrink();
              }
              return _buildUserAsDialogue(chatItem);
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
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: FadeTransition(
        opacity: _loadingAnimation,
        child: Text(
          "생각하는 중...",
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                color: Colors.grey[500],
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
        ),
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
                color: Color(0xFF666666),
                fontSize: 15.0,
                lineHeight: 1.8,
              ),
        ),
      ),
    );
  }

  Widget _buildUserAsDialogue(StoryChatMessageStructStruct chatItem) {
    return _buildDialogueMessage(
      chatItem,
      overrideSpeaker: widget.userInChatName ?? '나',
      overrideImage: currentUserPhoto ?? '',
      isUser: true,
    );
  }

  Widget _buildDialogueMessage(StoryChatMessageStructStruct chatItem,
      {String? overrideSpeaker, String? overrideImage, bool isUser = false}) {
    String speaker =
        isUser ? (widget.userInChatName ?? '나') : chatItem.speakerName;
    Color nameColor = isUser ? Colors.red : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$speaker :: ",
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: nameColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.0,
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
      ),
    );
  }

  Widget _buildStoryImage(StoryChatMessageStructStruct chatItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          chatItem.storyImageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
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
    return SizedBox.shrink();
  }

  List<dynamic> _parseScriptIntoScenes(String scriptText) {
    final List<dynamic> scenes = [];
    scenes.add({"type": "narration", "content": scriptText});
    return scenes;
  }

  StoryChatMessageStructStruct? _createStructFromScene(
      dynamic scene, String text, bool isStreaming) {
    if (scene == null) return null;

    return createStoryChatMessageStructStruct(
      type: scene['type'] ?? 'narration',
      speakerName: scene['speaker'] ?? '',
      actionText: '',
      text: text,
      isStreaming: isStreaming,
      storyImageUrl: '',
      speakerImage: '',
    );
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

  String? _findCharacterImageByName(
      String name, List<CharacterStructStruct> characters) {
    for (final char in characters) {
      if (char.name.trim() == name.trim()) {
        return char.image;
      }
    }
    return null;
  }
}
