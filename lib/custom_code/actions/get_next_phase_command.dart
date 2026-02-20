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

String getNextPhaseCommand(int currentCount) {
  String phase = "";
  if (currentCount < 50) {
    phase = "초반(결성/관계 형성)";
  } else if (currentCount < 150) {
    phase = "전개(목표와 갈등 확대)";
  } else if (currentCount < 350) {
    phase = "상승(갈등 심화)";
  } else if (currentCount < 450) {
    phase = "클라이맥스 직전(결정적 충돌)";
  } else {
    phase = "후반(해결과 여파)";
  }

  return """
[SYSTEM CONTINUE INSTRUCTION]
- 지금 직전 문단의 '바로 다음 순간'부터 이어서 써라.
- 이번 턴 본문 분량은 한국어 약 500자 내외(권장 420~650자)로 맞춰라.
- 장소 목록은 시간순이 아니라 '등장 가능한 주요 배경 목록'이다. 순서로 해석하지 마라.
- 장소는 특별한 전환 사건이 없으면 유지하라(한 턴마다 급격히 바꾸지 마라).
- 장면 전환이 필요할 때만, 서술로 이동 이유를 먼저 만든 뒤 장소를 바꿔라.
- 본문은 빈 출력 금지. 최소 3개 이상의 유의미한 서술/대사 블록을 포함해라.
- 방금까지의 감정선/갈등선을 끊지 말고 이어라.
- 현재 진행 단계 힌트: $phase
[/SYSTEM CONTINUE INSTRUCTION]
"""
      .trim();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
