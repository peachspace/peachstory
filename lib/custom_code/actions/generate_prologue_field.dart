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

import 'package:cloud_functions/cloud_functions.dart';

Future<String> generatePrologueField(
  String currentStoryContext,
  String? draftId,
  List<CharacterStructStruct>? characters,
  String? userInstruction, // ✅ 텍스트필드 지시 추가
) async {
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

    return (result.data['fullText'] ?? '').toString();
  }

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
        if (RegExp(r'^[가-힣A-Za-z0-9 _/-]+:\s*$').hasMatch(l)) break;

        if (l.contains(':')) {
          final name = l.split(':').first.trim();
          if (name.isNotEmpty && name.length <= 30) out.add(name);
        } else {
          if (l.length <= 30) out.add(l);
        }
      }
    }

    final uniq = <String>{};
    final res = <String>[];
    for (final p in out) {
      final v = p.trim();
      if (v.isEmpty) continue;
      if (uniq.add(v)) res.add(v);
    }
    return res;
  }

  final ctx = currentStoryContext.trim();
  final did = (draftId ?? '').trim();

  final uiRaw = (userInstruction ?? '').trim();
  final uiBlock = uiRaw.isEmpty ? '' : '\n[사용자 추가 지시]\n$uiRaw\n';

  final majorPlaces = extractMajorPlacesFromCtx(ctx);

  final charNames = <String>[];
  if (characters != null) {
    for (final c in characters) {
      final n = (c.name).trim();
      if (n.isNotEmpty) charNames.add(n);
    }
  }
  final charHint = charNames.isEmpty ? '없음' : charNames.join(', ');
  final hasConfiguredChars = charNames.isNotEmpty;

  final systemPrompt = """
너는 "프롤로그 텍스트필드"에 들어갈 텍스트만 출력한다.
설명/해설/요약/목차/JSON/코드블록/마크다운 금지.
"""
      .trim();

  final userPrompt = """
${did.isNotEmpty ? "[세션키] $did" : ""}

[스토리 데이터]
$ctx
$uiBlock

[최우선 규칙]
- 사용자 추가 지시가 있으면 최대한 반영하되, 아래 형식/금지 규칙은 절대 깨지 마라.

[설정된 캐릭터 이름(있다면 이 이름을 그대로 사용)]
$charHint

[최상위 규칙: 줄 간격]
- 출력은 "한 줄 출력 후 반드시 빈 줄 1개"를 넣어라.
- 즉, 모든 출력 단위는 (내용줄) 다음에 공백줄 1개를 둔다.
- 마지막 줄 뒤에는 빈 줄을 추가하지 마라.

[출력 규칙(형식은 반드시 지켜라)]
1) 첫 줄(내용줄)은 반드시:
장소: <장소명>

- 장소명 규칙:
${majorPlaces.isNotEmpty ? "- 반드시 다음 목록 중 하나만 사용: ${majorPlaces.join(', ')}" : "- 반드시 구체적인 고유 장소명을 네가 지어라. '어딘가/미정/알 수 없음' 금지."}

2) 이후 각 '내용줄'은 오직 아래 셋 중 하나만:
A) 설정된 캐릭터만: 이름(감정): 대사
B) 설정되지 않은 인물: 이름: 대사   (감정 괄호 절대 금지)
C) 내레이션: 라벨 없이 문장만 출력

[감정 태그 규칙]
- A형식에서 (감정)은 반드시 1개만 붙이고, 감정은 1~4글자 단어로 쓴다.
- A형식의 감정 괄호 외에는 어떤 괄호()도 쓰지 마라.
- B형식(비설정 인물)과 C형식(내레이션)에는 괄호()가 단 하나도 나오면 안 된다.

[스토리 안정 조건]
- 대사만 연속으로 6줄 이상 이어지지 않게 해라(중간에 내레이션 끼워라).
- 내레이션만 연속으로 4줄 이상 이어지지 않게 해라(중간에 대사 끼워라).
${hasConfiguredChars ? """
- 설정된 캐릭터가 있으므로, 반드시 설정된 캐릭터 중 최소 1명이 'A형식 대사'를 최소 2줄 이상 말하게 해라.
- 설정된 캐릭터 이름은 정확히 일치해야 한다(오타/변형/공백추가 금지).
""" : """
- 설정된 캐릭터가 없으므로, 필요한 경우 너가 이름을 지어 B형식으로만 대사를 넣어라(감정괄호 금지).
"""}

[금지]
- "내레이션:" 같은 라벨 금지
- JSON/중괄호/대괄호 금지
- 역할명 화자(예: 악역/길드원/현재연인 등) 금지 → 필요하면 고유 이름을 지어라
- {user}가 화자로 말하는 형태 금지

[분량]
- '빈 줄을 제외한 내용줄' 기준으로 18~28줄
- 장소는 프롤로그 내내 유지(이동/전환 묘사 금지)

이제 위 규칙대로만 출력해라.
"""
      .trim();

  try {
    final raw = await callAi('openai/gpt-oss-20b', systemPrompt, userPrompt);
    return raw.trim();
  } catch (e) {
    return "생성 오류: $e";
  }
}
