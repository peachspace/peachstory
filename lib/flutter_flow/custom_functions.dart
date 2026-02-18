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
      majorPlacesText.trim().isEmpty ? 'None' : majorPlacesText.trim();
  final safeEventsText =
      majorEventsText.trim().isEmpty ? 'None' : majorEventsText.trim();

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
  final bgBlock = bgSet.isEmpty ? 'None' : bgSet.join(', ');

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

    characterBlock.writeln('- Name: ${name.isEmpty ? 'Unknown' : name}');
    characterBlock.writeln('  Setting: ${setting.isEmpty ? 'None' : setting}');
    characterBlock.writeln(
      '  AvailableEmotionTags: ${emoList.isEmpty ? 'None' : emoList.join(', ')}',
    );
  }

  final abilityLines = abilityComboSet.toList()..sort();
  final emotionLines = emotionComboSet.toList()..sort();

  final abilityAssetBlock = abilityLines.isEmpty
      ? 'None'
      : abilityLines.map((e) => '- $e').join('\n');
  final emotionAssetBlock = emotionLines.isEmpty
      ? 'None'
      : emotionLines.map((e) => '- $e').join('\n');

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
  final eventAssetBlock = evLines.isEmpty ? 'None' : evLines.join('\n');

  final modeText = isNovelMode
      ? 'WEB NOVEL (Continue story without waiting user input)'
      : 'ROLEPLAY (Wait user input, never speak as the user)';

  final modeRule = isNovelMode
      ? '''
[MODE RULES - NOVELMODE]
- The "user" role message you receive is NOT the character {user}'s dialogue.
  It can be a system directive like: [SYSTEM: Next Scene ...]
- Do NOT output any dialogue line as the user.
  Never use: [DIALOGUE SPEAKER="{user}" ...]
- {user} may be mentioned as a person inside narration/dialogue (3rd person).
- The system will add the turn header. Never output [TURN_HEADER] yourself.
- LOCATION PACING: Keep the same location for multiple turns.
  Only change location when a major scene shift happens.
'''
      : '''
[MODE RULES - FREEMODE]
- The real user sends messages separately. Never speak as the user.
- Never output: [DIALOGUE SPEAKER="{user}" ...]
- The system will add the turn header. Never output [TURN_HEADER] yourself.
- LOCATION PACING: Keep the same location for multiple turns.
  Only change location when a major scene shift happens.
''';

  final noteSection = userNote.trim().isNotEmpty ? userNote.trim() : '';
  final memorySection =
      (summary != null && summary.trim().isNotEmpty) ? summary.trim() : '';

  return '''
You are an AI storyteller.

[MODE]
$modeText
$modeRule

[WORLD BIBLE]
Title: $storyTitle
Setting: $storySetting
UserRole: $userRole
UserNameInChat: $userInChatName

[MAJOR PLACES]
$safePlacesText

[MAJOR EVENTS]
$safeEventsText

[CHARACTERS]
$characterBlock

[ASSET LIST]
BackgroundAssets: $bgBlock

AbilityAssets (Place__Ability):
$abilityAssetBlock

EmotionAssets (Place__Emotion):
$emotionAssetBlock

EventAssets:
$eventAssetBlock

[STORY CONSISTENCY RULES]
- Use MAJOR EVENTS as the backbone of progression.
- Keep causal flow (earlier events should lead to later events).
- When changing locations, prefer names from MAJOR PLACES.
- If a place is not in BackgroundAssets, you can still use it as __PLACE__,
  but do NOT output SHOW_IMAGE for background.
- AbilityAssets and EmotionAssets are strictly PLACE__TAG matches only.
- EventAssets are "very important moments". Use them only at the exact moment.

[CRITICAL OUTPUT FORMAT — ONLY THESE TAGS]
- Mandatory place signal (MUST be the FIRST line of every response):
  [NARRATION]__PLACE__[/NARRATION]
  Rules:
  1) __PLACE__ is the current location name in plain text.
  2) Do not include any other words in that line.
  3) Even if there is no background image asset, you MUST still output __PLACE__.

- For image display, output only:
  [SHOW_IMAGE="ASSET_NAME"]

  IMPORTANT:
  1) Only use ASSET_NAME if it EXACTLY matches one of:
     - BackgroundAssets (place name)
     - AbilityAssets (PLACE__ABILITY)
     - EmotionAssets (PLACE__EMOTION)
     - EventAssets (event tag)
  2) Background rule:
     - If the location changes AND the new place exists in BackgroundAssets,
       output exactly ONE background [SHOW_IMAGE="PLACE"] near the top of the turn.
     - If the location changes but the place is NOT in BackgroundAssets,
       do NOT output background SHOW_IMAGE. Only update the __PLACE__ line.
  3) Ability rule:
     - Only when the current place is PLACE and the action matches ABILITY,
       output [SHOW_IMAGE="PLACE__ABILITY"] once near the top.
  4) Emotion rule:
     - Only when the current place is PLACE and the character emotion matches EMOTION,
       output [SHOW_IMAGE="PLACE__EMOTION"] once near the top.
  5) Event rule (MOST IMPORTANT MOMENTS):
     - Only when the current story moment IS the event described by an EventAsset tag,
       output [SHOW_IMAGE="EVENT_TAG"] once near the top.
     - Do NOT output Event SHOW_IMAGE early.
     - Do NOT invent new tags.

- For narration:
  [NARRATION]text[/NARRATION]

- For dialogue:
  [DIALOGUE SPEAKER="NAME" ACTION="EMOTION"]text[/DIALOGUE]
  ACTION is optional, but if emotion is unknown, use ACTION="무감정".

[HARD BANS]
1) Do NOT output any plain text outside the tags.
2) Do NOT use quotes in narration/dialogue content.
   Quotes are ONLY allowed inside tag attributes exactly as shown:
   [SHOW_IMAGE="..."] and [DIALOGUE SPEAKER="..." ACTION="..."]
3) Do NOT use parenthetical acting: ( ... )
4) Never output [TURN_HEADER].

[DYNAMIC CONTEXT]
$memorySection
$noteSection

Now write the next story turn using only the tags.
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

  // 캐릭터 이름 목록
  final characterNames = characters
      .map((c) => (c.name ?? '').toString().trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  // 배경 place 목록
  final bgAssets = places
      .map((b) => (b.place ?? '').toString().trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  // 능력(상황) ability 목록
  final situationAssets = <String>{};
  for (final c in characters) {
    for (final s in (c.abilityStruct ?? [])) {
      final cond = (s.ability ?? '').toString().trim();
      if (cond.isNotEmpty) situationAssets.add(cond);
    }
  }

  // 캐릭터별 허용 감정 목록
  final emotionsByChar = <String, Set<String>>{};
  for (final c in characters) {
    final charName = (c.name ?? '').toString().trim();
    final emos = <String>{};
    for (final e in (c.emotionStruct ?? [])) {
      final emo = (e.emotion ?? '').toString().trim();
      if (emo.isNotEmpty) emos.add(emo);
    }
    if (charName.isNotEmpty) emotionsByChar[charName] = emos;
  }

  final globalAllowedEmotions = <String>{
    '무감정',
    '기쁨',
    '슬픔',
    '화남',
    '놀람',
    '공포',
    '혐오',
    '사랑',
    '설렘',
    '안도',
    '감동',
    '자신감',
    '장난',
    '만족',
    '감사',
    '짜증',
    '질투',
    '실망',
    '우울',
    '고통',
    '부끄러움',
    '당황',
    '경멸',
    '불안',
    '피곤',
    '지루함',
    '멍함',
    '호기심',
    '진지',
    '결의',
    '미침',
    '취함',
    '아픔',
    '배고픔'
  };

  final headerRe = RegExp(
      r'^\[\s*\d{4}년\s*\d{2}월\s*\d{2}일\s*\d{2}시\s*\d{2}분\s*\|\s*.+\s*\]\s*$');

  String stripParensInContent(String s) {
    return s
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  String normalizeEmotion(String raw, Set<String> allowed) {
    var e = raw.trim();
    if (e.isEmpty) return '무감정';
    if (allowed.contains(e)) return e;

    final lower = e.replaceAll(' ', '');
    String pick(String target) => allowed.contains(target) ? target : '무감정';

    if (lower.contains('냉정') || lower.contains('차갑') || lower.contains('무표정'))
      return pick('진지');
    if (lower.contains('떨') || lower.contains('긴장')) return pick('불안');
    if (lower.contains('짜증') || lower.contains('날카')) return pick('짜증');
    if (lower.contains('분노') || lower.contains('화')) return pick('화남');
    if (lower.contains('결심') || lower.contains('단호')) return pick('결의');
    if (lower.contains('웃') || lower.contains('미소')) return pick('기쁨');
    if (lower.contains('슬프') || lower.contains('울')) return pick('슬픔');
    if (lower.contains('설레')) return pick('설렘');
    if (lower.contains('놀라')) return pick('놀람');

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

    // 장소:
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

    // 상황(능력):
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

    // 이름(감정): 대사 / 이름: 대사
    final m =
        RegExp(r'^(.+?)\s*(?:\(\s*(.+?)\s*\))?\s*:\s*(.+)$').firstMatch(raw);

    if (m != null) {
      final speaker = m.group(1)!.trim();
      final emoRaw = (m.group(2) ?? '').trim();
      var speech = m.group(3)!.trim();
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

    // 나머지 내레이션
    if (raw.isNotEmpty) {
      outLines.add('[NARRATION]$raw[/NARRATION]');
    }
  }

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
