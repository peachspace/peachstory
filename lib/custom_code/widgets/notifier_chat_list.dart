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
    this.backgroundList,
    this.situationalImageList,
    this.onBackgroundChange,
    this.onTurnComplete,
  });

  final double? width;
  final double? height;
  final List<StoryChatMessageStructStruct>? initialMessages;
  final String newResponseScript;
  final String? userInChatName;
  final List<CharacterStructStruct>? preDefinedCharacters;
  final List<LocationBackgroundStructStruct>? backgroundList;
  final List<SituationalImageStructStruct>? situationalImageList;
  // [수정됨] 콜백 파라미터 타입을 다시 String?으로 변경
  final Future<dynamic> Function(String? newBgUrl)? onBackgroundChange;
  final Future<dynamic> Function(List<dynamic>? scenes)? onTurnComplete;

  @override
  State<NotifierChatList> createState() => _NotifierChatListState();
}

class _NotifierChatListState extends State<NotifierChatList> {
  late ValueNotifier<List<StoryChatMessageStructStruct>> _messagesNotifier;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _scenes = [];
  int _currentSceneIndex = 0;

  @override
  void initState() {
    super.initState();
    // 페이지가 처음 로드될 때만 initialMessages로 초기화합니다.
    _messagesNotifier = ValueNotifier(List.from(widget.initialMessages ?? []));
    _messagesNotifier.addListener(_scrollToBottom);
  }

  @override
  void didUpdateWidget(covariant NotifierChatList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 1. 부모의 메시지 리스트(initialMessages)와 위젯 내부의 리스트를 동기화합니다.
    //    사용자가 새 메시지를 보내면 이 부분이 실행되어 목록에 반영됩니다.
    final newMsgs = widget.initialMessages ?? [];
    if (newMsgs.length > _messagesNotifier.value.length) {
      _messagesNotifier.value = List.from(newMsgs);
    }

    // 2. 새로운 AI 스크립트가 도착했을 때만 연출을 시작합니다.
    //    이제 상태를 덮어쓰지 않고 바로 연출을 시작하여 깜빡임이 없습니다.
    if (widget.newResponseScript != oldWidget.newResponseScript &&
        widget.newResponseScript.isNotEmpty &&
        widget.newResponseScript != '""' &&
        widget.newResponseScript != '" "') {
      SchedulerBinding.instance.addPostFrameCallback((_) => _startDirecting());
    }
  }

  @override
  void dispose() {
    _messagesNotifier.removeListener(_scrollToBottom);
    _messagesNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startDirecting() {
    if (!mounted) return;
    _scenes = _parseScriptIntoScenes(widget.newResponseScript);
    _currentSceneIndex = 0;
    _processNextScene();
  }

  void _processNextScene() async {
    if (!mounted || _currentSceneIndex >= _scenes.length) {
      if (widget.onTurnComplete != null) {
        SchedulerBinding.instance
            .addPostFrameCallback((_) => widget.onTurnComplete!(_scenes));
      }
      return;
    }
    final scene = _scenes[_currentSceneIndex];
    _currentSceneIndex++;
    final type = scene['type'] ?? 'narration';

    if (type == 'background_change') {
      final location = scene['location'] ?? '';
      String foundUrl = '';
      if (widget.backgroundList != null) {
        for (final bg in widget.backgroundList!) {
          if (bg.locationName == location) {
            foundUrl = bg.imageUrl;
            break;
          }
        }
      }
      if (widget.onBackgroundChange != null) {
        await widget.onBackgroundChange!(foundUrl);
      }
      _processNextScene();
    } else if (type == 'show_image') {
      final imageUrl = _findSituationalImageUrlByCondition(
          scene['condition'] ?? '', widget.situationalImageList ?? []);
      if (imageUrl.isNotEmpty) {
        // 👇 타입 수정
        final imageMessage = createStoryChatMessageStructStruct(
            type: 'story_image', storyImageUrl: imageUrl, isStreaming: false);
        _messagesNotifier.value = [..._messagesNotifier.value, imageMessage];
      }
      await Future.delayed(const Duration(milliseconds: 300));
      _processNextScene();
    } else {
      await _animateTextScene(scene);
      if (mounted) {
        _processNextScene();
      }
    }
  }

  Future<void> _animateTextScene(dynamic scene) async {
    final placeholder = _createStructFromScene(scene, '', true);
    if (placeholder == null) return;
    _messagesNotifier.value = [..._messagesNotifier.value, placeholder];
    final String fullText = scene['content'] ?? '';
    for (int i = 0; i <= fullText.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 20)); // 속도 조절
      final currentList = _messagesNotifier.value;
      if (currentList.isEmpty) return;
      final updatedMessage =
          _createStructFromScene(scene, fullText.substring(0, i), true);
      if (updatedMessage == null) continue;
      currentList[currentList.length - 1] = updatedMessage;
      _messagesNotifier.value = List.from(currentList);
    }
    final currentList = _messagesNotifier.value;
    if (currentList.isNotEmpty) {
      final finalMessage = _createStructFromScene(scene, fullText, false);
      if (finalMessage != null) {
        currentList[currentList.length - 1] = finalMessage;
        _messagesNotifier.value = List.from(currentList);
      }
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 👇 타입 수정
    return ValueListenableBuilder<List<StoryChatMessageStructStruct>>(
      valueListenable: _messagesNotifier,
      builder: (context, chatMessages, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          itemCount: chatMessages.length,
          itemBuilder: (context, index) {
            final chatItem = chatMessages[index];
            if (chatItem.type == 'user') {
              return _buildUserMessage(chatItem);
            } else {
              return _buildAiMessage(chatItem);
            }
          },
        );
      },
    );
  }

  List<dynamic> _parseScriptIntoScenes(String scriptText) {
    final List<dynamic> scenes = [];
    final RegExp exp = RegExp(
        r'(\[SET_BACKGROUND="(.*?)"\])|(\[SHOW_IMAGE="(.*?)"\])|(\[NARRATION\](.*?)\[/NARRATION\])|(\[DIALOGUE SPEAKER="(.*?)"(?: ACTION="(.*?)")?\](.*?)\[/DIALOGUE\])',
        dotAll: true,
        multiLine: true);
    final matches = exp.allMatches(scriptText);
    for (final m in matches) {
      if (m.group(1) != null) {
        scenes.add({
          "type": "background_change",
          "location": m.group(2)?.trim() ?? ''
        });
      } else if (m.group(3) != null) {
        scenes
            .add({"type": "show_image", "condition": m.group(4)?.trim() ?? ''});
      } else if (m.group(5) != null) {
        scenes.add({"type": "narration", "content": m.group(6)?.trim() ?? ''});
      } else if (m.group(7) != null) {
        scenes.add({
          "type": "dialogue",
          "speaker": m.group(8)?.trim() ?? '',
          "action": m.group(9)?.trim(),
          "content": m.group(10)?.trim() ?? ''
        });
      }
    }
    return scenes;
  }

  // 👇 타입 수정
  StoryChatMessageStructStruct? _createStructFromScene(
      dynamic scene, String text, bool isStreaming) {
    if (scene == null) return null;
    // 👇 타입 수정
    return createStoryChatMessageStructStruct(
      type: scene['type'] ?? 'narration',
      speakerName: scene['speaker'],
      actionText: scene['action'],
      text: text,
      isStreaming: isStreaming,
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
      if (char.name == name) {
        return char.image;
      }
    }
    return null;
  }

  // 👇 타입 수정
  Widget _buildUserMessage(StoryChatMessageStructStruct chatItem) {
    return _buildDialogueMessage(chatItem);
  }

  // 👇 타입 수정
  Widget _buildAiMessage(StoryChatMessageStructStruct chatItem) {
    final messageType = chatItem.type;
    if (messageType == 'narration') {
      return _buildNarration(chatItem);
    } else if (messageType == 'dialogue') {
      return _buildDialogueMessage(chatItem);
    } else if (messageType == 'story_image') {
      return _buildStoryImage(chatItem);
    } else if (messageType == 'thinking') {
      return _buildThinkingIndicator();
    }
    return Container();
  }

  Widget _buildNarration(StoryChatMessageStructStruct message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Text(
        message.text?.trim() ?? '',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Readex Pro',
              color: Color(0xFF8A2BE2),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
            ),
      ),
    );
  }

  Widget _buildDialogueMessage(StoryChatMessageStructStruct chatItem) {
    final isUserMessage = chatItem.type == 'user';

    String speaker = isUserMessage
        ? (widget.userInChatName ?? chatItem.speakerName ?? 'User')
        : (chatItem.speakerName ?? 'Unknown');

    String speakerImage = isUserMessage
        ? (currentUserPhoto)
        : (chatItem.speakerImage ??
            _findCharacterImageByName(
                speaker, widget.preDefinedCharacters ?? []) ??
            'https://cdn-icons-png.flaticon.com/512/12428/12428135.png');

    Color speakerNameColor;
    if (isUserMessage) {
      speakerNameColor = Color(0xFFee8b60);
    } else {
      final isPreDefined =
          widget.preDefinedCharacters?.any((char) => char.name == speaker) ??
              false;
      speakerNameColor = isPreDefined
          ? Color(0xFF4B39EF)
          : FlutterFlowTheme.of(context).primaryText;
    }

    final speakerStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Readex Pro',
          fontWeight: FontWeight.bold,
          color: speakerNameColor,
        );

    // 모든 대화는 이제 왼쪽 정렬
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(speakerImage),
              radius: 12.5,
              onBackgroundImageError: (e, s) {},
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(speaker, style: speakerStyle),
                SizedBox(height: 4.0),
                Text(
                  (chatItem.actionText != null &&
                              chatItem.actionText!.isNotEmpty
                          ? '(${chatItem.actionText}) '
                          : '') +
                      (chatItem.text ?? ''),
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // [수정됨] 생략되었던 함수들 추가
  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(children: [
        SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
        SizedBox(width: 12),
        Text('이야기를 생각하고 있어요...',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                color: FlutterFlowTheme.of(context).secondaryText,
                fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _buildStoryImage(StoryChatMessageStructStruct message) {
    final imageUrl = message.storyImageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(imageUrl, fit: BoxFit.fitWidth),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
