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

import 'package:intl/intl.dart';

Future<String> formatStoryTurnHeaderAndBg(
  String scriptTags,
  List<StoryChatMessageStructStruct>? existingMessages,
  List<BackgroundStructStruct>? backgrounds,
  List<CharacterStructStruct>? characters,
  String? userName,
  bool isPrologue,
) async {
  var raw = scriptTags.replaceAll('\r\n', '\n').trim();
  if (raw.isEmpty) return raw;

  // 1) {user} 치환
  final u = (userName ?? '').trim();
  if (u.isNotEmpty) {
    raw = raw.replaceAll('{user}', u);
  }

  // 2) TURN_HEADER 중복 0%: 있으면 제거
  raw = raw
      .replaceAll(
        RegExp(r'\[TURN_HEADER\].*?\[/TURN_HEADER\]\s*', dotAll: true),
        '',
      )
      .trim();

  // 3) 배경 자산 목록 + URL->placeName 맵
  final bgNames = <String>{};
  final bgUrlToName = <String, String>{};
  if (backgrounds != null) {
    for (final bg in backgrounds) {
      final name = (bg.placeName).trim();
      final url = (bg.imageUrl).trim();
      if (name.isNotEmpty) bgNames.add(name);
      if (name.isNotEmpty && url.isNotEmpty) bgUrlToName[url] = name;
    }
  }

  // 4) 상황 자산 목록
  final situationNames = <String>{};
  if (characters != null) {
    for (final c in characters) {
      for (final s in c.situationImages) {
        final cond = (s.condition).trim();
        if (cond.isNotEmpty) situationNames.add(cond);
      }
    }
  }

  // 5) 기존 메시지에서 마지막 배경 장소 추정
  String? lastBgPlace;
  if (!isPrologue && existingMessages != null && existingMessages.isNotEmpty) {
    for (final msg in existingMessages.reversed) {
      if (msg.type == 'story_image') {
        final url = (msg.storyImageUrl).trim();
        if (url.isEmpty) continue;
        final mapped = bgUrlToName[url];
        if (mapped != null && mapped.isNotEmpty) {
          lastBgPlace = mapped;
          break;
        }
      }
    }
  }

  // 6) 토큰 추출
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
    final now = DateTime.now();
    final dt = DateFormat('yyyy년 MM월 dd일 HH시 mm분', 'ko_KR').format(now);
    final headerText = '[ $dt | ${lastBgPlace ?? '어딘가'} ]';
    return '[TURN_HEADER]$headerText[/TURN_HEADER]\n[NARRATION]$raw[/NARRATION]';
  }

  final imgRe = RegExp(r'^\[SHOW_IMAGE="(.*?)"\]$');
  final narRe = RegExp(r'^\[NARRATION\](.*?)\[/NARRATION\]$', dotAll: true);

  // 7) __PLACE__ 파싱 + 해당 라인 제거
  String? thisPlace;
  final cleanedTokens = <String>[];

  for (final t in tokens) {
    final nm = narRe.firstMatch(t);
    if (nm != null) {
      final content = (nm.group(1) ?? '').trim();
      if (content.startsWith('__PLACE__')) {
        var p = content.substring('__PLACE__'.length).trim();
        if (p.startsWith('=') || p.startsWith(':')) p = p.substring(1).trim();
        if (p.isNotEmpty) thisPlace = p;
        continue; // __PLACE__ 라인은 화면에 표시하지 않음
      }
    }
    cleanedTokens.add(t);
  }

  // 8) AI가 요청한 bg 후보 (SHOW_IMAGE 중 bgNames에 있는 첫 번째)
  String? requestedBg;
  for (final t in cleanedTokens) {
    final m = imgRe.firstMatch(t);
    if (m == null) continue;
    final cond = (m.group(1) ?? '').trim();
    if (bgNames.contains(cond)) {
      requestedBg = cond;
      break;
    }
  }

  // 9) 헤더 장소 100%: __PLACE__ > (requestedBg) > lastBgPlace > 어딘가
  //    단, __PLACE__가 있으면 그게 최우선
  final placeForHeader =
      (thisPlace ?? requestedBg ?? lastBgPlace ?? '어딘가').trim();
  final safePlace = placeForHeader.isEmpty ? '어딘가' : placeForHeader;

  // ✅ 핵심: 배경 후보는 "헤더 장소(safePlace)와 동일"할 때만 인정
  // - __PLACE__가 있으면: 배경은 safePlace가 자산에 있을 때만
  // - __PLACE__가 없으면: requestedBg를 배경으로 쓸 수 있음
  String? bgCandidate;
  if (thisPlace != null && thisPlace!.isNotEmpty) {
    bgCandidate = bgNames.contains(safePlace) ? safePlace : null;
  } else {
    bgCandidate = (requestedBg != null && bgNames.contains(requestedBg!))
        ? requestedBg
        : null;
  }

  // 10) 배경 허용: 장소 바뀔 때만 1개 (프롤로그는 1개 허용)
  final shouldShowBg = (() {
    if (bgCandidate == null || bgCandidate!.isEmpty) return false;
    if (isPrologue) return true;
    if (lastBgPlace == null || lastBgPlace!.isEmpty) return true;
    return bgCandidate != lastBgPlace;
  })();

  final bgToShow = shouldShowBg ? bgCandidate : null;

  // 11) SHOW_IMAGE 하드 필터
  // - 배경은 bgToShow만 1개 허용
  // - 상황은 자산에 있을 때만 허용 (최대 2개 + 중복 제거)
  final filtered = <String>[];
  bool keptBg = false;

  int keptSitCount = 0;
  final keptSitSet = <String>{};

  for (final t in cleanedTokens) {
    final m = imgRe.firstMatch(t);
    if (m != null) {
      final cond = (m.group(1) ?? '').trim();
      final isBg = bgNames.contains(cond);
      final isSit = situationNames.contains(cond);

      if (!isBg && !isSit) continue;

      if (isBg) {
        if (bgToShow == null) continue;
        if (cond != bgToShow) continue;
        if (keptBg) continue;
        keptBg = true;
        filtered.add(t);
        continue;
      }

      // 상황
      if (keptSitSet.contains(cond)) continue;
      if (keptSitCount >= 2) continue;
      keptSitSet.add(cond);
      keptSitCount++;
      filtered.add(t);
      continue;
    }

    filtered.add(t);
  }

  // 12) 배경 자동 삽입: bgToShow가 있는데 태그가 없으면 맨 위에 넣기
  if (bgToShow != null && bgToShow.isNotEmpty) {
    final tag = '[SHOW_IMAGE="$bgToShow"]';
    final exists = filtered.any((x) => x.trim() == tag);
    if (!exists) {
      filtered.insert(0, tag);
    }
  }

  // 13) 시스템 시간 헤더 생성
  final now = DateTime.now();
  final dt = DateFormat('yyyy년 MM월 dd일 HH시 mm분', 'ko_KR').format(now);
  final headerText = '[ $dt | $safePlace ]';

  final body = filtered.join('\n').trim();
  return '[TURN_HEADER]$headerText[/TURN_HEADER]\n$body'.trim();
}
