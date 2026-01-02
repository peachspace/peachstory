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

    if (widget.initialMessages != null && !_isTyping) {
      final parentList = widget.initialMessages!;
      final currentList = _messagesNotifier.value;
      bool shouldUpdate = false;

      if (parentList.length != currentList.length) {
        shouldUpdate = true;
      } else if (parentList.isNotEmpty && currentList.isNotEmpty) {
        final p = parentList.last;
        final c = currentList.last;
        // [중요] 텍스트 뿐만 아니라 이미지 URL, 스피커 이름 등이 바뀌어도 업데이트
        if (p.text != c.text ||
            p.type != c.type ||
            p.storyImageUrl != c.storyImageUrl || // 상황 이미지 URL 변경 감지
            p.speakerName != c.speakerName) {
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

    // 중복 제거 로직 생략 (필요시 추가)
    _currentSceneIndex = 0;
    _processNextScene();
  }

  void _processNextScene() async {
    if (!mounted || _currentSceneIndex >= _scenes.length) {
      setState(() => _isTyping = false);
      if (widget.onTurnComplete != null) {
        await widget.onTurnComplete!(_scenes);
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
          type: 'story_image', // ★ [중요] 화면 표시용 타입
          storyImageUrl: imageUrl,
          isStreaming: false,
          text: '',
          speakerName: '',
          actionText: '',
          speakerImage: '',
        );
        _messagesNotifier.value = [..._messagesNotifier.value, imageMessage];
        _jumpToBottom();
        await Future.delayed(const Duration(milliseconds: 800)); // 이미지 감상 시간
      }
      _processNextScene();
    } else if (type == 'narration' || type == 'dialogue') {
      await _animateTextScene(scene);
      if (mounted) _processNextScene();
    } else {
      _processNextScene();
    }
  }

  Future<void> _animateTextScene(dynamic scene) async {
    // 1. 빈 메시지 생성 (자리 잡기)
    final placeholder = _createStructFromScene(scene, '', true);
    if (placeholder == null) return;

    _messagesNotifier.value = [..._messagesNotifier.value, placeholder];
    _jumpToBottom();

    final String content = scene['content'] ?? '';

    // 2. 타이핑 애니메이션
    for (int i = 0; i <= content.length; i++) {
      if (!mounted) return;
      // 속도 조절 (너무 느리면 답답함)
      await Future.delayed(const Duration(milliseconds: 15));

      final currentList =
          List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
      if (currentList.isEmpty) return;

      final updatedMessage =
          _createStructFromScene(scene, content.substring(0, i), true);

      if (updatedMessage != null) {
        currentList[currentList.length - 1] = updatedMessage;
        _messagesNotifier.value = currentList;
        if (i % 30 == 0) _jumpToBottom(); // 스크롤 빈도 조절
      }
    }

    // 3. 최종 완성 (Streaming false)
    final currentList =
        List<StoryChatMessageStructStruct>.from(_messagesNotifier.value);
    final finalMessage = _createStructFromScene(scene, content, false);
    if (finalMessage != null) {
      currentList[currentList.length - 1] = finalMessage;
      _messagesNotifier.value = currentList;
    }
    _jumpToBottom();
    await Future.delayed(const Duration(milliseconds: 200));
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
              if (chatItem.text == '생각 중' || chatItem.type == 'thinking') {
                return _buildThinkingIndicator();
              }
              // 유저 메시지 (오른쪽 정렬)
              return _buildDialogueMessage(chatItem, isUser: true);
            } else if (chatItem.type == 'thinking') {
              return _buildThinkingIndicator();
            } else {
              // AI 메시지 (왼쪽 정렬)
              return _buildAiMessage(chatItem);
            }
          },
        );
      },
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: Alignment.centerLeft, // AI가 생각할 땐 왼쪽
        child: FadeTransition(
          opacity: _loadingAnimation,
          child: Text(
            "생각하는 중...",
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
      ),
    );
  }

  // ★ [핵심 1] Scene에서 데이터 파싱 (Action=감정 저장)
  StoryChatMessageStructStruct? _createStructFromScene(
      dynamic scene, String text, bool isStreaming) {
    if (scene == null) return null;

    final String type = (scene['type'] ?? 'narration').toString();
    final String speaker = (scene['speaker'] ?? '').toString();
    // Action 필드를 가져와서 actionText에 저장 (이게 감정 키가 됨)
    final String action = (scene['action'] ?? '').toString();

    return createStoryChatMessageStructStruct(
      type: type,
      speakerName: speaker,
      actionText: action, // 감정 정보 저장!
      text: text,
      isStreaming: isStreaming,
      storyImageUrl: '',
      // 이미지를 미리 찾아서 저장 (Helper 함수 사용)
      speakerImage: _resolveCharacterImageUrl(speaker, action) ?? '',
    );
  }

  // ★ [핵심 2] 감정에 맞는 이미지 URL 찾기 Helper 함수
  String? _resolveCharacterImageUrl(String speakerName, String? emotionKey) {
    final name = speakerName.trim();
    if (name.isEmpty) return null;

    // 1. 캐릭터 찾기
    final characters = widget.preDefinedCharacters ?? [];
    CharacterStructStruct? character;
    try {
      character = characters.firstWhere((c) => c.name.trim() == name);
    } catch (_) {
      return null;
    }

    // 2. 감정(Action) 매칭 -> 감정 이미지 반환
    final key = (emotionKey ?? '').trim();
    if (key.isNotEmpty) {
      // emotion_images 리스트 순회 (Firestore 구조체 필드명 확인 필요: emotionImages or emotion_images)
      for (final e in character.emotionImages) {
        if (e.emotionLabel.trim() == key) {
          // URL 유효성 체크
          if (e.image != null && e.image.startsWith('http')) {
            return e.image;
          }
        }
      }
    }

    // 3. 실패 시 기본 프로필 반환
    if (character.imageUrl != null && character.imageUrl!.startsWith('http')) {
      return character.imageUrl;
    }
    return character.image; // 로컬 경로라도 반환
  }

  // ★ [핵심 3] 대화 메시지 UI (아바타 이미지 추가)
  Widget _buildDialogueMessage(StoryChatMessageStructStruct chatItem,
      {String? overrideSpeaker, String? overrideImage, bool isUser = false}) {
    final speaker =
        isUser ? (widget.userInChatName ?? '나') : chatItem.speakerName;

    // 이미지 URL 결정
    String avatarUrl = '';
    if (isUser) {
      // 유저 이미지 (현재 유저 사진이 없으면 빈 값)
      avatarUrl = overrideImage ?? '';
    } else {
      // AI: 이미 파싱된 speakerImage 사용 (없으면 다시 조회)
      avatarUrl = chatItem.speakerImage;
      if (avatarUrl.isEmpty) {
        avatarUrl = _resolveCharacterImageUrl(
                chatItem.speakerName, chatItem.actionText) ??
            '';
      }
    }

    // 아바타 위젯
    Widget avatarWidget;
    if (avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
      avatarWidget = CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {}, // 에러 시 투명 처리
        backgroundColor: Colors.transparent,
      );
    } else {
      // 이미지가 없으면 첫 글자 아이콘
      avatarWidget = CircleAvatar(
        radius: 20,
        backgroundColor: isUser ? Colors.blue[100] : Colors.grey[300],
        child: Text(speaker.isNotEmpty ? speaker[0] : '?',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 아바타 (왼쪽)
          if (!isUser) avatarWidget,
          if (!isUser) const SizedBox(width: 12),

          // 말풍선 + 이름
          Flexible(
            // Expanded 대신 Flexible 사용 (텍스트 길이에 맞춤)
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  speaker,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: isUser ? Colors.black87 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                ),
                const SizedBox(height: 4),
                // 말풍선 디자인 (선택 사항)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Color(0xFFFFD1BA)
                        : Colors.white, // 유저는 살구색, AI는 흰색
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft:
                          isUser ? Radius.circular(16) : Radius.circular(0),
                      bottomRight:
                          isUser ? Radius.circular(0) : Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1))
                    ],
                  ),
                  child: Text(
                    chatItem.text,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: Colors.black87,
                          fontSize: 15.0,
                          lineHeight: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),

          if (isUser) const SizedBox(width: 12),
          // 유저 아바타 (오른쪽)
          if (isUser) avatarWidget,
        ],
      ),
    );
  }

  Widget _buildNarration(StoryChatMessageStructStruct message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        width: double.infinity,
        child: Text(
          message.text, // 나레이션 내용
          textAlign: TextAlign.center, // 가운데 정렬
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                color: Color(0xFF666666),
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
                lineHeight: 1.6,
              ),
        ),
      ),
    );
  }

  Widget _buildStoryImage(StoryChatMessageStructStruct chatItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          chatItem.storyImageUrl,
          width: double.infinity,
          height: 250, // 높이 고정 (선택 사항)
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(
                height: 250,
                color: Colors.grey[200],
                child: Center(child: CircularProgressIndicator()));
          },
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          ),
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
    // ... (기존 파싱 로직 유지)
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
            "action": m.group(7)?.trim(), // Action 캡처
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
