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
import 'package:flutter/scheduler.dart';
import '/auth/firebase_auth/auth_util.dart';

/// 캐릭터챗 전용으로 NotifierChatList를 수정한 위젯입니다.
class CharacterChatDirector extends StatefulWidget {
  const CharacterChatDirector({
    super.key,
    this.width,
    this.height,
    this.initialMessages,
    required this.newResponseScript,
    required this.characterDoc,
    this.onTurnComplete,
  });

  final double? width;
  final double? height;
  final List<CharacterChatMessageStructStruct>? initialMessages;
  final String newResponseScript;
  final CharacterRecord? characterDoc; // 스토리 대신 캐릭터 정보를 받습니다.
  final Future<dynamic> Function(List<dynamic>? scenes)? onTurnComplete;

  @override
  State<CharacterChatDirector> createState() => _CharacterChatDirectorState();
}

class _CharacterChatDirectorState extends State<CharacterChatDirector> {
  late ValueNotifier<List<dynamic>> _messagesNotifier;
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _scenes = [];

  @override
  void initState() {
    super.initState();
    _messagesNotifier = ValueNotifier(List.from(widget.initialMessages ?? []));
    _messagesNotifier.addListener(_scrollToBottom);
  }

  @override
  void didUpdateWidget(covariant CharacterChatDirector oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newMsgs = widget.initialMessages ?? [];
    if (newMsgs.length > _messagesNotifier.value.length) {
      final newItems = newMsgs.sublist(_messagesNotifier.value.length);
      _messagesNotifier.value = [..._messagesNotifier.value, ...newItems];
    }

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

  void _startDirecting() async {
    if (!mounted) return;
    _scenes = _parseScriptIntoScenes(widget.newResponseScript);
    if (_scenes.isEmpty) return;

    final aiTurnPlaceholder = {
      'type': 'ai_turn',
      'isStreaming': true,
      'scenes': [],
    };
    _messagesNotifier.value = [..._messagesNotifier.value, aiTurnPlaceholder];
    await _processNextScene(0);
  }

  Future<void> _processNextScene(int sceneIndex) async {
    if (!mounted || sceneIndex >= _scenes.length) {
      final currentList = _messagesNotifier.value;
      if (currentList.isNotEmpty) {
        final lastItem = currentList.last;
        if (lastItem is Map && lastItem['type'] == 'ai_turn') {
          lastItem['isStreaming'] = false;
          _messagesNotifier.value = List.from(currentList);
        }
      }
      if (widget.onTurnComplete != null) {
        SchedulerBinding.instance
            .addPostFrameCallback((_) => widget.onTurnComplete!(_scenes));
      }
      return;
    }

    final scene = _scenes[sceneIndex];
    final type = scene['type'] ?? 'dialogue';

    if (type == 'show_image') {
      _addSceneToTurn(scene);
      await Future.delayed(const Duration(milliseconds: 300));
      await _processNextScene(sceneIndex + 1);
    } else {
      await _animateTextScene(scene);
      await _processNextScene(sceneIndex + 1);
    }
  }

  Future<void> _animateTextScene(dynamic scene) async {
    final String fullText = scene['content'] ?? '';
    final textScene = {'type': 'dialogue', 'content': ''};
    _addSceneToTurn(textScene);

    for (int i = 0; i <= fullText.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 50));
      _updateLastSceneInTurn(
          {'type': 'dialogue', 'content': fullText.substring(0, i)});
    }
  }

  void _addSceneToTurn(Map<String, dynamic> scene) {
    if (!mounted) return;
    final currentList = _messagesNotifier.value;
    if (currentList.isEmpty) return;
    final lastItem = currentList.last;
    if (lastItem is Map && lastItem['type'] == 'ai_turn') {
      final scenesList = lastItem['scenes'] as List;
      scenesList.add(scene);
      _messagesNotifier.value = List.from(currentList);
    }
  }

  void _updateLastSceneInTurn(Map<String, dynamic> scene) {
    if (!mounted) return;
    final currentList = _messagesNotifier.value;
    if (currentList.isEmpty) return;
    final lastItem = currentList.last;
    if (lastItem is Map && lastItem['type'] == 'ai_turn') {
      final scenesList = lastItem['scenes'] as List;
      if (scenesList.isNotEmpty) {
        scenesList.last = scene;
        _messagesNotifier.value = List.from(currentList);
      }
    }
  }

  List<dynamic> _parseScriptIntoScenes(String scriptText) {
    final List<dynamic> scenes = [];
    final RegExp exp = RegExp(r'(\[SHOW_IMAGE="([^"]*)"\])');
    int lastIndex = 0;

    exp.allMatches(scriptText).forEach((match) {
      String textBeforeTag = scriptText.substring(lastIndex, match.start);
      if (textBeforeTag.trim().isNotEmpty) {
        scenes.add({"type": "dialogue", "content": textBeforeTag.trim()});
      }
      scenes.add(
          {"type": "show_image", "condition": match.group(2)?.trim() ?? ''});
      lastIndex = match.end;
    });

    if (lastIndex < scriptText.length) {
      String remainingText = scriptText.substring(lastIndex);
      if (remainingText.trim().isNotEmpty) {
        scenes.add({"type": "dialogue", "content": remainingText.trim()});
      }
    }
    if (scenes.isEmpty && scriptText.isNotEmpty) {
      scenes.add({"type": "dialogue", "content": scriptText});
    }
    return scenes;
  }

  String? findSituationalImageUrlByCondition(
      String condition, List<SituationalImageStructStruct> imageList) {
    for (final img in imageList) {
      if (img.condition == condition) return img.imageUrl;
    }
    return null;
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
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: _messagesNotifier,
      builder: (context, messages, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final item = messages[index];
            if (item is CharacterChatMessageStructStruct) {
              if (item.type == 'user') return _buildUserMessage(item);
              if (item.type == 'thinking') return _buildThinkingIndicator();
            } else if (item is Map && item['type'] == 'ai_turn') {
              return _buildAiTurnBubble(item['scenes'] as List<dynamic>);
            }
            return Container(height: 15); // separator
          },
        );
      },
    );
  }

  Widget _buildUserMessage(CharacterChatMessageStructStruct chatItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: AlignmentDirectional(1, 0),
        child: Container(
          constraints: BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).accent3,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
              topLeft: Radius.circular(15),
              topRight: Radius.circular(0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              chatItem.text ?? '',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiTurnBubble(List<dynamic> scenes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.characterDoc?.characterimage ??
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/peach-story-w80s31/assets/uprrd005zh3i/peach_icon.png',
                  ),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text(
                  widget.characterDoc?.name ?? '캐릭터',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Align(
            alignment: AlignmentDirectional(-1, 0),
            child: Padding(
              padding: EdgeInsets.only(left: 58, right: 8),
              child: Container(
                constraints: BoxConstraints(maxWidth: 250),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: scenes.map<Widget>((scene) {
                    final type = scene['type'];
                    if (type == 'dialogue') {
                      return Text(
                        scene['content'] ?? '',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      );
                    } else if (type == 'show_image') {
                      final imageUrl = findSituationalImageUrlByCondition(
                          scene['condition'] ?? '',
                          widget.characterDoc?.situationalImages.toList() ??
                              []);
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(imageUrl),
                          ),
                        );
                      }
                    }
                    return Container();
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 58),
        SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
        SizedBox(width: 12),
        Text('생각 중...',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                color: FlutterFlowTheme.of(context).secondaryText,
                fontStyle: FontStyle.italic)),
      ]),
    );
  }
}
