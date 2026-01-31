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
  List<CharacterStructStruct>? characters, // ✅ 상황 자산 하드필터용
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

  // 2) TURN_HEADER 제거 (중복 방지)
  raw = raw
      .replaceAll(
        RegExp(r'\[TURN_HEADER\].*?\[/TURN_HEADER\]\s*', dotAll: true),
        '',
      )
      .trim();

  // 3) 배경 자산(placeName) + url->placeName 맵
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

  // 4) 상황 자산(condition) 목록 만들기
  final situationNames = <String>{};
  if (characters != null) {
    for (final c in characters) {
      for (final s in c.situationImages) {
        final cond = (s.condition).trim();
        if (cond.isNotEmpty) situationNames.add(cond);
      }
    }
  }

  // 5) 기존 메시지에서 "마지막 장소" 추정 (우선순위: turn_header > story_image(background url))
  String? lastPlace;

  // 5-1) turn_header 타입이 있으면 그 헤더에서 장소 파싱
  if (!isPrologue && existingMessages != null && existingMessages.isNotEmpty) {
    for (final msg in existingMessages.reversed) {
      if (msg.type == 'turn_header') {
        final t = (msg.text).trim(); // 예: [ 2026년 ... | 공원 ]
        final m = RegExp(r'^\[\s*.+?\|\s*(.+?)\s*\]$').firstMatch(t);
        if (m != null) {
          final p = (m.group(1) ?? '').trim();
          if (p.isNotEmpty) {
            lastPlace = p;
            break;
          }
        }
      }
    }
  }

  // 5-2) 없으면 story_image url로 배경 매핑
  if (lastPlace == null &&
      !isPrologue &&
      existingMessages != null &&
      existingMessages.isNotEmpty) {
    for (final msg in existingMessages.reversed) {
      if (msg.type == 'story_image' && (msg.storyImageUrl).trim().isNotEmpty) {
        final mapped = bgUrlToName[(msg.storyImageUrl).trim()];
        if (mapped != null && mapped.isNotEmpty) {
          lastPlace = mapped;
          break;
        }
      }
    }
  }

  // 6) 토큰 추출 (SHOW_IMAGE / NARRATION / DIALOGUE)
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

  if (tokens.isEmpty) return raw;

  // 7) __PLACE__ 파싱 (헤더 장소 100% 잡기)
  //    [NARRATION]__PLACE__:공원[/NARRATION]
  String? placeSignal;
  final placeRe =
      RegExp(r'^\[NARRATION\]\s*__PLACE__\s*:\s*(.+?)\s*\[/NARRATION\]$');

  // placeSignal 토큰은 본문에서 제거할 거라서 filteredTokens로 옮길 때 제외
  // (placeSignal은 헤더에만 쓰이게)
  // 8) SHOW_IMAGE 하드필터 + 배경 1개 규칙 적용
  final imgRe = RegExp(r'^\[SHOW_IMAGE="(.*?)"\]$');

  // 먼저 placeSignal 잡기
  for (final t in tokens) {
    final m = placeRe.firstMatch(t);
    if (m != null) {
      final p = (m.group(1) ?? '').trim();
      if (p.isNotEmpty) {
        placeSignal = p;
        break;
      }
    }
  }

  // thisPlace: placeSignal 우선, 없으면 첫 배경 SHOW_IMAGE, 없으면 lastPlace
  String? thisPlace = (placeSignal ?? '').trim().isEmpty ? null : placeSignal;

  if (thisPlace == null) {
    for (final t in tokens) {
      final m = imgRe.firstMatch(t);
      if (m == null) continue;
      final cond = (m.group(1) ?? '').trim();
      if (cond.isNotEmpty && bgNames.contains(cond)) {
        thisPlace = cond;
        break;
      }
    }
  }

  thisPlace ??= lastPlace;

  final safePlace =
      (thisPlace ?? '').trim().isEmpty ? '어딘가' : thisPlace!.trim();

  // 배경은 장소가 바뀔 때만 허용
  // - 프롤로그는 첫 턴이므로 허용
  // - 그 외에는 lastPlace와 다를 때만
  final allowBackgroundThisTurn =
      isPrologue || (lastPlace == null ? true : safePlace != lastPlace);

  final filtered = <String>[];
  bool keptBackground = false;
  final keptSituations = <String>{}; // 같은 상황 반복 SHOW_IMAGE 방지(선택)

  for (final t in tokens) {
    // __PLACE__ 라인은 본문에서 제거
    if (placeRe.hasMatch(t)) {
      continue;
    }

    final mImg = imgRe.firstMatch(t);
    if (mImg != null) {
      final cond = (mImg.group(1) ?? '').trim();

      // ✅ 하드 필터: 자산 목록에 없으면 SHOW_IMAGE 제거
      final isBackground = cond.isNotEmpty && bgNames.contains(cond);
      final isSituation = cond.isNotEmpty && situationNames.contains(cond);

      // 둘 다 아니면 삭제
      if (!isBackground && !isSituation) {
        continue;
      }

      // 배경이면: (1) 이번 턴 허용 여부 (2) 1개만 (3) 헤더 장소와 불일치면 삭제
      if (isBackground) {
        if (!allowBackgroundThisTurn) continue;
        if (keptBackground) continue;

        // 헤더 장소가 placeSignal로 정해졌는데, 배경 SHOW_IMAGE가 다른 장소면 버림
        if ((placeSignal ?? '').trim().isNotEmpty && cond != safePlace) {
          continue;
        }

        keptBackground = true;
        filtered.add(t);
        continue;
      }

      // 상황이면: 중복 상황은 1개만 남김(너무 연속 호출 방지)
      if (isSituation) {
        if (keptSituations.contains(cond)) continue;
        keptSituations.add(cond);
        filtered.add(t);
        continue;
      }
    }

    // 나머지 토큰은 그대로
    filtered.add(t);
  }

  // 9) 시스템 시간 헤더 생성
  final now = DateTime.now();
  final dt = DateFormat('yyyy년 MM월 dd일 HH시 mm분', 'ko_KR').format(now);
  final headerText = '[ $dt | $safePlace ]';

  final body = filtered.join('\n').trim();
  return '[TURN_HEADER]$headerText[/TURN_HEADER]\n$body'.trim();
}
