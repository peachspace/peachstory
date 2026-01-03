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

class _NotifierChatListState extends State<NotifierChatList> {
  late ValueNotifier<List<StoryChatMessageStructStruct>> _messagesNotifier;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _scenes = [];
  int _currentSceneIndex = 0;
  // ★ [복구] 타이핑 관련 변수 제거 (즉시 출력)

  @override
  void initState() {
    super.initState();
    _messagesNotifier = ValueNotifier(List.from(widget.initialMessages ?? []));
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void didUpdateWidget(covariant NotifierChatList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 1. 리스트 동기화 (기존 로직 유지)
    if (widget.initialMessages != null) {
      final parentList = widget.initialMessages!;
      final currentList = _messagesNotifier.value;
      bool shouldUpdate = false;

      if (parentList.length != currentList.length) {
        shouldUpdate = true;
      } else if (parentList.isNotEmpty && currentList.isNotEmpty) {
        final p = parentList.last;
        final c = currentList.last;
        // 변경 감지 (이미지 포함)
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

    // 2. AI 스크립트 처리
    if (widget.newResponseScript != oldWidget.newResponseScript &&
        widget.newResponseScript.isNotEmpty &&
        widget.newResponseScript != '""' &&
        widget.newResponseScript != '" "' &&
        !widget.newResponseScript.contains("BLOCKED_CONTENT")) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _startDirecting());
    }
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startDirecting() {
    if (!mounted) return;

    // 스크립트 파싱 (기존 로직)
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

    // ★ [수정] 타이핑 없이 즉시 완료 처리
    if (widget.onTurnComplete != null) {
      widget.onTurnComplete!(_scenes);
    }
    _jumpToBottom();
  }

  // ★ [복구] 타이핑 애니메이션 로직 제거 -> 즉시 스크롤만 수행
  void _jumpToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
              // ★ [복구] 생각 중 메시지 처리
              if (chatItem.text == '생각 중' || chatItem.type == 'thinking') {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "생각하는 중...",
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                );
              }
              // 유저 메시지 (기존 스타일)
              return _buildDialogueMessage(chatItem, isUser: true);
            } else if (chatItem.type == 'thinking') {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "생각하는 중...",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              );
            } else {
              return _buildAiMessage(chatItem);
            }
          },
        );
      },
    );
  }

  // ★ [수정] 1. JSON 파싱 시 감정(Action) 저장
  StoryChatMessageStructStruct? _createStructFromScene(
      dynamic scene, String text, bool isStreaming) {
    // 이 함수는 onTurnComplete에서 호출하는 용도 (현재 위젯 내에서는 사용 안함)
    return null;
  }

  // ★ [수정] 2. 감정에 맞는 이미지 찾기
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

    final key = (emotionKey ?? '').trim();
    if (key.isNotEmpty) {
      for (final e in character.emotionImages) {
        if (e.emotion != null && e.emotion.trim() == key) {
          if (e.image != null && e.image.startsWith('http')) {
            return e.image;
          }
        }
      }
    }
    // 기본 프로필
    if (character.imageUrl != null && character.imageUrl!.startsWith('http')) {
      return character.imageUrl;
    }
    return character.image;
  }

  // ★ [수정] 3. 대사 출력 (기존 스타일 + 상단 큰 이미지)
  Widget _buildDialogueMessage(StoryChatMessageStructStruct chatItem,
      {String? overrideSpeaker, String? overrideImage, bool isUser = false}) {
    final speaker =
        isUser ? (widget.userInChatName ?? '나') : chatItem.speakerName;
    // 기존 색상 유지
    final nameColor = isUser ? Colors.red : Colors.black87;

    // 이미지 URL 결정
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
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          // [추가] 감정/프로필 이미지 (존재할 때만 크게 출력)
          if (!isUser && imageUrl.isNotEmpty && imageUrl.startsWith('http'))
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  width: double.infinity, // 가로 꽉 차게
                  // height: 250, // 필요시 높이 고정
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      SizedBox.shrink(), // 엑박 방지
                ),
              ),
            ),

          // [기존 코드 100% 복구] RichText (Speaker :: Text)
          Align(
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
                color: Color(0xFF666666),
                fontSize: 15.0,
                lineHeight: 1.8,
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
          errorBuilder: (context, error, stackTrace) =>
              SizedBox.shrink(), // 엑박 방지
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
            "action": m.group(7)?.trim(), // Action(감정) 파싱
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
