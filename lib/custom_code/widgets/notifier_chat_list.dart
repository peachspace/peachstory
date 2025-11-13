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

class NotifierChatList extends StatefulWidget {
  const NotifierChatList({
    Key? key,
    this.width,
    this.height,
    this.newResponseScript,
    required this.initialMessages,
    required this.preDefinedCharacters,
    required this.userInChatName,
    // backgroundList 파라미터 삭제됨
    required this.situationalImageList,
    // onBackgroundChange 파라미터 삭제됨
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
    // 화면 로드 시 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(NotifierChatList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 새로운 AI 스크립트가 들어오면 파싱 및 스트리밍 시작
    if (widget.newResponseScript != null &&
        widget.newResponseScript != oldWidget.newResponseScript &&
        widget.newResponseScript!.isNotEmpty) {
      _processAiResponse(widget.newResponseScript!);
    }
    // 초기 메시지 목록이 바뀌었을 때 업데이트
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

  // AI 응답(JSON String)을 파싱하여 메시지 리스트에 순차적으로 추가하는 함수
  Future<void> _processAiResponse(String responseScript) async {
    try {
      setState(() => _isTyping = true);

      // JSON 파싱 (대괄호 등으로 감싸져 있지 않은 경우 처리 등 필요시 로직 추가)
      // 여기서는 단순 JSON 리스트로 가정하거나, custom function을 활용할 수 있습니다.
      // 편의상 responseScript가 Valid JSON List String이라고 가정합니다.
      List<dynamic> scenes = jsonDecode(responseScript);

      for (var scene in scenes) {
        String type = scene['type'] ?? 'narration';
        String content = scene['content'] ?? '';
        String speaker = scene['speaker'] ?? '';
        String action = scene['action'] ?? '';
        String condition = scene['condition'] ?? '';

        // 배경 변경(set_background) 로직은 삭제됨

        // 메시지 구조체 생성
        StoryChatMessageStructStruct newMessage = StoryChatMessageStructStruct(
          type: type,
          text: content,
          speakerName: speaker,
          actionText: action,
          isStreaming: false, // 타이핑 효과가 필요하면 true로 설정 후 별도 로직 구현
        );

        // 캐릭터 이미지 찾기
        if (type == 'dialogue') {
          // custom function 활용 또는 직접 찾기
          var char = widget.preDefinedCharacters.firstWhere(
            (c) => c.name == speaker,
            orElse: () => CharacterStructStruct(image: ''),
          );
          newMessage.speakerImage = char.image;
        } else if (type == 'show_image') {
          // 상황 이미지 찾기
          // (custom function: findSituationalImageUrlByCondition 로직 내장)
          var sitImg = widget.situationalImageList.firstWhere(
            (s) => s.condition == condition,
            orElse: () => SituationalImageStructStruct(imageUrl: ''),
          );
          newMessage.storyImageUrl = sitImg.imageUrl;
        }

        // 메시지 추가 및 딜레이 (자연스러운 연출을 위해)
        if (mounted) {
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        }
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // 턴 종료 콜백 호출
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
      // 배경색은 투명하게 하여 상위 위젯의 배경색을 따르게 함
      color: Colors.transparent,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length) {
            // 로딩 인디케이터 (Typing...)
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
                  color: const Color(0xFFFFD1BA), // 유저 말풍선 색상
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

    // 2. 나레이션 (일반적 설명/묘사)
    // [요청사항 반영] 기울기 제거, 검은색(연하게), 크기 작게
    else if (message.type == 'narration') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
        child: Text(
          message.text,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                color: const Color(0xFF4A4A4A), // 검은색보다 약간 연한 진회색
                fontSize: 13.0, // 대사보다 약간 작게
                fontWeight: FontWeight.normal, // 기울기 없음 (Normal)
                fontStyle: FontStyle.normal, // 확실하게 Normal로 지정
                lineHeight: 1.5,
              ),
        ),
      );
    }

    // 3. 캐릭터 대사
    else if (message.type == 'dialogue') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [요청사항 반영] 원형 -> 둥근 사각형 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0), // 둥근 사각형 (반경 12)
              child: Image.network(
                message.speakerImage != null && message.speakerImage.isNotEmpty
                    ? message.speakerImage
                    : 'https://via.placeholder.com/150', // 기본 이미지
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
                  // 캐릭터 이름
                  Text(
                    message.speakerName,
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily: 'Inter',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // 말풍선
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
                        // (선택 사항) 지문/행동 묘사가 있다면 작게 표시
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

    // 4. 이미지 보여주기 (show_image)
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
