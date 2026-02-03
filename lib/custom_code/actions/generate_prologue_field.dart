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

import 'index.dart'; // Imports other custom actions

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

  // "주요 장소" 블록에서 장소명만 뽑기 (장소명: 설명 형태 지원)
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

  // ✅ “어딘가” 같은 애매한 장소면 대체
  String fallbackInventPlace(String safeGenre) {
    // 장르별로 그럴듯한 기본값
    if (safeGenre.contains('로맨스')) return '청연 카페';
    if (safeGenre.contains('미스터리') || safeGenre.contains('스릴러'))
      return '서늘한 골목 끝 탐정사무소';
    if (safeGenre.contains('판타지')) return '루미나 왕도 외곽의 마법서점';
    if (safeGenre.contains('무협')) return '흑운객잔 2층 끝방';
    if (safeGenre.contains('SF')) return '오비탈 정거장 7번 회랑';
    return '바람결 도서관';
  }

  // ✅ 역할명/이름없음 같은 화자면 이름으로 바꾸기
  String forceName(String raw, Set<String> known, Map<String, String> memo,
      List<String> pool, int idx) {
    final s = raw.trim();

    if (known.contains(s)) return s;

    // 이미 배정된 역할/문제 화자면 동일 이름 유지
    if (memo.containsKey(s)) return memo[s]!;

    final looksBad = s.contains('이름 없음') ||
        s.contains('현재') ||
        s.contains('과거') ||
        s.contains('연인') ||
        s.contains('악역') ||
        s.contains('캐릭터') ||
        s.contains(' ') ||
        s.length <= 1;

    if (!looksBad) return s;

    final name = pool[idx % pool.length];
    memo[s] = name;
    return name;
  }

  // 프롤로그 텍스트필드 강제 교정(후처리)
  String forceFixPrologueUi(
    String raw,
    String safeGenre,
    List<String> majorPlaces,
    Set<String> knownNames,
  ) {
    var s = raw.replaceAll('\r\n', '\n').trim();
    s = s.replaceAll('```json', '').replaceAll('```', '').trim();
    s = s.replaceAll('"', '').replaceAll("'", "");

    final lines =
        s.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    // 1) 장소 추출
    String place = '';
    for (final l in lines) {
      final m = RegExp(r'^장소\s*:\s*(.+)$').firstMatch(l);
      if (m != null) {
        place = (m.group(1) ?? '').trim();
        break;
      }
    }

    // 2) 장소 강제 규칙
    if (majorPlaces.isNotEmpty) {
      // majorPlaces가 있으면 반드시 그중 하나
      if (!majorPlaces.contains(place)) {
        place = majorPlaces.first;
      }
    } else {
      // 없으면 “어딘가” 금지 → AI가 구체적으로 지어야 하지만 혹시 실패하면 후처리에서 보정
      if (place.isEmpty ||
          place.contains('어딘가') ||
          place.contains('미정') ||
          place.contains('알 수')) {
        place = fallbackInventPlace(safeGenre);
      }
    }

    final out = <String>[];
    out.add('장소: $place');

    // 대사 패턴들
    final reKnown = RegExp(r'^(.+?)\((.+?)\)\s*:\s*(.+)$'); // 이름(감정): 대사
    final rePlain = RegExp(r'^(.+?)\s*:\s*(.+)$'); // 이름: 대사
    final reNarrLabel = RegExp(r'^(내레이션|내래이션)\s*:\s*(.+)$');

    // 본문 괄호 제거(대사/내레이션 본문에 있는 ( ... )만 삭제)
    String stripParensInText(String t) {
      var x = t;
      x = x.replaceAll(RegExp(r'\([^)]*\)'), '');
      x = x.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
      return x.trim();
    }

    // 이름 풀(필요 시)
    final namePool = <String>[
      '서윤',
      '도윤',
      '지호',
      '하린',
      '유진',
      '민재',
      '채원',
      '선우',
      '아린',
      '현우',
      '서연',
      '준호',
      '나연',
      '시우',
      '다은'
    ];
    int poolIdx = 0;
    final memo = <String, String>{};

    for (final l in lines) {
      if (l.startsWith('장소')) continue;

      // 내레이션 라벨이 섞여 나오면 제거하고 문장만
      final nm = reNarrLabel.firstMatch(l);
      if (nm != null) {
        var text = stripParensInText((nm.group(2) ?? '').trim());
        if (text.isNotEmpty) out.add(text);
        continue;
      }

      // 이름(감정): 대사
      final km = reKnown.firstMatch(l);
      if (km != null) {
        var name = (km.group(1) ?? '').trim();
        var emo = (km.group(2) ?? '').trim();
        var text = (km.group(3) ?? '').trim();

        // 대사 본문 괄호 제거
        text = stripParensInText(text);
        if (text.isEmpty) continue;

        // {user} 금지
        if (name == '{user}') continue;

        // 화자명 정리(이름없음/역할명 → 이름)
        name = forceName(name, knownNames, memo, namePool, poolIdx);
        if (!knownNames.contains(name) &&
            memo.containsKey((km.group(1) ?? '').trim())) {
          poolIdx++;
        }

        if (knownNames.contains(name)) {
          if (emo.isEmpty) emo = '무감정';
          out.add('$name($emo): $text');
        } else {
          // ✅ 설정되지 않은 인물은 감정 괄호 금지 → "이름: 대사"
          out.add('$name: $text');
        }
        continue;
      }

      // 이름: 대사
      final pm = rePlain.firstMatch(l);
      if (pm != null) {
        var name = (pm.group(1) ?? '').trim();
        var text = (pm.group(2) ?? '').trim();
        text = stripParensInText(text);
        if (text.isEmpty) continue;
        if (name == '{user}') continue;

        name = forceName(name, knownNames, memo, namePool, poolIdx);
        if (!knownNames.contains(name) &&
            memo.containsKey((pm.group(1) ?? '').trim())) {
          poolIdx++;
        }

        if (knownNames.contains(name)) {
          // 설정 캐릭터인데 감정이 빠져 있으면 기본 감정 부여
          out.add('$name(무감정): $text');
        } else {
          out.add('$name: $text');
        }
        continue;
      }

      // 그 외는 내레이션 문장으로 처리(라벨 없이)
      var t = stripParensInText(l);
      if (t.isEmpty) continue;
      out.add(t);
    }

    // 너무 짧으면 최소 안전 문장
    if (out.length < 8) {
      out.add('창밖의 빛이 천천히 기울며, 공기까지 낯설게 변한다.');
      out.add('누군가의 한마디가, 앞으로의 모든 선택을 바꿔놓을 것처럼 들린다.');
    }

    return out.join('\n').trim();
  }

  // -----------------------
  // 1) 장소 힌트 결정
  // -----------------------
  final ctx = currentStoryContext.trim();
  final majorPlaces = extractMajorPlacesFromCtx(ctx);

  // 캐릭터 이름 힌트
  final knownNames = <String>{};
  final charNames = <String>[];
  if (characters != null) {
    for (final c in characters) {
      final n = (c.name).trim();
      if (n.isNotEmpty) {
        knownNames.add(n);
        charNames.add(n);
      }
    }
  }
  final charHint = charNames.isEmpty ? '없음' : charNames.join(', ');

  final safeGenre = normalizeGenre(genre);
  final did = (draftId ?? '').trim();

  // -----------------------
  // 2) 프롬프트 (라벨/형식 강제)
  // -----------------------
  final systemPrompt = """
너는 "프롤로그 텍스트필드"에 들어갈 텍스트만 출력한다.
설명/해설/요약/목차/JSON/마크다운/따옴표 금지.
"""
      .trim();

  final userPrompt = """
[장르] $safeGenre
${did.isNotEmpty ? "[세션키] $did" : ""}

[스토리 데이터]
$ctx

[설정된 캐릭터 이름(반드시 이 이름 그대로 사용)]
$charHint

[출력 규칙]
1) 첫 줄은 반드시:
장소: <장소명>

- 장소명 규칙:
${majorPlaces.isNotEmpty ? "- 반드시 다음 목록 중 하나만 사용: ${majorPlaces.join(', ')}" : "- 반드시 구체적인 고유 장소명을 네가 지어라. '어딘가/미정/알 수 없음' 금지."}

2) 이후 각 줄은 오직 아래 셋 중 하나만:
A) 설정된 캐릭터만: 이름(감정): 대사
B) 설정되지 않은 인물: 이름: 대사   (감정 괄호 절대 금지)
C) 내레이션: 라벨 없이 문장만 출력

3) 금지:
- "내레이션:" 라벨 금지
- "(이름 없음)" 금지
- "현재 연인/과거 연인/악역 캐릭터" 같은 역할명 화자 금지 (이름을 만들어라)
- 괄호 () 사용 금지 (단, A형식의 감정 괄호만 예외로 1회 허용)
- 유저가 화자로 말하는 형태 금지: {user}...

[분량]
- 전체 18~28줄
- 장소는 프롤로그 내내 유지(이동/전환 묘사 금지)

이제 출력해라.
"""
      .trim();

  String raw;
  try {
    raw = await callAi('solar-pro2', systemPrompt, userPrompt);
  } catch (e) {
    final fallbackPlace = majorPlaces.isNotEmpty
        ? majorPlaces.first
        : fallbackInventPlace(safeGenre);
    return '장소: $fallbackPlace\n창밖의 소음이 갑자기 멀어지고, 숨이 턱 막히는 침묵만 남는다.\n무언가가 시작되려 한다.';
  }

  return forceFixPrologueUi(raw, safeGenre, majorPlaces, knownNames);
}
