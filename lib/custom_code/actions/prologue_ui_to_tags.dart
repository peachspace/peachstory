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

String prologueUiToTags(
  String input,
  List<CharacterStructStruct> characters,
  List<BackgroundStructStruct> backgrounds,
) {
  final text = input.replaceAll('\r\n', '\n').trim();

  // 1) 구형 포맷이면 기존 변환기 사용
  if (text.contains('[Image:') ||
      text.contains('내레이션:') ||
      text.contains('대사:')) {
    return legacyToTags(text);
  }

  // 2) 유저친화 포맷 파싱 준비
  final characterNames =
      characters.map((c) => c.name.trim()).where((s) => s.isNotEmpty).toSet();

  final bgAssets = backgrounds
      .map((b) => b.placeName.trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  // 상황 에셋: buildStoryPrompt에서 SituationAssets로 쓰는 condition들
  final situationAssets = <String>{};
  for (final c in characters) {
    for (final s in c.situationImages) {
      final cond = (s.condition).trim();
      if (cond.isNotEmpty) situationAssets.add(cond);
    }
  }

  // 감정 에셋: 캐릭터별로 보유 감정 목록
  final emotionsByChar = <String, Set<String>>{};
  for (final c in characters) {
    final emos = c.emotionimages
        .map((e) => e.emotion.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    emotionsByChar[c.name.trim()] = emos;
  }

  final lines =
      text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  final out = StringBuffer();

  for (final line in lines) {
    // 배경이미지: 장소명
    if (line.startsWith('배경이미지:')) {
      final place = line.substring('배경이미지:'.length).trim();
      if (bgAssets.contains(place)) {
        out.writeln('[SHOW_IMAGE="$place"]');
      }
      continue;
    }

    // 상황이미지: 상황명
    if (line.startsWith('상황이미지:')) {
      final sit = line.substring('상황이미지:'.length).trim();
      if (situationAssets.contains(sit)) {
        out.writeln('[SHOW_IMAGE="$sit"]');
      }
      continue;
    }

    // 이름(감정): 대사  또는  이름: 대사
    final m =
        RegExp(r'^(.+?)\s*(?:\(\s*(.+?)\s*\))?\s*:\s*(.+)$').firstMatch(line);
    if (m != null) {
      final speaker = m.group(1)!.trim();
      var emo = (m.group(2) ?? '').trim();
      var speech = m.group(3)!.trim();

      // 따옴표 제거
      speech = speech.replaceAll('"', '').replaceAll("'", "");

      // speaker가 캐릭터 목록에 있으면 대사로 처리
      if (characterNames.contains(speaker)) {
        final allowedEmos = emotionsByChar[speaker] ?? {};
        if (emo.isEmpty) emo = '무감정';
        if (emo != '무감정' && !allowedEmos.contains(emo)) emo = '무감정';

        out.writeln(
            '[DIALOGUE SPEAKER="$speaker" ACTION="$emo"]$speech[/DIALOGUE]');
        continue;
      }

      // 캐릭터 이름이 아니면 내레이션으로 처리(파싱 오탐 방지)
    }

    // 나머지는 내레이션
    out.writeln('[NARRATION]$line[/NARRATION]');
  }

  return out.toString().trim();
}
