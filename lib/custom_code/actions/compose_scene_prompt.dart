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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

/// mode: "emotion" | "situation" | "background" | "main" | "character"
/// keyKorean: emotionKey(예: "기쁨") 또는 상황키(예: "칼뽑기") 등
/// tags: generateVisualTags 결과(영문 comma tags)
/// framing: "upper body, waist up, medium shot" 같은 구도 태그(옵션)
Future<String> composeScenePrompt(
  String mode,
  String? keyKorean,
  String? tags,
  String? framing,
) async {
  final k = (keyKorean ?? '').trim();
  final t = (tags ?? '').trim();
  final f = (framing ?? '').trim();

  if (mode == "character") {
    // character는 scenePrompt보다 basePrompt(identityTags)가 핵심이라
    // 여기서는 그냥 tags(=identityTags)만 돌려주는 용도로 써도 됨.
    return t;
  }

  // emotion: EMOTION_MAP을 확실히 타기 위해 "첫 단어 = 감정키"를 보장
  if (mode == "emotion") {
    final base = [k, if (f.isNotEmpty) f, if (t.isNotEmpty) t]
        .where((e) => e.trim().isNotEmpty)
        .join(', ');

    // ⚠️ 첫 토큰이 '기쁨'이 되도록 "기쁨␠..." 형태로 시작시킴
    // 쉼표로 바로 붙이면 "기쁨,"이 첫 토큰이 될 수 있어 위험.
    if (k.isNotEmpty) {
      final rest = base.substring(k.length).trimLeft();
      return rest.isEmpty
          ? k
          : '$k ${rest.replaceFirst(RegExp(r'^[, ]+'), '')}';
    }
    return base.isNotEmpty ? base : 'neutral expression';
  }

  // 상황/배경/메인: 구도 + 태그 중심
  final combined = [if (f.isNotEmpty) f, if (t.isNotEmpty) t]
      .where((e) => e.trim().isNotEmpty)
      .join(', ');
  return combined.isNotEmpty ? combined : 'simple composition';
}
