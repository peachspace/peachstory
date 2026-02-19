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

import 'index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:intl/intl.dart';

Future<String> formatStoryTurnHeaderAndBg(
  String scriptTags,
  List<StoryChatMessageStructStruct>? existingMessages,
  List<PlaceStructStruct>? backgrounds,
  List<CharacterStructStruct>? characters,
  String? userName,
  bool isPrologue,
) async {
  var raw = scriptTags.replaceAll('\r\n', '\n').trim();
  if (raw.isEmpty) return raw;

  // {user} 치환
  final u = (userName ?? '').trim();
  if (u.isNotEmpty) raw = raw.replaceAll('{user}', u);

  // TURN_HEADER 제거
  raw = raw
      .replaceAll(
        RegExp(r'\[TURN_HEADER\].*?\[/TURN_HEADER\]\s*', dotAll: true),
        '',
      )
      .trim();

  // 배경 자산: place 이름 + url->place 맵
  final bgNames = <String>{};
  final bgUrlToName = <String, String>{};
  if (backgrounds != null) {
    for (final bg in backgrounds) {
      final name = (bg.place).toString().trim();
      final url = (bg.imageUrl).toString().trim();
      if (name.isNotEmpty) bgNames.add(name);
      if (name.isNotEmpty && url.isNotEmpty) bgUrlToName[url] = name;
    }
  }

  // 조합 자산(능력/감정): PLACE__TAG 만 허용
  final comboNames = <String>{};
  if (characters != null) {
    for (final c in characters) {
      for (final a in (c.abilityStruct ?? <AbilityStructStruct>[])) {
        final place = (a.place).toString().trim();
        final tag = (a.ability).toString().trim();
        final url = (a.imageUrl).toString().trim();
        if (place.isNotEmpty && tag.isNotEmpty && url.isNotEmpty) {
          comboNames.add('${place}__${tag}');
        }
      }
      for (final e in (c.emotionStruct ?? <EmotionStructStruct>[])) {
        final place = (e.place).toString().trim();
        final tag = (e.emotion).toString().trim();
        final url = (e.imageurl).toString().trim();
        if (place.isNotEmpty && tag.isNotEmpty && url.isNotEmpty) {
          comboNames.add('${place}__${tag}');
        }
      }
    }
  }

  // 기존 메시지에서 마지막 배경 장소 추정
  String? lastBgPlace;
  if (!isPrologue && existingMessages != null && existingMessages.isNotEmpty) {
    for (final msg in existingMessages.reversed) {
      if (msg.type == 'story_image') {
        final url = (msg.storyImageUrl).toString().trim();
        if (url.isEmpty) continue;
        final mapped = bgUrlToName[url];
        if (mapped != null && mapped.isNotEmpty) {
          lastBgPlace = mapped;
          break;
        }
      }
    }
  }

  // 토큰 추출
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

  // ✅ 장소 단독 NARRATION 판별(너무 길면 장소로 보지 않음 / 문장부호 있으면 제외)
  bool _looksLikePurePlaceLine(String s) {
    final x = s.trim();
    if (x.isEmpty) return false;
    if (x.length > 60) return false;
    if (RegExp(r'[.!?…"]|\.\.\.').hasMatch(x)) return false;
    if (x.contains('|')) return false;
    if (x.contains('[') || x.contains(']')) return false;
    return true;
  }

  // __PLACE__ 파싱 + "장소만 있는 NARRATION"도 파싱 + 라인 제거
  String? thisPlace;
  final cleanedTokens = <String>[];

  for (int i = 0; i < tokens.length; i++) {
    final t = tokens[i];
    final nm = narRe.firstMatch(t);
    if (nm != null) {
      final content = (nm.group(1) ?? '').trim();

      // (1) __PLACE__ 형식
      if (content.startsWith('__PLACE__')) {
        var p = content.substring('__PLACE__'.length).trim();
        if (p.startsWith('=') || p.startsWith(':')) p = p.substring(1).trim();
        if (p.isNotEmpty) thisPlace = p;
        continue; // ✅ 장소줄 제거
      }

      // (2) 장소만 단독 NARRATION (첫 토큰에서만 인정)
      if (i == 0 && thisPlace == null && _looksLikePurePlaceLine(content)) {
        thisPlace = content;
        continue; // ✅ 장소줄 제거
      }
    }

    cleanedTokens.add(t);
  }

  // AI가 요청한 bg 후보
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

  // 헤더 장소
  final placeForHeader =
      (thisPlace ?? requestedBg ?? lastBgPlace ?? '어딘가').trim();

  String sanitizePlace(String p) {
    var x = p.trim();
    x = x.replaceAll(RegExp(r'[<>]'), '');
    x = x.replaceAll(RegExp(r'[\[\]]'), '');
    x = x.replaceAll(RegExp(r'\s{2,}'), ' ');
    return x.trim();
  }

  final safePlaceRaw = placeForHeader.isEmpty ? '어딘가' : placeForHeader;
  final safePlace =
      sanitizePlace(safePlaceRaw).isEmpty ? '어딘가' : sanitizePlace(safePlaceRaw);

  // 배경 후보는 헤더 장소와 동일할 때만
  String? bgCandidate;
  if (thisPlace != null && thisPlace!.isNotEmpty) {
    bgCandidate = bgNames.contains(safePlace) ? safePlace : null;
  } else {
    bgCandidate = (requestedBg != null && bgNames.contains(requestedBg!))
        ? requestedBg
        : null;
  }

  // 배경 허용: 장소 변경 시 1개
  final shouldShowBg = (() {
    if (bgCandidate == null || bgCandidate!.isEmpty) return false;
    if (isPrologue) return true;
    if (lastBgPlace == null || lastBgPlace!.isEmpty) return true;
    return bgCandidate != lastBgPlace;
  })();

  final bgToShow = shouldShowBg ? bgCandidate : null;

  // SHOW_IMAGE 필터
  final filtered = <String>[];
  bool keptBg = false;
  int keptCombo = 0;
  final keptComboSet = <String>{};
  int keptOther = 0;
  final keptOtherSet = <String>{};

  for (final t in cleanedTokens) {
    final m = imgRe.firstMatch(t);
    if (m != null) {
      final cond = (m.group(1) ?? '').trim();

      final isBg = bgNames.contains(cond);
      final isCombo = comboNames.contains(cond);

      if (!isBg && !isCombo) {
        // 이벤트 같은 "기타"는 1개만 허용
        if (keptOther >= 1) continue;
        if (keptOtherSet.contains(cond)) continue;
        keptOtherSet.add(cond);
        keptOther++;
        filtered.add(t);
        continue;
      }

      if (isBg) {
        if (bgToShow == null) continue;
        if (cond != bgToShow) continue;
        if (keptBg) continue;
        keptBg = true;
        filtered.add(t);
        continue;
      }

      // 조합(능력/감정) 최대 2개
      if (keptComboSet.contains(cond)) continue;
      if (keptCombo >= 2) continue;
      keptComboSet.add(cond);
      keptCombo++;
      filtered.add(t);
      continue;
    }

    filtered.add(t);
  }

  // 배경 자동 삽입
  if (bgToShow != null && bgToShow.isNotEmpty) {
    final tag = '[SHOW_IMAGE="$bgToShow"]';
    final exists = filtered.any((x) => x.trim() == tag);
    if (!exists) filtered.insert(0, tag);
  }

  // 헤더
  final now = DateTime.now();
  final dt = DateFormat('yyyy년 MM월 dd일 HH시 mm분', 'ko_KR').format(now);
  final headerText = '[ $dt | $safePlace ]';

  final body = filtered.join('\n').trim();
  return '[TURN_HEADER]$headerText[/TURN_HEADER]\n$body'.trim();
}
