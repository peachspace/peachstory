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
import 'package.flutter/material.dart';

import 'dart:async';
import 'dart:convert';

class NotifierChatList extends StatefulWidget {
  const NotifierChatList({
    Key? key,
    this.width,
    this.height,
    this.newResponseScript,
    required this.initialMessages,
    required this.preDefinedCharacters,
    required this.userInChatName,
    // [삭제됨] backgroundList 파라미터
    required this.situationalImageList,
    // [삭제됨] onBackgroundChange 파라미터
    required this.onTurnComplete,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? newResponseScript;
  final List<StoryChatMessageStructStruct> initialMessages;
  final List<CharacterStructStruct> preDefinedCharacters;
  final String? userInChatName;
  final List<SituationalImageStructStruct> situationalImageList;
  final Future<dynamic> Function(List<dynamic>? scenes) onTurnComplete;

  @override
  _NotifierChatListState createState() => _NotifierChatListState();
}

class _NotifierChatListState extends State<NotifierChatList> {
  final ScrollController _scrollController = ScrollController();
  List<StoryChatMessageStructStruct> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.initialMessages);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(NotifierChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.newResponseScript != null &&
        widget.newResponseScript != oldWidget.newResponseScript &&
        widget.newResponseScript!.isNotEmpty) {
      _processAiResponse(widget.newResponseScript!);
    }
    if (widget.initialMessages.length != oldWidget.initialMessages.length) {
      setState(() {
        _messages = List.from(widget.initialMessages);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _processAiResponse(String responseScript) async {
    try {
      setState(() => _isTyping = true);
      List<dynamic> scenes = jsonDecode(responseScript);

      for (var scene in scenes) {
        String type = scene['type'] ?? 'narration';

        // [삭제됨] 배경 변경 로직
        // if (type == 'set_background') {
        //   ...
        //   continue;
        // }

        String content = scene['content'] ?? '';
        String speaker = scene['speaker'] ?? '';
        String action = scene['action'] ?? '';
        String condition = scene['condition'] ?? '';

        StoryChatMessageStructStruct newMessage = StoryChatMessageStructStruct(
          type: type,
          text: content,
          speakerName: speaker,
          actionText: action,
          isStreaming: false,
        );

        if (type == 'dialogue') {
          var char = widget.preDefinedCharacters.firstWhere(
            (c) => c.name == speaker,
            orElse: () => CharacterStructStruct(image: ''),
          );
          newMessage.speakerImage = char.image;
        } else if (type == 'show_image') {
          var sitImg = widget.situationalImageList.firstWhere(
            (s) => s.condition == condition,
            orElse: () => SituationalImageStructStruct(imageUrl: ''),
          );
          newMessage.storyImageUrl = sitImg.imageUrl;
        }

        if (mounted) {
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        }
        await Future.delayed(const Duration(milliseconds: 800));
      }

      if (mounted) {
        setState(() => _isTyping = false);
        widget.onTurnComplete(scenes);
      }
    } catch (e) {
      print('Error parsing AI response: $e');
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.transparent,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFFFD1BA))),
              ),
            );
          }
          final msg = _messages[index];
          return _buildMessageItem(msg);
        },
      ),
    );
  }

  Widget _buildMessageItem(StoryChatMessageStructStruct message) {
    // 1. 유저 메시지
    if (message.type == 'user') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1BA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.text,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // 2. 나레이션 (디자인 수정됨)
    else if (message.type == 'narration') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
        child: Text(
          message.text,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                color: const Color(0xFF4A4A4A), // 연한 검은색
                fontSize: 13.0, // 크기 축소
                fontStyle: FontStyle.normal, // 기울임 제거
                lineHeight: 1.5,
              ),
        ),
      );
    }
    // 3. 캐릭터 대사 (디자인 수정됨)
    else if (message.type == 'dialogue') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [수정됨] 원형 -> 둥근 사각형 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                message.speakerImage != null && message.speakerImage.isNotEmpty
                    ? message.speakerImage
                    : 'https://via.placeholder.com/150',
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.speakerName,
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily: 'Inter',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E3E7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.actionText != null &&
                            message.actionText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              "(${message.actionText})",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        Text(
                          message.text,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    color: Colors.black87,
                                    fontSize: 15.0,
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
    // 4. 상황 이미지 (유지)
    else if (message.type == 'story_image' || message.type == 'show_image') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            message.storyImageUrl ?? '',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: Center(
                    child: Icon(Icons.broken_image, color: Colors.grey))),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
