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

  @override
  void initState() {
    super.initState();
    _messagesNotifier = ValueNotifier(List.from(widget.initialMessages ?? []));
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
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
        !widget.newResponseScript.contains("BLOCKED_CONTENT")) {
      _processScriptImmediately(widget.newResponseScript);
    }
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _processScriptImmediately(String script) {
    String cleanScript =
        script.replaceAll('```json', '').replaceAll('```', '').trim();
    _scenes = [];

    try {
      int bracketIndex = cleanScript.indexOf('[');
      if (bracketIndex != -1) {
        String jsonPart = cleanScript.substring(bracketIndex).trim();
        try {
          final dynamic decoded = jsonDecode(jsonPart);
          if (decoded is List) _scenes = decoded;
        } catch (_) {}
      }
      if (_scenes.isEmpty) _scenes = _parseScriptIntoScenes(cleanScript);
    } catch (e) {
      _scenes = _parseScriptIntoScenes(cleanScript);
    }

    if (_scenes.isEmpty && cleanScript.isNotEmpty) {
      _scenes.add({"type": "narration", "content": cleanScript});
    }

    if (widget.onTurnComplete != null) {
      widget.onTurnComplete!(_scenes);
    }
    _jumpToBottom();
  }

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
          itemCount: chatMessages.length,
          itemBuilder: (context, index) {
            final chatItem = chatMessages[index];

            if (chatItem.type == 'user') {
              if (chatItem.text == '생각 중' || chatItem.type == 'thinking') {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text("생각하는 중...",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                );
              }
              return _buildDialogueMessage(chatItem, isUser: true);
            } else if (chatItem.type == 'thinking') {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text("생각하는 중...",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              );
            } else {
              return _buildAiMessage(chatItem);
            }
          },
        );
      },
    );
  }

  // ★ [핵심] 대사 출력 UI (말풍선/원형프사 제거, 큰 이미지 추가)
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
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          // 1. [이미지] 감정/프로필 이미지가 있으면 크게 출력
          if (!isUser && imageUrl.isNotEmpty && imageUrl.startsWith('http'))
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  width: double.infinity, // 가로 꽉 차게
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),

          // 2. [텍스트] Speaker :: Text (기존 스타일)
          RichText(
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
        ],
      ),
    );
  }

  // Helper: 이미지 URL 찾기
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
    if (character.imageUrl != null && character.imageUrl!.startsWith('http')) {
      return character.imageUrl;
    }
    return character.image;
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
