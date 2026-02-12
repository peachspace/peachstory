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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

Future<void> updateStoryMemory(
  DocumentReference storyChatRef,
) async {
  String _keepMax(String s, int maxLen) {
    final t = (s).trim();
    if (t.length <= maxLen) return t;
    return t.substring(0, maxLen).trim();
  }

  String _extractBlock(String text, String tag) {
    final re = RegExp(
      '\\[$tag\\]([\\s\\S]*?)\\[\\/$tag\\]',
      multiLine: true,
    );
    final m = re.firstMatch(text);
    if (m == null) return '';
    return (m.group(1) ?? '').trim();
  }

  String _safeStr(dynamic v) => (v ?? '').toString().trim();
  int _safeInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }

  // 1) 현재 memory 상태 읽기
  final snap = await storyChatRef.get();
  final data = (snap.data() as Map<String, dynamic>?) ?? {};

  final prevTurn = _safeInt(data['turnCount'], 0);
  final prevChapter = _safeInt(data['chapterIndex'], 1);

  final prevBible = _safeStr(data['storyBible']);
  final prevChapterState = _safeStr(data['chapterState']);
  final prevSummary = _safeStr(data['summary']);

  final newTurn = prevTurn + 1;

  // 2) 업데이트 규칙(고정)
  final doMicro = (newTurn % 10 == 0); // 10턴마다 장기요약 갱신
  final doState = (newTurn % 25 == 0); // 25턴마다 챕터상태 갱신
  final doChapterEnd = (newTurn % 100 == 0); // 100턴마다 바이블/챕터 리셋

  // 3) 최근 로그 가져오기(고정 60개)
  final msgSnap = await storyChatRef
      .collection('storymessages')
      .orderBy('timestamp', descending: true)
      .limit(60)
      .get();

  final docs = msgSnap.docs.toList().reversed.toList();

  final lines = <String>[];
  for (final d in docs) {
    final m = d.data() as Map<String, dynamic>;
    final type = _safeStr(m['type']);
    final text = _safeStr(m['text']);
    if (text.isEmpty) continue;
    if (text == '생각 중') continue;

    // user/assistant 구분 (너 기존 로직과 동일하게 type==user면 user 취급)
    // (user 메시지 type을 실제로 어떻게 저장하는지에 따라 필요 시 여기만 맞추면 됨)
    final role = (type == 'user') ? 'USER' : 'ASSISTANT';

    // 태그형 출력은 그대로 텍스트로만 요약에 넣기
    lines.add('$role: $text');
  }

  final recentLog = lines.isEmpty ? '(no log)' : lines.join('\n');

  // 4) callAiSummary 호출(고정)
  final callable = FirebaseFunctions.instance.httpsCallable(
    'callAiSummary',
    options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
  );

  // 5) 프롬프트(고정 출력 포맷)
  // - 모델이 반드시 3개(또는 2개) 블록으로만 내보내게 강제
  final needInitBible = prevBible.trim().isEmpty;

  String prompt = '';

  if (doChapterEnd) {
    prompt = '''
너는 장편 스토리 메모리 편집기다.
아래 RECENT_LOG와 기존 메모리를 반영해서, 반드시 아래 3개 블록만 출력해라.
다른 문장/설명/머리말/번호/마크다운/JSON 금지.

[STORY_BIBLE]
- 변하지 않는 설정/인물/관계 핵심만.
- 너무 길어지지 않게.
[/STORY_BIBLE]

[LONG_SUMMARY]
- 지금까지의 진행을 장기요약으로 업데이트.
[/LONG_SUMMARY]

[NEXT_CHAPTER_STATE]
- 다음 100턴을 위한 챕터 목표/진행/미해결만.
[/NEXT_CHAPTER_STATE]

[CURRENT_MEMORY]
[STORY_BIBLE]
${prevBible.isEmpty ? '(empty)' : prevBible}
[/STORY_BIBLE]
[LONG_SUMMARY]
${prevSummary.isEmpty ? '(empty)' : prevSummary}
[/LONG_SUMMARY]
[CHAPTER_STATE]
${prevChapterState.isEmpty ? '(empty)' : prevChapterState}
[/CHAPTER_STATE]

[RECENT_LOG]
$recentLog
''';
  } else if (doState) {
    prompt = '''
너는 장편 스토리 메모리 편집기다.
아래 RECENT_LOG와 기존 메모리를 반영해서, 반드시 아래 2개 블록만 출력해라.
다른 문장/설명/머리말/번호/마크다운/JSON 금지.

[LONG_SUMMARY]
- 지금까지의 진행을 장기요약으로 업데이트.
[/LONG_SUMMARY]

[NEXT_CHAPTER_STATE]
- 현재 챕터 목표/진행/미해결만 업데이트.
[/NEXT_CHAPTER_STATE]

[CURRENT_MEMORY]
[LONG_SUMMARY]
${prevSummary.isEmpty ? '(empty)' : prevSummary}
[/LONG_SUMMARY]
[CHAPTER_STATE]
${prevChapterState.isEmpty ? '(empty)' : prevChapterState}
[/CHAPTER_STATE]

[RECENT_LOG]
$recentLog
''';
  } else if (doMicro || needInitBible) {
    prompt = '''
너는 장편 스토리 메모리 편집기다.
아래 RECENT_LOG와 기존 메모리를 반영해서, 반드시 아래 블록만 출력해라.
다른 문장/설명/머리말/번호/마크다운/JSON 금지.

${needInitBible ? '''
[STORY_BIBLE]
- 변하지 않는 설정/인물/관계 핵심만.
- 너무 길어지지 않게.
[/STORY_BIBLE]
''' : ''}

[LONG_SUMMARY]
- 지금까지의 진행을 장기요약으로 업데이트.
[/LONG_SUMMARY]

[CURRENT_MEMORY]
${needInitBible ? '''
[STORY_BIBLE]
${prevBible.isEmpty ? '(empty)' : prevBible}
[/STORY_BIBLE]
''' : ''}

[LONG_SUMMARY]
${prevSummary.isEmpty ? '(empty)' : prevSummary}
[/LONG_SUMMARY]

[RECENT_LOG]
$recentLog
''';
  } else {
    // 업데이트 타이밍 아니면 카운트만 올리고 종료
    await storyChatRef.update({
      'turnCount': newTurn,
    });
    return;
  }

  final result = await callable.call({'summaryPrompt': prompt});
  final resData = result.data;

  // Groq(OpenAI 호환) 응답에서 content 추출
  String content = '';
  try {
    if (resData is Map &&
        resData['choices'] is List &&
        (resData['choices'] as List).isNotEmpty) {
      final c0 = (resData['choices'] as List).first;
      if (c0 is Map &&
          c0['message'] is Map &&
          (c0['message'] as Map)['content'] != null) {
        content = (c0['message'] as Map)['content'].toString().trim();
      }
    }
  } catch (_) {}

  if (content.isEmpty) {
    content = resData.toString().trim();
  }

  // 6) 블록 파싱
  String nextBible = _extractBlock(content, 'STORY_BIBLE');
  String nextSummary = _extractBlock(content, 'LONG_SUMMARY');
  String nextState = _extractBlock(content, 'NEXT_CHAPTER_STATE');

  // 7) 길이 캡(고정)
  if (nextBible.isNotEmpty) nextBible = _keepMax(nextBible, 2500);
  if (nextSummary.isNotEmpty) nextSummary = _keepMax(nextSummary, 4500);
  if (nextState.isNotEmpty) nextState = _keepMax(nextState, 1500);

  final updates = <String, dynamic>{
    'turnCount': newTurn,
    'summary': nextSummary.isNotEmpty ? nextSummary : prevSummary,
  };

  if (needInitBible && nextBible.isNotEmpty) {
    updates['storyBible'] = nextBible;
  }

  if (doState && nextState.isNotEmpty) {
    updates['chapterState'] = nextState;
  }

  if (doChapterEnd) {
    // 챕터 종료 시: 바이블/요약/챕터상태 갱신 + chapterIndex 증가
    if (nextBible.isNotEmpty) updates['storyBible'] = nextBible;
    if (nextState.isNotEmpty) updates['chapterState'] = nextState;
    updates['chapterIndex'] = prevChapter + 1;
  }

  await storyChatRef.update(updates);
}
