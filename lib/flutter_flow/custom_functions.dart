import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

List<String> parseHashtags(String inputText) {
  if (inputText == null || inputText.isEmpty) {
    return [];
  }
  // 쉼표와 공백을 기준으로 문자열을 나눕니다.
  final tags = inputText.split(RegExp(r'[\s,]+'));
  // 각 태그의 '#' 기호와 앞뒤 공백을 제거하고, 빈 태그는 제외합니다.
  return tags
      .map((tag) => tag.replaceAll('#', '').trim())
      .where((tag) => tag.isNotEmpty)
      .toList();
}

bool didUserLike(
  List<DocumentReference>? likedByList,
  DocumentReference? currentUserRef,
) {
// 리스트가 비어있거나, 현재 유저 정보가 없으면 false를 반환합니다.
  if (likedByList == null || likedByList.isEmpty || currentUserRef == null) {
    return false;
  }
  // 리스트에 현재 유저의 참조가 포함되어 있는지 확인하여 true/false를 반환합니다.
  return likedByList.contains(currentUserRef);
}

String buildStoryPrompt(
  String storyTitle,
  String storySetting,
  List<CharacterStructStruct> characters,
  String userRole,
  List<PlaceStructStruct> places,
  String userNote,
  String userInChatName,
  String? summary,
  bool isNovelMode,
  String majorPlacesText,
  String majorEventsText,
  List<EventStructStruct>? events,
) {
  Map<String, dynamic> _toMap(dynamic s) {
    if (s == null) return <String, dynamic>{};
    if (s is Map) return Map<String, dynamic>.from(s as Map);
    try {
      final m = (s as dynamic).toMap();
      if (m is Map) return Map<String, dynamic>.from(m as Map);
    } catch (_) {}
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic v) => (v is List) ? v : const [];

  String _pickStr(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  final safePlacesText =
      majorPlacesText.trim().isEmpty ? '없음' : majorPlacesText.trim();
  final safeEventsText =
      majorEventsText.trim().isEmpty ? '없음' : majorEventsText.trim();

  // -------------------------
  // BackgroundAssets (장소 배경 이미지 있는 것만)
  // -------------------------
  final bgSet = <String>{};
  for (final p in places) {
    final pm = _toMap(p);
    final place = _pickStr(pm, ['place', 'placeName']);
    final url = _pickStr(pm, ['imageUrl', 'imageurl', 'imageURL']);
    if (place.isNotEmpty && url.isNotEmpty) bgSet.add(place);
  }
  final bgBlock = bgSet.isEmpty ? '없음' : bgSet.join(', ');

  // -------------------------
  // Ability/Emotion 조합 자산 수집
  // - 형식: PLACE__TAG
  // -------------------------
  final abilityComboSet = <String>{};
  final emotionComboSet = <String>{};

  // 캐릭터 블록 (감정 태그 목록은 캐릭터별로 제공)
  final characterBlock = StringBuffer();

  for (final c in characters) {
    final cm = _toMap(c);
    final name = _pickStr(cm, ['name']);
    final setting = _pickStr(cm, ['setting']);

    // (1) ability list: abilityStruct / abilityImages / situationImages 호환
    final abilityList = <dynamic>[
      ..._asList(cm['abilityStruct']),
      ..._asList(cm['abilityImages']),
      ..._asList(cm['situationImages']),
    ];

    for (final it in abilityList) {
      final im = _toMap(it);
      final place = _pickStr(im, ['place', 'placeName']);
      final tag = _pickStr(im, ['ability', 'condition']);
      final url = _pickStr(im, ['imageUrl', 'imageurl', 'imageURL']);
      if (place.isNotEmpty && tag.isNotEmpty && url.isNotEmpty) {
        abilityComboSet.add('${place}__${tag}');
      }
    }

    // (2) emotion list: emotionStruct / emotionimages 호환
    final emotionList = <dynamic>[
      ..._asList(cm['emotionStruct']),
      ..._asList(cm['emotionimages']),
    ];

    final emoTagSet = <String>{};
    for (final it in emotionList) {
      final em = _toMap(it);
      final place = _pickStr(em, ['place', 'placeName']);
      final tag = _pickStr(em, ['emotion']);
      final url = _pickStr(em, ['imageurl', 'imageUrl', 'imageURL']);
      if (tag.isNotEmpty) emoTagSet.add(tag);
      if (place.isNotEmpty && tag.isNotEmpty && url.isNotEmpty) {
        emotionComboSet.add('${place}__${tag}');
      }
    }

    final emoList = emoTagSet.toList()..sort();
    if (!emoList.contains('무감정')) emoList.insert(0, '무감정');

    characterBlock.writeln('- 이름: ${name.isEmpty ? '미정' : name}');
    characterBlock.writeln('  소개/설정: ${setting.isEmpty ? '없음' : setting}');
    characterBlock.writeln(
      '  사용가능감정태그: ${emoList.isEmpty ? '없음' : emoList.join(', ')}',
    );
  }

  final abilityLines = abilityComboSet.toList()..sort();
  final emotionLines = emotionComboSet.toList()..sort();

  final abilityAssetBlock =
      abilityLines.isEmpty ? '없음' : abilityLines.map((e) => '- $e').join('\n');
  final emotionAssetBlock =
      emotionLines.isEmpty ? '없음' : emotionLines.map((e) => '- $e').join('\n');

  // -------------------------
  // EventAssets (태그 -> 이미지 있는 것만)
  // -------------------------
  final evSet = <String>{};
  final evLines = <String>[];
  final evList = events ?? [];
  for (final ev in evList) {
    final em = _toMap(ev);
    final tag = _pickStr(em, ['event']);
    final url = _pickStr(em, ['imageurl', 'imageUrl', 'imageURL']);
    if (tag.isEmpty || url.isEmpty) continue;
    if (evSet.add(tag)) evLines.add('- $tag');
  }
  final eventAssetBlock = evLines.isEmpty ? '없음' : evLines.join('\n');

  final modeText = isNovelMode
      ? '소설모드 (유저 입력을 기다리지 않고 계속 진행)'
      : '자유모드 (유저 입력을 기다림, 유저 대사는 절대 쓰지 않음)';

  final modeRule = isNovelMode
      ? '''
- 절대 금지: [DIALOGUE SPEAKER="{user}" ...]
- [TURN_HEADER]를 절대 출력하지 마라.
- 장소는 여러 턴 동안 유지할 수 있고,
  장면 전환이 있을 때 주로 장소를 변경해라.
'''
      : '''
- 절대 금지: [DIALOGUE SPEAKER="{user}" ...]
- [TURN_HEADER]를 절대 출력하지 마라.
- 장소는 여러 턴 동안 유지할 수 있고,
  장면 전환이 있을 때 주로 장소를 변경해라.
''';

  final noteSection = userNote.trim().isNotEmpty ? userNote.trim() : '';
  final memorySection =
      (summary != null && summary.trim().isNotEmpty) ? summary.trim() : '';

  return '''
너는 웹소설가 AI다.

[모드]
$modeText
$modeRule

[세계관/기본정보]
제목: $storyTitle
배경/설정: $storySetting
유저역할: $userRole
채팅에서 유저이름: $userInChatName

[주요 장소]
$safePlacesText

[주요 이벤트]
$safeEventsText

[캐릭터]
$characterBlock

[자산 목록(=이미지로 보여줄 수 있는 태그 목록)]
배경자산(장소 배경): $bgBlock

능력자산(장소__능력):
$abilityAssetBlock

감정자산(장소__감정):
$emotionAssetBlock

이벤트자산:
$eventAssetBlock

[일관성 규칙]
- 인과관계를 유지해라.
- 장소를 바꿀 때는 "주요 장소"에 있는 이름을 우선 사용해라.
- 장소가 배경자산에 없어도 __PLACE__에는 사용할 수 있다.
  단, 배경자산에 없는 장소는 배경 SHOW_IMAGE를 출력하지 마라.
- 능력자산/감정자산은 반드시 "장소__태그"가 정확히 일치할 때만 사용해라.
- 이벤트자산은 "정확히 그 순간"에만 사용해라(미리 쓰지 마라).

[출력 포맷 — 아래 태그만 사용]
✅ 장소: 
[NARRATION]__PLACE__=장소명[/NARRATION]
1) 매 응답의 “첫 줄”은 무조건 이 포맷 1줄을 출력한다.
2) 이 줄에는 장소명 외에 어떤 글자도 넣지 마라(설명/문장 금지).
3) 장소자산이 없는 장소라도 장소 신호는 반드시 출력한다.

✅ (이미지 출력)
[SHOW_IMAGE="자산이름"]
중요 규칙:
1) "자산이름"은 아래 목록 중 하나와 “완전 동일”해야만 한다.
   - 배경자산(장소명)
   - 능력자산(장소__능력)
   - 감정자산(장소__감정)
   - 이벤트자산(이벤트 태그)
2) 배경 규칙:
   - 장소가 바뀌었고, 새 장소가 배경자산에 있으면
     그 턴 상단에 배경 SHOW_IMAGE를 정확히 1번만 출력하라.
   - 장소가 바뀌었지만 배경자산에 없으면
     배경 SHOW_IMAGE는 출력하지 말고 __PLACE__만 갱신하라.
3) 능력 규칙:
   - 현재 장소가 PLACE이고, 행동/상황이 ABILITY와 정확히 일치할 때만
     [SHOW_IMAGE="PLACE__ABILITY"]를 상단에 1번 출력하라.
4) 감정 규칙:
   - 현재 장소가 PLACE이고, 감정이 EMOTION과 정확히 일치할 때만
     [SHOW_IMAGE="PLACE__EMOTION"]을 상단에 1번 출력하라.
5) 이벤트 규칙(가장 중요):
   - "지금 이 순간이 그 이벤트"일 때만 [SHOW_IMAGE="EVENT_TAG"]를 1번 출력하라.
   - 절대 미리 출력하지 마라.
   - 절대 새로운 태그를 만들지 마라.

✅ (서술)
[NARRATION]내용[/NARRATION]

✅ (대사)
[DIALOGUE SPEAKER="이름" ACTION="감정"]내용[/DIALOGUE]
- ACTION은 선택이지만, 감정을 확신 못 하면 ACTION="무감정"을 써라.

[절대 금지]
1) 태그 밖의 일반 텍스트를 절대 출력하지 마라.
2) 서술/대사 내용에 따옴표(")를 쓰지 마라.
   따옴표는 태그 속성에만 허용된다:
   [SHOW_IMAGE="..."] 와 [DIALOGUE SPEAKER="..." ACTION="..."]
3) 괄호 연기 금지: ( ... )
4) [TURN_HEADER] 출력 금지.

[동적 컨텍스트(기억/유저 메모)]
$memorySection
$noteSection

이제 다음 스토리 턴을 태그만 사용해서 작성하라.
''';
}

int getPointCost(String? modelName) {
  if (modelName == null || modelName.isEmpty) {
    return 1300; // 기본값을 Gemini 2.5 Pro로 설정
  }

  // 새로운 포인트 정책을 반영합니다.
  switch (modelName) {
    // OpenAI
    case 'gpt-4o':
      return 1250;

    // Anthropic
    case 'claude-3-sonnet-20240229': // claude-sonnet-4.0의 정확한 모델명 예시
      return 2000;
    case 'claude-3-haiku-20240307': // claude-haiku-3.5의 정확한 모델명 예시
      return 300;

    // Google
    case 'gemini-2.5-pro': // gemini-2.5-pro의 정확한 모델명 예시
      return 1300;
    case 'gemini-2.5-flash': // gemini-2.5-flash의 정확한 모델명 예시
      return 300;

    // Groq (OpenAI 호환)
    case 'gemma-2-9b-instruct':
      // Groq 모델들은 비용이 매우 저렴하므로, 별도의 포인트 정책을 적용할 수 있습니다.
      // 예시로 최소 비용을 책정합니다.
      return 50;
    case 'llama3-70b-8192': // llama-4-maverick의 정확한 모델명 예시
      return 100;

    default:
      return 300; // 목록에 없는 모델은 기본값으로 처리
  }
}

List<StoryChatMessageStructStruct> mapJsonToStoryChatStructs(
    List<dynamic> jsonList) {
  if (jsonList == null || jsonList.isEmpty) {
    return [];
  }

  return jsonList.map((json) {
    final data = json as Map<String, dynamic>;
    return StoryChatMessageStructStruct(
      // Firestore의 'text' 또는 'content' 필드를 앱의 'text'로 연결
      text: data['text'] ?? data['content'] ?? '',

      // Firestore의 'type' (narration 등) 연결. 없으면 narration 기본값.
      type: data['type'] ?? 'narration',

      // [핵심!] Firestore는 snake_case, 앱은 camelCase일 수 있음. 둘 다 체크.
      speakerName: data['speaker_name'] ?? data['speakerName'] ?? 'ai',

      // 이미지 URL 연결
      storyImageUrl: data['story_image_url'] ?? data['storyImageUrl'],

      // Role 연결 (필요 시)
      // role: data['role'] ?? 'assistant',
    );
  }).toList();
}

String formatNumberCompact(int count) {
  if (count == null) return '0';
  if (count < 1000) {
    return count.toString();
  } else if (count < 1000000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  } else {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

String convertCharactersToString(List<CharacterStructStruct> charList) {
  if (charList.isEmpty) {
    return "설정된 캐릭터 없음";
  }

  String result = "";

  for (var char in charList) {
    String name = char.name;
    String desc = char.setting;

    result += "- 이름: $name\n  설정: $desc\n\n";
  }

  return result.trim();
}

String stringToImagePath(String? imageUrl) {
  final s = (imageUrl ?? '').trim();
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  return '';
}

bool isSummaryTurn(int messageCount) {
  return messageCount > 0 && messageCount % 20 == 0;
}

List<dynamic> combineJsonLists(
  List<dynamic>? list1,
  List<dynamic>? list2,
) {
  List<dynamic> combined = [];
  if (list1 != null) combined.addAll(list1);
  if (list2 != null) combined.addAll(list2);
  return combined;
}

List<StoryChatMessageStructStruct> mergeChatLists(
  List<StoryChatMessageStructStruct>? list1,
  List<StoryChatMessageStructStruct>? list2,
) {
// 두 리스트를 합쳐서 반환 (null 안전 처리)
  return [...(list1 ?? []), ...(list2 ?? [])];
}

List<StoriesRecord> sortStories(
  List<StoriesRecord> storyList,
  String sortBy,
) {
// 리스트를 복사해서 새로운 리스트를 만듭니다 (안전성 확보)
  var sortedList = List<StoriesRecord>.from(storyList);

  if (sortBy == '인기순') {
    // 하트 수(heartCount)가 많은 순서대로(내림차순) 정렬
    sortedList.sort((a, b) => (b.heartCount ?? 0).compareTo(a.heartCount ?? 0));
  } else {
    // 생성일(createdTimestamp)이 최신인 순서대로(내림차순) 정렬
    sortedList.sort((a, b) {
      DateTime timeA = a.createdTimestamp ?? DateTime(1900);
      DateTime timeB = b.createdTimestamp ?? DateTime(1900);
      return timeB.compareTo(timeA);
    });
  }
  return sortedList;
}

List<StoryChatMessageStructStruct> parsePrologueToMessages(
  String? prologueText,
  List<CharacterStructStruct> characters,
  List<PlaceStructStruct> places,
) {
  if (prologueText == null || prologueText.isEmpty) {
    return [];
  }

  List<StoryChatMessageStructStruct> messages = [];
  final lines = prologueText.split('\n');

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('[Image:') && line.endsWith(']')) {
      String condition = line.substring(7, line.length - 1).trim();
      String foundImageUrl = '';

      // 1) 장소(배경)에서 찾기
      for (var bg in places) {
        if ((bg.place ?? '').trim() == condition) {
          foundImageUrl = (bg.imageUrl ?? '').trim();
          break;
        }
      }

      // 2) 캐릭터 능력(상황) 이미지에서 찾기
      if (foundImageUrl.isEmpty) {
        for (var char in characters) {
          for (var sit in (char.abilityStruct ?? [])) {
            if (((sit.ability ?? '').trim()) == condition) {
              foundImageUrl = (sit.imageUrl ?? '').trim();
              break;
            }
          }
          if (foundImageUrl.isNotEmpty) break;
        }
      }

      if (foundImageUrl.isNotEmpty) {
        messages.add(createStoryChatMessageStructStruct(
          type: 'story_image',
          storyImageUrl: foundImageUrl,
          text: '',
          speakerName: '',
        ));
      }
    } else if (line.contains('|')) {
      final parts = line.split('|');
      if (parts.length >= 2) {
        String name = parts[0].trim();
        String content = parts.sublist(1).join('|').trim();

        messages.add(createStoryChatMessageStructStruct(
          type: 'dialogue',
          text: content,
          speakerName: name,
          storyImageUrl: '',
        ));
      } else {
        messages.add(createStoryChatMessageStructStruct(
          type: 'narration',
          text: line,
          speakerName: 'ai',
        ));
      }
    } else {
      messages.add(createStoryChatMessageStructStruct(
        type: 'narration',
        text: line,
        speakerName: 'ai',
      ));
    }
  }

  return messages;
}

List<EmotionStructStruct> getEmptyEmotionList() {
  return [];
}

List<AbilityStructStruct> getEmptyabilityList() {
  return [];
}

String getSituationTagString(List<CharacterStructStruct> characters) {
  if (characters.isEmpty) {
    return "없음";
  }

  final set = <String>{};

  for (final char in characters) {
    for (final s in (char.abilityStruct ?? [])) {
      final a = (s.ability ?? '').toString().trim();
      if (a.isNotEmpty) set.add(a);
    }
  }

  if (set.isEmpty) return "없음";
  return set.map((s) => "- $s").join('\n');
}

String getEmotionTagString(List<CharacterStructStruct> characters) {
  if (characters.isEmpty) {
    return "없음";
  }

  final set = <String>{};

  for (final char in characters) {
    for (final e in (char.emotionStruct ?? [])) {
      final emo = (e.emotion ?? '').toString().trim();
      if (emo.isNotEmpty) set.add(emo);
    }
  }

  if (set.isEmpty) return "없음";
  return set.map((e) => "- $e").join('\n');
}

String getBackgroundTagString(List<PlaceStructStruct>? backgrounds) {
  if (backgrounds == null || backgrounds.isEmpty) {
    return "없음";
  }

  return backgrounds.map((bg) => "- ${bg.place}").join('\n');
}

String joinPlaceNames(List<PlaceStructStruct>? list) {
  if (list == null || list.isEmpty) return '';
  return list
      .map((e) => (e.place).trim())
      .where((e) => e.isNotEmpty)
      .toSet()
      .join('|');
}

List<StoryChatMessageStructStruct> getemptyStoryChatMessages() {
  return <StoryChatMessageStructStruct>[];
}

String prologueTextToTagScript(
  String prologueText,
  List<CharacterStructStruct> characters,
  List<PlaceStructStruct> backgrounds,
) {
  final cleaned = cleanPrologue(prologueText);
  return prologueUiToTags(cleaned, characters, backgrounds);
}

String prologueUiToTags(
  String input,
  List<CharacterStructStruct> characters,
  List<PlaceStructStruct> places,
) {
  final text = input.replaceAll('\r\n', '\n').trim();

  final characterNames = characters
      .map((c) => (c.name).toString().trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  // ✅ 배경 place 목록
  final bgAssets = places
      .map((b) => (b.place).toString().trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  // ✅ 상황(능력) 목록: abilityStruct의 ability 값만 수집
  final situationAssets = <String>{};
  for (final c in characters) {
    for (final s in (c.abilityStruct ?? <AbilityStructStruct>[])) {
      final cond = (s.ability).toString().trim();
      if (cond.isNotEmpty) situationAssets.add(cond);
    }
  }

  // ✅ 캐릭터별 허용 감정 목록: emotionStruct의 emotion 값만 수집
  final emotionsByChar = <String, Set<String>>{};
  for (final c in characters) {
    final charName = (c.name).toString().trim();
    final emos = <String>{};
    for (final e in (c.emotionStruct ?? <EmotionStructStruct>[])) {
      final emo = (e.emotion).toString().trim();
      if (emo.isNotEmpty) emos.add(emo);
    }
    if (charName.isNotEmpty) emotionsByChar[charName] = emos;
  }

  // ✅ 전역 감정 리스트: 7개만
  final globalAllowedEmotions = <String>{
    '무감정',
    '기쁨',
    '슬픔',
    '혐오',
    '두려움',
    '놀람',
    '분노',
  };

  final headerRe = RegExp(
      r'^\[\s*\d{4}년\s*\d{2}월\s*\d{2}일\s*\d{2}시\s*\d{2}분\s*\|\s*.+\s*\]\s*$');

  String stripParensInContent(String s) {
    return s
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  // ✅ 감정 정규화(7개)
  String normalizeEmotion(String raw, Set<String> allowed) {
    final allowed7 = <String>{
      '무감정',
      '기쁨',
      '슬픔',
      '혐오',
      '두려움',
      '놀람',
      '분노',
    };

    final useAllowed = allowed.isNotEmpty ? allowed : allowed7;

    final r = raw.trim();
    if (r.isEmpty) return '무감정';
    if (useAllowed.contains(r)) return r;

    final compact = r.replaceAll(' ', '');

    if (compact.contains('공포') || compact.contains('두려')) return '두려움';
    if (compact.contains('화') ||
        compact.contains('분노') ||
        compact.contains('화남')) return '분노';
    if (compact.contains('혐오') ||
        compact.contains('역겹') ||
        compact.contains('메스꺼')) return '혐오';
    if (compact.contains('놀라') || compact.contains('경악')) return '놀람';
    if (compact.contains('기쁘') ||
        compact.contains('행복') ||
        compact.contains('웃')) return '기쁨';
    if (compact.contains('슬프') ||
        compact.contains('울') ||
        compact.contains('눈물')) return '슬픔';

    return '무감정';
  }

  final lines =
      text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  final outLines = <String>[];

  bool keptOneBg = false;
  final keptSituations = <String>[];

  bool hasPlace = false;

  for (final raw0 in lines) {
    if (headerRe.hasMatch(raw0)) continue;

    final raw =
        stripParensInContent(raw0.replaceAll('"', '').replaceAll("'", ""));

    // ✅ 1) 장소:
    if (raw.startsWith('장소:') || raw.startsWith('장소 :')) {
      final p = raw.split(':').sublist(1).join(':').trim();
      if (p.isEmpty) continue;

      if (!hasPlace) {
        hasPlace = true;

        outLines.add('[NARRATION]__PLACE__$p[/NARRATION]');

        if (!keptOneBg && bgAssets.contains(p)) {
          outLines.add('[SHOW_IMAGE="$p"]');
          keptOneBg = true;
        }
      }
      continue;
    }

    // ✅ 2) 상황: (능력 태그) -> 자산에 있을 때만 SHOW_IMAGE
    if (raw.startsWith('상황:') || raw.startsWith('상황 :')) {
      final sit = raw.split(':').sublist(1).join(':').trim();
      if (sit.isEmpty) continue;

      if (keptSituations.contains(sit)) continue;
      if (keptSituations.length >= 2) continue;

      if (situationAssets.contains(sit)) {
        outLines.add('[SHOW_IMAGE="$sit"]');
        keptSituations.add(sit);
      }
      continue;
    }

    // ✅ 3) 이름(감정): 대사  또는 이름: 대사
    final m =
        RegExp(r'^(.+?)\s*(?:\(\s*(.+?)\s*\))?\s*:\s*(.+)$').firstMatch(raw);

    if (m != null) {
      final speaker = (m.group(1) ?? '').trim();
      final emoRaw = (m.group(2) ?? '').trim();
      var speech = (m.group(3) ?? '').trim();
      speech = stripParensInContent(speech);

      if (speaker.isEmpty || speech.isEmpty) continue;
      if (speaker == '{user}') continue;

      if (!characterNames.contains(speaker)) {
        outLines.add('[DIALOGUE SPEAKER="$speaker"]$speech[/DIALOGUE]');
        continue;
      }

      final perCharAllowed = emotionsByChar[speaker] ?? <String>{};
      final allowed =
          perCharAllowed.isNotEmpty ? perCharAllowed : globalAllowedEmotions;
      final emo = normalizeEmotion(emoRaw, allowed);

      outLines
          .add('[DIALOGUE SPEAKER="$speaker" ACTION="$emo"]$speech[/DIALOGUE]');
      continue;
    }

    // ✅ 4) 그 외: 내레이션
    if (raw.isNotEmpty) {
      outLines.add('[NARRATION]$raw[/NARRATION]');
    }
  }

  // ✅ 장소 라인이 없으면 안전장치
  if (!hasPlace) {
    final fallbackPlace = bgAssets.isNotEmpty ? bgAssets.first : '어딘가';
    outLines.insert(0, '[NARRATION]__PLACE__$fallbackPlace[/NARRATION]');
    if (!keptOneBg && bgAssets.contains(fallbackPlace)) {
      outLines.insert(1, '[SHOW_IMAGE="$fallbackPlace"]');
    }
  }

  return outLines.join('\n').trim();
}

String cleanPrologue(String s) {
  var out = s.trim();
  out = out.replaceAll('```json', '').replaceAll('```', '').trim();

  // ✅ 새 포맷: "장소:"가 있으면 그 줄부터 잘라내기
  final idxPlace = out.indexOf('장소:');
  if (idxPlace > 0) out = out.substring(idxPlace).trim();

  return out;
}

String parseMajorPlacesTextToJson(String raw) {
  final text = raw.replaceAll('\r\n', '\n').trim();
  if (text.isEmpty) return '[]';

  final out = <Map<String, String>>[];
  final seen = <String>{};

  for (final lineRaw in text.split('\n')) {
    final line = lineRaw.trim();
    if (line.isEmpty) continue;

    String name = '';
    String desc = '';

    // "장소명: 설명" 우선
    final idx = line.indexOf(':');
    if (idx >= 0) {
      name = line.substring(0, idx).trim();
      desc = line.substring(idx + 1).trim();
    } else {
      // ":"가 없으면 전체를 장소명으로 취급
      name = line.trim();
      desc = '';
    }

    if (name.isEmpty) continue;
    if (!seen.add(name)) continue;

    out.add({'name': name, 'desc': desc});
  }

  return jsonEncode(out);
}

String composeMemoryBlock(
  int turnCount,
  int chapterIndex,
  String storyBible,
  String chapterState,
  String longSummary,
) {
  final t = (turnCount).toString();
  final c = (chapterIndex).toString();

  final bible = (storyBible).trim();
  final state = (chapterState).trim();
  final summary = (longSummary).trim();

  return '''
[MEMORY META]
Turn: $t
Chapter: $c

[STORY_BIBLE]
${bible.isEmpty ? '(empty)' : bible}
[/STORY_BIBLE]

[CHAPTER_STATE]
${state.isEmpty ? '(empty)' : state}
[/CHAPTER_STATE]

[LONG_SUMMARY]
${summary.isEmpty ? '(empty)' : summary}
[/LONG_SUMMARY]
'''
      .trim();
}

String pickOutlineForTurn(
  String outlineText,
  int turnCount,
) {
  final raw = outlineText.trim();
  if (raw.isEmpty) return '';

  String clean(String s) {
    var t = s.replaceAll('\r\n', '\n').trim();
    t = t.replaceAll('```', '');
    t = t.replaceAll('**', '');
    t = t.replaceAll('__', '');
    return t.trim();
  }

  final text = raw.replaceAll('\r\n', '\n');
  final lines = text.split('\n').map(clean).toList();

  final headerRe = RegExp(
      r'^$begin:math:display$\(\?\:CH\|ch\|챕터\)\\s\*\(\\d\+\)\\s\+\(\\d\+\)\\s\*\-\\s\*\(\\d\+\)$end:math:display$\s*$');

  final blocks = <Map<String, dynamic>>[];

  int? curCh;
  int? curA;
  int? curB;
  final buf = <String>[];

  void flush() {
    if (curCh != null && curA != null && curB != null) {
      final body = buf.where((e) => e.isNotEmpty).join('\n').trim();
      blocks.add({'ch': curCh, 'a': curA, 'b': curB, 'body': body});
    }
    buf.clear();
  }

  for (final l in lines) {
    final m = headerRe.firstMatch(l);
    if (m != null) {
      flush();
      curCh = int.tryParse(m.group(1)!);
      curA = int.tryParse(m.group(2)!);
      curB = int.tryParse(m.group(3)!);
      continue;
    }
    if (curCh != null) buf.add(l);
  }
  flush();

  if (blocks.isEmpty) return raw;

  for (final b in blocks) {
    final a = b['a'] as int;
    final bb = b['b'] as int;
    if (turnCount >= a && turnCount <= bb) {
      final body = (b['body'] as String).trim();
      return body.isEmpty ? raw : body;
    }
  }

  blocks.sort((x, y) => (x['a'] as int).compareTo(y['a'] as int));
  final last = blocks.last;
  final lastBody = (last['body'] as String).trim();
  return lastBody.isEmpty ? raw : lastBody;
}

String buildOutlineGuideBlock(
  String outlineText,
  int turnCount,
) {
  final picked = pickOutlineForTurn(
    outlineText,
    turnCount,
  ).trim();

  if (picked.isEmpty) return '';

  return '''
[OUTLINE GUIDE]
- 아래 가이드와 모순되지 않게 진행해라.
- 표현/디테일/대사는 자유롭게 창작해라.
- 유저의 이번 입력이 가이드보다 우선이다.

$picked
[/OUTLINE GUIDE]
'''
      .trim();
}

String dynamicContextByOutlineMode(
  bool outlineMode,
  String outlineText,
  int turnCount,
  int chapterIndex,
  String storyBible,
  String chapterState,
  String summary,
) {
  final enabled = outlineMode && outlineText.trim().isNotEmpty;
  if (!enabled) {
    return summary.trim();
  }

  final nextTurn = turnCount + 1;

  return (composeMemoryBlock(
            nextTurn,
            chapterIndex,
            storyBible,
            chapterState,
            summary,
          ) +
          '\n\n' +
          buildOutlineGuideBlock(
            outlineText,
            nextTurn,
          ))
      .trim();
}

List<String> extractTagsFromColonLines(String inputText) {
  final text = (inputText).trim();
  if (text.isEmpty) return [];

  final lines = text.split(RegExp(r'\r?\n'));
  final out = <String>[];
  final seen = <String>{};

  for (final raw in lines) {
    var line = raw.trim();
    if (line.isEmpty) continue;

    final idx = line.indexOf(':');
    if (idx >= 0) {
      line = line.substring(0, idx).trim();
    }

    if (line.isEmpty) continue;
    if (seen.add(line)) out.add(line);
  }
  return out;
}

List<PlaceStructStruct> updatePlaceTagByImageUrl(
  List<PlaceStructStruct> list,
  String imageUrl,
  String newPlace,
) {
  final out = List<PlaceStructStruct>.from(list);

  final u = imageUrl.trim();
  final p = newPlace.trim();
  if (u.isEmpty) return out;

  final idx = out.indexWhere((e) => (e.imageUrl ?? '').trim() == u);
  if (idx < 0) return out;

  final old = out[idx];
  out[idx] = createPlaceStructStruct(
    place: p,
    imageUrl: old.imageUrl,
  );
  return out;
}

List<CharacterStructStruct> addCharacter(
  List<CharacterStructStruct> list,
  CharacterStructStruct newChar,
) {
  final out = List<CharacterStructStruct>.from(list);
  out.add(newChar);
  return out;
}

List<EmotionStructStruct> updateEmotionImageUrlAt(
  List<EmotionStructStruct> list,
  String place,
  String imageUrl,
  String newEmotion,
) {
  final out = List<EmotionStructStruct>.from(list);

  final p = place.trim();
  final u = imageUrl.trim();
  final e = newEmotion.trim();

  if (p.isEmpty || u.isEmpty) return out;

  final idx = out.indexWhere((x) =>
      (x.place ?? '').toString().trim() == p &&
      (x.imageurl ?? '').toString().trim() == u);

  if (idx < 0) return out;

  final old = out[idx];

  out[idx] = createEmotionStructStruct(
    place: old.place,
    emotion: e,
    imageurl: old.imageurl,
  );

  return out;
}

List<AbilityStructStruct> updateAbilityTagByPlaceAndUrl(
  List<AbilityStructStruct> list,
  String place,
  String imageUrl,
  String newAbility,
) {
  final out = List<AbilityStructStruct>.from(list);

  final p = place.trim();
  final u = imageUrl.trim();
  final a = newAbility.trim();

  if (p.isEmpty || u.isEmpty) return out;

  final idx = out.indexWhere(
      (e) => (e.place ?? '').trim() == p && (e.imageUrl ?? '').trim() == u);

  if (idx < 0) return out;

  final old = out[idx];
  out[idx] = createAbilityStructStruct(
    place: old.place,
    ability: a,
    imageUrl: old.imageUrl,
  );
  return out;
}

List<CharacterStructStruct> updateCharacterAt(
  List<CharacterStructStruct> list,
  int index,
  CharacterStructStruct updated,
) {
  final out = List<CharacterStructStruct>.from(list);
  if (index < 0 || index >= out.length) return out;
  out[index] = updated;
  return out;
}

List<AbilityStructStruct> filterAbilityByPlace(
  List<AbilityStructStruct> list,
  String place,
) {
  final p = place.trim();
  if (p.isEmpty) return [];
  return list.where((e) => (e.place ?? '').trim() == p).toList();
}

List<EmotionStructStruct> filterEmotionByPlace(
  List<EmotionStructStruct> list,
  String place,
) {
  final p = place.trim();
  if (p.isEmpty) return [];
  return list.where((e) => (e.place ?? '').trim() == p).toList();
}
