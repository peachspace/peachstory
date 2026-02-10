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

// ===============================
// ✅ 스타일/퀄리티 토큰 제거(앱에서도 2차 방어)
// ===============================
final RegExp _forbiddenStyleRe = RegExp(
  r'(\bmasterpiece\b|\bbest quality\b|\bhigh quality\b|\banime\b|\bwebtoon\b|\bmanhwa\b|\blineart\b|\bcel shading\b|\bflat color\b|\b8k\b|\b4k\b|\bphotorealistic\b|\brealistic\b|\bcinematic\b|\brender\b|\bstyle\b|\bquality\b)',
  caseSensitive: false,
);

String _stripStyleTokens(String s) {
  var out = s.trim();
  out = out.replaceAll(_forbiddenStyleRe, ' ');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
  out = out.replaceAll(RegExp(r'[, ]+'), ', ').trim();
  out = out.replaceAll(RegExp(r'^(, )+'), '').trim();
  out = out.replaceAll(RegExp(r'(, )+$'), '').trim();
  return out;
}

// ✅ tags 안에서 framing 후보 추출 (framing 파라미터가 비어있을 때만 사용)
String? _extractFramingFromTags(String tags) {
  final lower = tags.toLowerCase();

  // 가장 강하게 잡는 것부터 우선순위
  if (lower.contains('close-up')) return 'close-up';
  if (lower.contains('full body')) return 'full body';
  if (lower.contains('upper body')) return 'upper body, waist up';
  if (lower.contains('waist up')) return 'upper body, waist up';
  if (lower.contains('medium shot')) return 'upper body, waist up, medium shot';
  return null;
}

String _removeFramingTokens(String tags) {
  // framing 토큰을 tags에서 제거(중복 방지)
  var s = tags;
  final patterns = [
    RegExp(r'\bclose-up\b', caseSensitive: false),
    RegExp(r'\bfull body\b', caseSensitive: false),
    RegExp(r'\bupper body\b', caseSensitive: false),
    RegExp(r'\bwaist up\b', caseSensitive: false),
    RegExp(r'\bmedium shot\b', caseSensitive: false),
    RegExp(r'\blong shot\b', caseSensitive: false),
    RegExp(r'\bwide shot\b', caseSensitive: false),
    RegExp(r'\bcowboy shot\b', caseSensitive: false),
    RegExp(r'\bthree-quarter\b', caseSensitive: false),
  ];
  for (final p in patterns) {
    s = s.replaceAll(p, ' ');
  }
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  // 콤마 정리
  s = s.replaceAll(RegExp(r'\s*,\s*'), ', ').trim();
  s = s.replaceAll(RegExp(r'^(, )+'), '').trim();
  s = s.replaceAll(RegExp(r'(, )+$'), '').trim();
  return s;
}

/// mode: "emotion" | "situation" | "background" | "main" | "character"
/// keyKorean: emotionKey(예: "기쁨") 또는 상황키(예: "칼뽑기") 등
/// tags: generateVisualTags 결과(영문 comma tags)
/// framing: "upper body, waist up" 같은 구도 태그(옵션)
Future<String> composeScenePrompt(
  String mode,
  String? keyKorean,
  String? tags,
  String? framing,
) async {
  final k = (keyKorean ?? '').trim();
  var t = _stripStyleTokens((tags ?? '').trim());
  var f = _stripStyleTokens((framing ?? '').trim());

  // framing이 비었고 tags에 framing이 섞여있으면 자동 추출
  if (f.isEmpty && t.isNotEmpty) {
    final extracted = _extractFramingFromTags(t);
    if (extracted != null) {
      f = extracted;
      t = _removeFramingTokens(t);
    }
  }

  if (mode == "character") {
    // character는 scenePrompt가 아니라 basePrompt(identity tags)가 핵심
    // 여기서는 tags를 그대로 반환(단, 스타일 토큰 제거는 완료)
    return t;
  }

  if (mode == "emotion") {
    // emotion: 첫 토큰 = 감정키 보장
    // "기쁨 <나머지>" 형태 유지 (쉼표로 바로 붙지 않게)
    final rest = [
      if (f.isNotEmpty) f,
      if (t.isNotEmpty) t,
    ].where((e) => e.trim().isNotEmpty).join(', ');

    if (k.isNotEmpty) {
      return rest.isEmpty ? k : '$k $rest';
    }
    return rest.isNotEmpty ? rest : 'neutral expression';
  }

  // situation/background/main: 구도 + 태그 중심
  final combined = [
    if (f.isNotEmpty) f,
    if (t.isNotEmpty) t,
  ].where((e) => e.trim().isNotEmpty).join(', ');

  return combined.isNotEmpty ? combined : 'simple composition';
}
