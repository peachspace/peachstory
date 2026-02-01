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

import 'package:cloud_functions/cloud_functions.dart';

Future<String> generatePrologueField(
  String currentStoryContext,
  String genre,
  String? draftId,
  List<CharacterStructStruct>? characters,
) async {
  // -----------------------
  // 0) 유틸
  // -----------------------
  String normalizeGenre(String input) {
    final g = input.trim();
    if (g.isEmpty) return "기본";
    final aliases = <String, List<String>>{
      "현대로맨스": ["현대로맨스", "현로", "로코", "오피스", "캠퍼스"],
      "로맨스판타지": ["로맨스판타지", "로판"],
      "현대판타지": ["현대판타지", "현판"],
      "무협": ["무협"],
      "SF": ["SF", "사이파이", "근미래"],
      "미스터리/추리": ["미스터리", "추리"],
      "스릴러/범죄": ["스릴러", "범죄", "느와르"],
      "공포/오컬트": ["공포", "오컬트", "호러"],
      "힐링/일상": ["힐링", "일상", "드라마"],
      "헌터/던전/게이트": ["헌터", "던전", "게이트"],
      "아카데미/학원": ["아카데미", "학원"],
      "회귀/빙의/환생": ["회귀", "빙의", "환생", "회빙환"],
      "판타지": ["판타지", "정통판타지"],
    };
    for (final e in aliases.entries) {
      if (g == e.key) return e.key;
      for (final a in e.value) {
        if (g.contains(a)) return e.key;
      }
    }
    return g;
  }

  Future<String> callAi(
    String modelName,
    String systemPrompt,
    String userPrompt,
  ) async {
    final options = HttpsCallableOptions(timeout: const Duration(seconds: 120));
    final callable = FirebaseFunctions.instance
        .httpsCallable('callAiProxy', options: options);

    final result = await callable.call(<String, dynamic>{
      'modelName': modelName,
      'systemPrompt': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    });

    return (result.data['fullText'] ?? '').toString().trim();
  }

  // "주요장소" 블록에서 장소명만 뽑기 (장소명: 설명 형태 지원)
  List<String> extractMajorPlacesFromCtx(String ctx) {
    final lines = ctx.replaceAll('\r\n', '\n').split('\n');
    final out = <String>[];

    bool inBlock = false;
    for (final raw in lines) {
      final l = raw.trim();
      if (l.isEmpty) {
        if (inBlock) break;
        continue;
      }

      if (l.startsWith('주요장소') || l.startsWith('주요 장소')) {
        inBlock = true;
        final parts = l.split(':');
        if (parts.length >= 2) {
          final tail = parts.sublist(1).join(':');
          out.addAll(
            tail
                .split(RegExp(r'[,\|/·•]'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          );
        }
        continue;
      }

      if (inBlock) {
        // 다른 라벨 시작으로 보이면 종료
        if (RegExp(r'^[가-힣A-Za-z0-9 _/-]+:\s*$').hasMatch(l)) break;

        // "장소명: 설명"이면 장소명만
        if (l.contains(':')) {
          final name = l.split(':').first.trim();
          if (name.isNotEmpty && name.length <= 30) out.add(name);
        } else {
          if (l.length <= 30) out.add(l);
        }
      }
    }

    // 중복 제거
    final uniq = <String>{};
    final res = <String>[];
    for (final p in out) {
      final v = p.trim();
      if (v.isEmpty) continue;
      if (uniq.add(v)) res.add(v);
    }
    return res;
  }

  // 프롤로그 텍스트필드 강제 교정(후처리): "장소/내레이션/대사"만 남기기
  String forceFixPrologueUi(String raw, String defaultPlace) {
    var s = raw.replaceAll('\r\n', '\n').trim();
    s = s.replaceAll('```', '').replaceAll('```json', '').trim();

    // 따옴표 제거(2중 방어)
    s = s.replaceAll('"', '').replaceAll("'", "");

    final lines =
        s.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    String place = defaultPlace;
    // 장소 라인 먼저 찾기
    for (final l in lines) {
      final m = RegExp(r'^장소\s*:\s*(.+)$').firstMatch(l);
      if (m != null) {
        final p = (m.group(1) ?? '').trim();
        if (p.isNotEmpty) {
          place = p;
          break;
        }
      }
    }
    if (place.isEmpty) place = '어딘가';

    final out = <String>[];
    out.add('장소: $place');

    final dialogueRe = RegExp(r'^(.+?)\((.+?)\)\s*:\s*(.+)$');
    final narrationRe = RegExp(r'^내레이션\s*:\s*(.+)$');
    final placeRe = RegExp(r'^장소\s*:\s*(.+)$');

    // 본문 괄호 제거 함수(대사/내레이션 본문에 있는 ( ... )만 삭제)
    String stripParensInText(String t) {
      var x = t;
      x = x.replaceAll(RegExp(r'\([^)]*\)'), ''); // 본문 괄호 제거
      x = x.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
      return x.trim();
    }

    for (final l in lines) {
      if (placeRe.hasMatch(l)) continue; // 장소 라인은 맨 위로 강제하므로 무시

      // 내레이션
      final nm = narrationRe.firstMatch(l);
      if (nm != null) {
        var text = (nm.group(1) ?? '').trim();
        text = stripParensInText(text);
        if (text.isNotEmpty) out.add('내레이션: $text');
        continue;
      }

      // 대사: 이름(감정): 대사
      final dm = dialogueRe.firstMatch(l);
      if (dm != null) {
        final name = (dm.group(1) ?? '').trim();
        var emo = (dm.group(2) ?? '').trim();
        var text = (dm.group(3) ?? '').trim();

        // 본문 괄호 제거(감정 괄호는 유지)
        text = stripParensInText(text);

        if (name.isEmpty || text.isEmpty) continue;

        // 유저 화자 금지: {user}(...) 형태 제거
        if (name == '{user}') continue;

        if (emo.isEmpty) emo = '무감정';

        out.add('$name($emo): $text');
        continue;
      }

      // 그 외 문장들은 전부 내레이션으로 흡수
      var t = stripParensInText(l);
      if (t.isEmpty) continue;
      out.add('내레이션: $t');
    }

    // 너무 짧으면 안전 내레이션 1줄
    if (out.length < 3) {
      out.add('내레이션: ...');
    }

    return out.join('\n').trim();
  }

  // -----------------------
  // 1) 시작 장소 힌트 결정
  // -----------------------
  final ctx = currentStoryContext.trim();
  final majorPlaces = extractMajorPlacesFromCtx(ctx);

  final startPlace = majorPlaces.isNotEmpty ? majorPlaces.first : '어딘가';

  // 캐릭터 이름 힌트(프롬프트용)
  final charNames = <String>[];
  if (characters != null) {
    for (final c in characters) {
      final n = (c.name).trim();
      if (n.isNotEmpty) charNames.add(n);
    }
  }
  final charHint = charNames.isEmpty ? '없음' : charNames.join(', ');

  final safeGenre = normalizeGenre(genre);
  final did = (draftId ?? '').trim();

  // -----------------------
  // 2) 프롬프트(텍스트필드용 포맷만 출력)
  // -----------------------
  final systemPrompt = '''
너는 "프롤로그 텍스트필드"에 들어갈 글만 출력한다.
설명/해설/요약/목차/라벨/태그/JSON/마크다운 금지.
출력은 반드시 아래 3가지 줄 형식만 사용한다.
''';

  final userPrompt = '''
[장르] $safeGenre
${did.isNotEmpty ? "[세션키] $did" : ""}

[스토리 데이터]
$ctx

[가능하면 사용할 캐릭터 이름 힌트]
$charHint

[출력 규칙]
- 1번째 줄은 반드시 아래와 완전히 같아야 한다 (다른 글자 섞지 말 것)
장소: $startPlace

- 이후 줄들은 오직 아래 2가지 중 하나 형식만 허용:
캐릭터이름(감정): 대사
내레이션 문장(라벨 없음)

- 괄호 () 사용 금지. 단, 예외로 "캐릭터이름(감정)"의 감정 괄호 1번만 허용.
  내레이션/대사 본문에는 괄호를 절대 쓰지 마라.
- 따옴표 " ' 절대 금지.
- 유저가 화자로 말하면 실패다. 아래 형식은 절대 쓰지 마라:
{user}(감정): ...
{user}: ...

[분량]
- 전체 18~28줄

[내용]
- 세계관/유저역할/주요사건/주요장소 설정이 있으면 자연스럽게 반영해서 프롤로그를 쓴다.
- 장소는 프롤로그 내내 유지한다. 이동/전환 묘사 금지.

이제 출력해라.
''';

  String raw;
  try {
    raw = await callAi('solar-pro2', systemPrompt, userPrompt);
  } catch (e) {
    // 텍스트필드라서 에러도 사용자 친화 문장으로
    return '장소: $startPlace\n내레이션: 프롤로그 생성 오류가 발생했다\n내레이션: 다시 시도해 달라';
  }

  return forceFixPrologueUi(raw, startPlace);
}
