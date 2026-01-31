// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';

import 'package:intl/intl.dart';

Future<String> formatStoryTurnHeaderAndBg(
  String scriptTags,
  String? userName,
  bool isPrologue,
  List<BackgroundStructStruct>? backgrounds,
) async {
  // 0) 프롤로그면 상태 리셋
  if (isPrologue) {
    FFAppState().storyCurrentPlace = '';
    FFAppState().storyLastBgShownPlace = '';
  }

  var raw = scriptTags.replaceAll('\r\n', '\n').trim();
  if (raw.isEmpty) return raw;

  // 1) {user} 치환
  final u = (userName ?? '').trim();
  if (u.isNotEmpty) {
    raw = raw.replaceAll('{user}', u);
  }

  // 2) 배경 장소명 목록(이미지 없어도 placeName은 자산으로 인정)
  final bgNames = <String>{};
  if (backgrounds != null) {
    for (final bg in backgrounds) {
      final name = (bg.placeName).trim();
      if (name.isNotEmpty) bgNames.add(name);
    }
  }

  // 3) 기존 TURN_HEADER 제거(중복 방지/시스템시간 강제)
  raw = raw
      .replaceAll(
        RegExp(r'\[TURN_HEADER\].*?\[/TURN_HEADER\]\s*', dotAll: true),
        '',
      )
      .trim();

  // 4) 태그 토큰만 뽑기
  final tokenRe = RegExp(
    r'(\[SHOW_IMAGE=".*?"\])'
    r'|(\[NARRATION\].*?\[/NARRATION\])'
    r'|(\[DIALOGUE SPEAKER=".*?"(?: ACTION=".*?")?\].*?\[/DIALOGUE\])',
    dotAll: true,
    multiLine: true,
  );

  final tokens = tokenRe
      .allMatches(raw)
      .map((m) => (m.group(0) ?? '').trim())
      .where((t) => t.isNotEmpty)
      .toList();

  if (tokens.isEmpty) {
    // 태그가 깨졌으면 그대로 반환
    return raw;
  }

  // 5) 이번 턴의 장소 후보: 첫 번째 background SHOW_IMAGE
  final imgRe = RegExp(r'^\[SHOW_IMAGE="(.*?)"\]$');
  String? thisPlace;

  for (final t in tokens) {
    final m = imgRe.firstMatch(t);
    if (m == null) continue;
    final cond = (m.group(1) ?? '').trim();
    if (cond.isNotEmpty && bgNames.contains(cond)) {
      thisPlace = cond;
      break;
    }
  }

  // 6) “장소 유지” 판단(상태 기반)
  final lastShown = FFAppState().storyLastBgShownPlace.trim();
  final currentPlaceBefore = FFAppState().storyCurrentPlace.trim();

  // 장소 갱신
  final currentPlace = (thisPlace ?? currentPlaceBefore).trim();
  if (currentPlace.isNotEmpty) {
    FFAppState().storyCurrentPlace = currentPlace;
  }

  // 배경 출력 여부: 이번 턴에서 배경이 나오고, 이전 배경과 다를 때만 허용
  final shouldAllowBg = (thisPlace != null &&
      thisPlace!.isNotEmpty &&
      (lastShown.isEmpty || thisPlace! != lastShown));

  // 7) 배경 SHOW_IMAGE는 “이번 턴 1개만”, 그리고 “shouldAllowBg 아닐 때는 제거”
  final filtered = <String>[];
  bool keptBackground = false;

  for (final t in tokens) {
    final m = imgRe.firstMatch(t);
    if (m != null) {
      final cond = (m.group(1) ?? '').trim();
      final isBackground = cond.isNotEmpty && bgNames.contains(cond);

      if (isBackground) {
        if (!shouldAllowBg) continue;
        if (keptBackground) continue;
        keptBackground = true;
        filtered.add(t);
        continue;
      }
    }
    filtered.add(t);
  }

  if (keptBackground && thisPlace != null && thisPlace!.isNotEmpty) {
    FFAppState().storyLastBgShownPlace = thisPlace!.trim();
  }

  // 8) 시스템 시간 헤더 생성
  final now = DateTime.now();
  final dt = DateFormat('yyyy년 MM월 dd일 HH시 mm분', 'ko_KR').format(now);
  final placeForHeader = FFAppState().storyCurrentPlace.trim().isEmpty
      ? '어딘가'
      : FFAppState().storyCurrentPlace.trim();
  final headerText = '[ $dt | $placeForHeader ]';

  final body = filtered.join('\n').trim();
  return '[TURN_HEADER]$headerText[/TURN_HEADER]\n$body'.trim();
}
