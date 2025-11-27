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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
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

    // [문제 해결 1] 리스트 동기화 (생각 중 삭제 감지)
    if (widget.initialMessages != null) {
      final parentList = widget.initialMessages!;
      final currentList = _messagesNotifier.value;

      // 리스트 길이 변경(삭제/추가) 또는 마지막 내용 변경 시 무조건 업데이트
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
        // 변경 시에는 애니메이션 없이 즉시 이동 (깜빡임/울렁임 방지)
        WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
      }
    }

    // 2. AI 스크립트 처리
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
      // 모든 씬이 끝나면 부드럽게 마무리 스크롤
      _animateToBottom();
      return;
    }

    final scene = _scenes[_currentSceneIndex];
    _currentSceneIndex++;
    final type = scene['type'] ?? 'narration';

    // 씬 시작 시 즉시 이동
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

        // [문제 해결 2] 타이핑 중에는 애니메이션 없이 '점프' (떨림 해결)
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
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // [스크롤 함수 1] 즉시 이동 (타이핑 중, 메시지 추가/삭제 시)
  void _jumpToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent + 150);
      }
    });
  }

  // [스크롤 함수 2] 부드러운 이동 (모든 씬 종료 시)
  void _animateToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 150,
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
          // [문제 해결 3] 버튼에 가려지지 않도록 하단 패딩 150px 확보
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 150),
          itemCount: chatMessages.length,
          itemBuilder: (context, index) {
            final chatItem = chatMessages[index];

            if (chatItem.type == 'user') {
              // [안전장치] 혹시라도 독자 메시지가 리스트에 들어오면 여기서 숨김
              if (chatItem.speakerName == '독자' ||
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

  // ... (나머지 UI 빌더 함수들은 기존과 동일) ...
  // _buildThinkingIndicator, _buildNarration, _buildUserAsDialogue, _buildDialogueMessage,
  // _buildStoryImage, _buildAiMessage, _parseScriptIntoScenes, _createStructFromScene,
  // _findSituationalImageUrlByCondition, _findCharacterImageByName

  // [주의] 아래 함수들도 반드시 포함되어야 합니다. 이전 답변의 코드를 그대로 쓰세요.

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
      padding: const EdgeInsets.only(bottom: 12.0),
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
    String speaker = overrideSpeaker ?? chatItem.speakerName;
    String speakerImage = overrideImage ??
        chatItem.speakerImage ??
        _findCharacterImageByName(speaker, widget.preDefinedCharacters ?? []) ??
        '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12.0),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: speakerImage.isNotEmpty
                  ? Image.network(
                      speakerImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.transparent),
                    )
                  : Container(color: Colors.transparent),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: isUser ? Color(0xFF4B39EF) : Colors.black87,
                        fontSize: 14.0,
                      ),
                ),
                SizedBox(height: 4),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      if (chatItem.actionText != null &&
                          chatItem.actionText!.isNotEmpty &&
                          chatItem.actionText != 'null')
                        TextSpan(
                          text: "(${chatItem.actionText}) ",
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF95A1AC),
                                    fontSize: 12.5,
                                  ),
                        ),
                      TextSpan(
                        text: chatItem.text,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              color: Colors.black87,
                              fontSize: 15.0,
                              lineHeight: 1.5,
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
    );
  }

  Widget _buildStoryImage(StoryChatMessageStructStruct chatItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
      actionText: scene['action'] ?? '',
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
