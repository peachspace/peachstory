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

    // 1. 외부 리스트 변경 감지 (이미지 URL 변경 등)
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

    // 2. AI 응답 처리 (타이핑 없이 즉시 변환)
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

  // ★ 타이핑 없이 스크립트를 즉시 파싱해서 넘기는 함수
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

    // StorychatWidget으로 파싱된 데이터를 바로 넘김 (저장 및 화면 갱신은 거기서 함)
    if (widget.onTurnComplete != null) {
      widget.onTurnComplete!(_scenes);
    }
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

            // 1. 유저 메시지 / 생각 중
            if (chatItem.type == 'user') {
              if (chatItem.text == '생각 중' || chatItem.type == 'thinking') {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text("생각하는 중...",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                );
              }
              return _buildDialogueMessage(chatItem, isUser: true);
            }
            // 2. 생각 중 (AI)
            else if (chatItem.type == 'thinking') {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text("생각하는 중...",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              );
            }
            // 3. AI 메시지 (대사, 지문, 상황이미지)
            else {
              return _buildAiMessage(chatItem);
            }
          },
        );
      },
    );
  }

  // ★ [핵심 수정] 대사 출력 (원형프사 X, 말풍선 X, 큰 이미지 O)
  Widget _buildDialogueMessage(StoryChatMessageStructStruct chatItem,
      {bool isUser = false}) {
    // 1. 화자 이름과 색상 결정
    final speaker =
        isUser ? (widget.userInChatName ?? '나') : chatItem.speakerName;
    final nameColor = isUser ? Colors.red : Colors.black87;

    // 2. 이미지 URL 결정 (감정이미지 or 프로필)
    String imageUrl = '';
    if (!isUser) {
      // 메시지에 저장된 이미지 우선 사용
      imageUrl = chatItem.speakerImage;
      // 없으면(빈값이면) 찾아서 채우기 (안전장치)
      if (imageUrl.isEmpty) {
        imageUrl = _resolveCharacterImageUrl(
                chatItem.speakerName, chatItem.actionText) ??
            '';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 무조건 왼쪽 정렬
        children: [
          // [이미지 영역] 이미지가 존재할 때만, 상황 이미지처럼 크게 출력
          if (!isUser && imageUrl.isNotEmpty && imageUrl.startsWith('http'))
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  width: double.infinity, // 가로 꽉 차게
                  fit: BoxFit.cover, // 비율 유지하며 꽉 채우기
                  // height: 300, // 필요하다면 높이 고정 (선택사항)
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(), // 엑박 방지
                ),
              ),
            ),

          // [텍스트 영역] 기존 스타일 (Speaker :: Text)
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

  // ★ 감정(Action)에 맞는 이미지 찾는 Helper 함수
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
    // 감정 없으면 기본 프로필 (이게 무감정일 때)
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
          textAlign: TextAlign.start, // 기존 스타일 (왼쪽 정렬)
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
    // 엑박 방지: URL이 없으면 아예 안 그림
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

  // 스크립트 파싱 로직 (기존 유지 + Action 파싱 추가)
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
            "action": m.group(7)?.trim(), // ★ Action(감정) 저장
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
}
