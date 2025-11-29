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

    String script = widget.newResponseScript.trim();
    _scenes = [];

    try {
      if (script.startsWith('[')) {
        _scenes = jsonDecode(script);
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

    _currentSceneIndex = 0;
    _processNextScene();
  }

  void _processNextScene() async {
    if (!mounted || _currentSceneIndex >= _scenes.length) {
      setState(() => _isTyping = false);
      if (widget.onTurnComplete != null) {
        widget.onTurnComplete!(_scenes);
      }
      _forceScrollToBottom();
      return;
    }

    final scene = _scenes[_currentSceneIndex];
    _currentSceneIndex++;
    final type = scene['type'] ?? 'narration';

    _jumpToBottom();

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
        _jumpToBottom();
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
    _jumpToBottom();

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

        // [스크롤 튐 방지]
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
    _jumpToBottom();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // [핵심] 화면이 이미 맨 아래일 때만 점프 (덜덜거림 방지)
  void _smartJumpToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.position.pixels;
        // 오차가 100px 이내일 때만 강제 이동
        if (max - current < 100) {
          _scrollController.jumpTo(max + 150);
        }
      }
    });
  }

  void _jumpToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent + 150);
      }
    });
  }

  void _forceScrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 150,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
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
                  chatItem.text.startsWith('[SYSTEM')) {
                return SizedBox.shrink();
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

  // [디자인] 나레이션: 간격 넓힘 (Bottom 24)
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
                fontSize: 14.0,
                lineHeight: 1.6,
              ),
        ),
      ),
    );
  }

  // [디자인] 대사: 이미지 없음, 이름::대사 형식, 이름 강조
  Widget _buildDialogueMessage(StoryChatMessageStructStruct chatItem,
      {bool isUser = false}) {
    String speaker =
        isUser ? (widget.userInChatName ?? '나') : chatItem.speakerName;

    // 내 이름은 빨간색, 남은 검은색
    Color nameColor = isUser ? Colors.red : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), // 간격 넓힘
      child: Align(
        alignment: Alignment.centerLeft, // 무조건 왼쪽 정렬
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$speaker :: ", // 포맷 변경
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: nameColor,
                      fontWeight: FontWeight.bold, // 굵게
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

  // ... (Helper Functions 유지) ...
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
      actionText: '', // [수정] 괄호 행동 지문 삭제 (빈값 처리)
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
}
