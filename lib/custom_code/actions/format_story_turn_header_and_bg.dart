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

  // 사용하지 않아도 시그니처 호환을 위해 유지
  backgrounds;

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

  // 조합 자산(능력/감정): tag + imageUrl 기준만 사용 (place 미사용)
  final imageTags = <String>{};
  if (characters != null) {
    for (final c in characters) {
      for (final a in (c.abilityStruct ?? <AbilityStructStruct>[])) {
        final tag = (a.ability).toString().trim();
        final url = (a.imageUrl).toString().trim();
        if (tag.isNotEmpty && url.isNotEmpty) {
          imageTags.add(tag);
        }
      }
      for (final e in (c.emotionStruct ?? <EmotionStructStruct>[])) {
        final tag = (e.emotion).toString().trim();
        final url = (e.imageurl).toString().trim();
        if (tag.isNotEmpty && url.isNotEmpty) {
          imageTags.add(tag);
        }
      }
    }
  }

  String? _extractPlaceFromHeader(String text) {
    final m = RegExp(r'\|\s*(.*?)\s*\]$').firstMatch(text.trim());
    final place = (m?.group(1) ?? '').trim();
    return place.isEmpty ? null : place;
  }

  // 기존 메시지에서 마지막 헤더 장소 추정
  String? lastPlace;
  if (!isPrologue && existingMessages != null && existingMessages.isNotEmpty) {
    for (final msg in existingMessages.reversed) {
      if (msg.type == 'turn_header') {
        final parsed = _extractPlaceFromHeader(msg.text);
        if (parsed != null) {
          lastPlace = parsed;
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
    final headerText = '[ $dt | ${lastPlace ?? '어딘가'} ]';
    return '[TURN_HEADER]$headerText[/TURN_HEADER]\n[NARRATION]$raw[/NARRATION]';
  }

  final imgRe = RegExp(r'^\[SHOW_IMAGE="(.*?)"\]$');
  final narRe = RegExp(r'^\[NARRATION\](.*?)\[/NARRATION\]$', dotAll: true);
  final diaRe = RegExp(
    r'^\[DIALOGUE SPEAKER=".*?"(?: ACTION=".*?")?\](.*?)\[/DIALOGUE\]$',
    dotAll: true,
  );

  bool _hasTransitionCue(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    return RegExp(
      r'(잠시 뒤|몇 분 뒤|다음 날|그날 저녁|한편|장면 전환|이동|옮기|향하|걸어|뛰어|복도로|교실로|학생부실로|밖으로|안으로|도착)',
    ).hasMatch(t);
  }

  String _tokenContent(String token) {
    final n = narRe.firstMatch(token);
    if (n != null) return (n.group(1) ?? '').trim();
    final d = diaRe.firstMatch(token);
    if (d != null) return (d.group(1) ?? '').trim();
    return '';
  }

  String _stripTags(String s) {
    return s
        .replaceAll(RegExp(r'\[/?[A-Z_]+(?: [^\]]+)?\]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _normalizeImageTag(String cond) {
    final trimmed = cond.trim();
    if (trimmed.contains('__')) {
      final parts = trimmed.split('__');
      return parts.last.trim();
    }
    return trimmed;
  }

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

  final combinedTokenText =
      cleanedTokens.map(_tokenContent).where((e) => e.isNotEmpty).join('\n');

  String? effectivePlace = thisPlace?.trim();
  if (!isPrologue &&
      effectivePlace != null &&
      effectivePlace.isNotEmpty &&
      lastPlace != null &&
      lastPlace.isNotEmpty &&
      effectivePlace != lastPlace &&
      !_hasTransitionCue(combinedTokenText)) {
    effectivePlace = lastPlace;
  }

  // 헤더 장소
  final placeForHeader = (effectivePlace ?? lastPlace ?? '어딘가').trim();

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

  // SHOW_IMAGE 필터
  final filtered = <String>[];
  final keptImageTags = <String>{};
  int keptOther = 0;
  final keptOtherSet = <String>{};

  for (final t in cleanedTokens) {
    final m = imgRe.firstMatch(t);
    if (m != null) {
      final cond = (m.group(1) ?? '').trim();
      final normalizedTag = _normalizeImageTag(cond);

      final isImageTag = imageTags.contains(normalizedTag);

      if (!isImageTag) {
        // 이벤트 같은 "기타"는 1개만 허용
        if (keptOther >= 1) continue;
        if (keptOtherSet.contains(cond)) continue;
        keptOtherSet.add(cond);
        keptOther++;
        filtered.add(t);
        continue;
      }

      // 능력/감정 태그는 최대 2개, 중복 금지, place 접두어 제거한 canonical 태그로 통일
      if (keptImageTags.contains(normalizedTag)) continue;
      if (keptImageTags.length >= 2) continue;
      keptImageTags.add(normalizedTag);
      filtered.add('[SHOW_IMAGE="$normalizedTag"]');
      continue;
    }

    filtered.add(t);
  }

  // 헤더
  final now = DateTime.now();
  final dt = DateFormat('yyyy년 MM월 dd일 HH시 mm분', 'ko_KR').format(now);
  final headerText = '[ $dt | $safePlace ]';

  var body = filtered.join('\n').trim();
  final plainBody = _stripTags(body);

  if (body.isEmpty || plainBody.isEmpty) {
    body =
        '[NARRATION]$safePlace의 공기가 잠시 무겁게 가라앉았다. 누구도 쉽게 다음 말을 잇지 못했고, 방금 벌어진 일의 여운이 남아 있었다.[/NARRATION]';
  } else if (plainBody.length < 120) {
    body =
        '$body\n[NARRATION]짧은 침묵 끝에, 방금의 선택이 앞으로의 관계를 바꿀 수 있다는 예감이 천천히 번져 갔다.[/NARRATION]';
  }

  return '[TURN_HEADER]$headerText[/TURN_HEADER]\n$body'.trim();
}
