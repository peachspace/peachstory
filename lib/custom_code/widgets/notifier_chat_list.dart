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

    // [핵심 수정] 리스트 갱신 로직 개선 (깜빡임 방지)
    if (widget.initialMessages != null) {
      final parentList = widget.initialMessages!;
      final currentList = _messagesNotifier.value;

      // 1. 리스트가 초기화되었거나 완전히 바뀐 경우 (길이가 줄어듦 -> 예: 생각중 삭제)
      if (parentList.length < currentList.length) {
        // 이때만 전체 교체 (삭제 반영을 위해)
        _messagesNotifier.value = List.from(parentList);
      }
      // 2. 새로운 메시지가 추가된 경우 (길이가 늘어남)
      else if (parentList.length > currentList.length) {
        // 기존 리스트를 유지하고, 추가된 부분만 덧붙임 (화면 깜빡임 방지)
        // 단, 타이핑 중에는 AI가 직접 그리고 있으므로, 부모 리스트 동기화를 잠시 미룸
        if (!_isTyping) {
          final newItems = parentList.sublist(currentList.length);
          _messagesNotifier.value = [...currentList, ...newItems];
          WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
        }
      }
      // 3. 길이는 같지만 내용이 바뀐 경우 (생각중 -> 텍스트)
      else if (parentList.isNotEmpty && currentList.isNotEmpty) {
        if (parentList.last.text != currentList.last.text ||
            parentList.last.type != currentList.last.type) {
          // 마지막 아이템만 교체
          final updatedList =
              List<StoryChatMessageStructStruct>.from(currentList);
          updatedList[updatedList.length - 1] = parentList.last;
          _messagesNotifier.value = updatedList;
        }
      }
    }

    // AI 스크립트 처리
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
      // JSON 파싱 (앞부분 잡담 제거)
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

    // 중복 제거
    if (_scenes.length > 1) {
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

      // [중요] 타이핑이 끝난 후 최종 데이터 동기화
      if (widget.onTurnComplete != null) {
        await widget.onTurnComplete!(_scenes);
      }

      // 부모 리스트와 최종 동기화 (타이핑 중 무시했던 데이터 맞추기)
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

    // 새 메시지를 리스트에 추가 (기존 리스트 유지 + 새 항목)
    _messagesNotifier.value = [..._messagesNotifier.value, placeholder];
    _jumpToBottom();

    final String content = scene['content'] ?? '';

    for (int i = 0; i <= content.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 10));

      // 현재 화면에 있는 리스트를 가져와서 마지막 항목만 수정
      final currentList =
          List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
      if (currentList.isEmpty) return;

      final updatedMessage =
          _createStructFromScene(scene, content.substring(0, i), true);
      if (updatedMessage != null) {
        currentList[currentList.length - 1] = updatedMessage;
        _messagesNotifier.value = currentList; // 교체 (화면 갱신)

        if (i % 20 == 0) _jumpToBottom();
      }
    }

    // 완료 처리
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
              // [독자 숨기기]
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
    try {
      int jsonStartIndex = scriptText.indexOf('[');
      if (jsonStartIndex != -1) {
        String jsonPart = scriptText.substring(jsonStartIndex);
        int jsonEndIndex = jsonPart.lastIndexOf(']');
        if (jsonEndIndex != -1) {
          jsonPart = jsonPart.substring(0, jsonEndIndex + 1);
          return jsonDecode(jsonPart);
        }
      }
    } catch (e) {}

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
