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
  List<BackgroundStructStruct> backgrounds,
  String userNote,
  String userInChatName,
  String? summary,
  bool isNovelMode,
  String majorPlacesText,
  String majorEventsText,
  List<EventstructStruct>? events,
) {
  // ---------- 0) 안전 정리 ----------
  final safePlacesText =
      majorPlacesText.trim().isEmpty ? 'None' : majorPlacesText.trim();
  final safeEventsText =
      majorEventsText.trim().isEmpty ? 'None' : majorEventsText.trim();

  // ---------- 1) 캐릭터 블록 ----------
  final characterBlock = StringBuffer();
  for (final c in characters) {
    final emotions = c.emotionimages
        .map((e) => (e.emotion).trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    if (!emotions.contains('무감정')) emotions.insert(0, '무감정');

    characterBlock.writeln('- Name: ${c.name}');
    characterBlock.writeln('  Personality: ${c.personality}');
    characterBlock.writeln(
      '  AvailableEmotionAssets: ${emotions.isEmpty ? 'None' : emotions.join(', ')}',
    );
  }

  // ---------- 2) 배경 자산 ----------
  final bgList = backgrounds
      .map((b) => (b.placeName).trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();
  final bgBlock = bgList.isEmpty ? 'None' : bgList.join(', ');

  // ---------- 3) 상황 자산 ----------
  final situationBlock = StringBuffer();
  final sitSet = <String>{};

  for (final c in characters) {
    for (final s in c.situationImages) {
      final cond = (s.condition).trim();
      if (cond.isNotEmpty && sitSet.add(cond)) {
        situationBlock.writeln('- $cond');
      }
    }
  }

  final sitBlock = situationBlock.toString().trim().isEmpty
      ? 'None'
      : situationBlock.toString().trim();

  // ---------- 4) 이벤트 자산 ----------
  // events: [{event:tag, imageurl:url}, ...]
  // 프롬프트에는 "태그"만 노출하고, 실제 URL 매핑은 processAndSaveChatTurn에서 함.
  final evSet = <String>{};
  final evLines = <String>[];

  final evList = events ?? [];
  for (final ev in evList) {
    final d = ev as dynamic;

    final tag = (d.event ?? '').toString().trim();
    final url = ((d.imageurl ?? d.imageUrl) ?? '').toString().trim();

    if (tag.isEmpty) continue;
    if (url.isEmpty) continue;

    if (evSet.add(tag)) evLines.add('- $tag');
  }

  final eventAssetBlock = evLines.isEmpty ? 'None' : evLines.join('\n');

  // ---------- 5) 모드 규칙 ----------
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

  // ---------- 6) 동적 컨텍스트 ----------
  final noteSection = userNote.trim().isNotEmpty ? userNote.trim() : '';
  final memorySection =
      (summary != null && summary.trim().isNotEmpty) ? summary.trim() : '';

  // ---------- 7) 최종 프롬프트 ----------
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
SituationAssets:
$sitBlock
EventAssets:
$eventAssetBlock

[STORY CONSISTENCY RULES]
- Use MAJOR EVENTS as the backbone of progression.
- Keep causal flow (earlier events should lead to later events).
- When changing locations, prefer names from MAJOR PLACES.
- If a place is not in BackgroundAssets, you can still use it as __PLACE__,
  but do NOT output SHOW_IMAGE for it.
- EventAssets are "very important moments". Use them only at the exact moment.

[CRITICAL OUTPUT FORMAT — ONLY THESE TAGS]
- Mandatory place signal (MUST be the FIRST line of every response):
  [NARRATION]__PLACE__[/NARRATION]
  Rules:
  1) __PLACE__ is the current location name in plain text.
  2) Do not include any other words in that line.
  3) Even if there is no background image asset, you MUST still output __PLACE__.

- For image display (background, situation, event), output only:
  [SHOW_IMAGE="ASSET_NAME"]

  IMPORTANT:
  1) Only use ASSET_NAME if it EXACTLY matches the Asset List
     (BackgroundAssets OR SituationAssets OR EventAssets).
  2) Background rule:
     - If the location changes AND the new place exists in BackgroundAssets,
       output exactly ONE background [SHOW_IMAGE="PLACE"] near the top of the turn.
     - If the location changes but the place is NOT in BackgroundAssets,
       do NOT output SHOW_IMAGE. Only update the __PLACE__ line.
  3) Situation rule:
     - If an action/condition moment clearly matches a SituationAsset,
       output [SHOW_IMAGE="SITUATION_TAG"] once near the top.
  4) Event rule (MOST IMPORTANT MOMENTS):
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
  if (charList == null || charList.isEmpty) {
    return "설정된 캐릭터 없음";
  }

  String result = "";

  for (var char in charList) {
    // 이름, 성격, 소개 등 필요한 필드를 가져옵니다.
    // 구조체 필드명(name, personality 등)은 사용자님 DB에 맞춰 수정하세요.
    String name = char.name;
    String desc = char.personality; // 혹은 char.intro 등

    result += "- 이름: $name\n  설정: $desc\n\n";
  }

  return result.trim();
}

String stringToImagePath(String? imageUrl) {
// 값이 없으면(null) 빈 문자열('')을 반환하고, 있으면 그 값을 반환합니다.
  return imageUrl ?? '';
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
  List<BackgroundStructStruct> backgrounds,
) {
  if (prologueText == null || prologueText.isEmpty) {
    return [];
  }

  List<StoryChatMessageStructStruct> messages = [];

  // 줄바꿈 단위로 쪼개서 분석합니다.
  final lines = prologueText.split('\n');

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;

    // 1. 이미지 태그 감지: [Image: Condition]
    if (line.startsWith('[Image:') && line.endsWith(']')) {
      String condition = line.substring(7, line.length - 1).trim();
      String foundImageUrl = '';

      // 배경에서 찾기
      for (var bg in backgrounds) {
        if (bg.placeName == condition) foundImageUrl = bg.imageUrl;
      }
      // 캐릭터 상황 이미지에서 찾기
      if (foundImageUrl.isEmpty) {
        for (var char in characters) {
          for (var sit in char.situationImages) {
            if (sit.condition == condition) foundImageUrl = sit.imageUrl;
          }
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
    }
    // 2. 대사 감지: 이름 | 대사
    else if (line.contains('|')) {
      final parts = line.split('|');
      if (parts.length >= 2) {
        String name = parts[0].trim();
        String content = parts.sublist(1).join('|').trim(); // 뒤에 또 |가 있을 수 있으므로

        messages.add(createStoryChatMessageStructStruct(
          type: 'dialogue',
          text: content,
          speakerName: name,
          storyImageUrl: '',
        ));
      } else {
        // 형식이 애매하면 그냥 지문으로
        messages.add(createStoryChatMessageStructStruct(
          type: 'narration',
          text: line,
          speakerName: 'ai',
        ));
      }
    }
    // 3. 나머지는 지문(Narration)
    else {
      messages.add(createStoryChatMessageStructStruct(
        type: 'narration',
        text: line,
        speakerName: 'ai',
      ));
    }
  }

  return messages;
}

List<EmotionImageStructStruct> getEmptyEmotionList() {
  return [];
}

List<SituationalImageStructStruct> getEmptysituationList() {
  return [];
}

String getSituationTagString(List<CharacterStructStruct> characters) {
  if (characters == null || characters.isEmpty) {
    return "없음";
  }

  // 모든 캐릭터를 돌면서 'situationImages' 안에 있는 'condition(상황태그)'을 수집합니다.
  List<String> allSituations = [];

  for (var char in characters) {
    for (var sit in char.situationImages) {
      if (sit.condition != null && sit.condition.isNotEmpty) {
        allSituations.add(sit.condition);
      }
    }
  }

  if (allSituations.isEmpty) {
    return "없음";
  }

  // 예시 출력: "- 칼뽑기\n- 울음\n- 도망"
  return allSituations.map((s) => "- $s").join('\n');
}

String getEmotionTagString(List<CharacterStructStruct> characters) {
  if (characters == null || characters.isEmpty) {
    return "없음";
  }

  // 모든 캐릭터의 emotionImages를 돌면서 'emotion(감정태그)'을 수집
  // 중복을 제거하기 위해 Set을 사용
  Set<String> uniqueEmotions = {};

  for (var char in characters) {
    for (var emo in char.emotionimages) {
      if (emo.emotion != null && emo.emotion.isNotEmpty) {
        uniqueEmotions.add(emo.emotion);
      }
    }
  }

  if (uniqueEmotions.isEmpty) {
    return "없음";
  }

  // 예시 출력: "- 기쁨\n- 슬픔\n- 분노"
  return uniqueEmotions.map((e) => "- $e").join('\n');
}

String getBackgroundTagString(List<BackgroundStructStruct>? backgrounds) {
// 1. 배경 리스트가 비어있거나 없으면 "없음" 반환
  if (backgrounds == null || backgrounds.isEmpty) {
    return "없음";
  }

  // 2. 배경 리스트를 순회하며 이름(placeName)만 뽑아서 줄바꿈으로 연결
  // 예시 결과:
  // - 학교
  // - 숲
  // - 집
  return backgrounds.map((bg) => "- ${bg.placeName}").join('\n');
}

String joinPlaceNames(List<BackgroundStructStruct>? list) {
  if (list == null || list.isEmpty) return '';
  return list
      .map((e) => (e.placeName ?? '').trim())
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
  List<BackgroundStructStruct> backgrounds,
) {
  final cleaned = cleanPrologue(prologueText);
  return prologueUiToTags(cleaned, characters, backgrounds);
}

String prologueUiToTags(
  String input,
  List<CharacterStructStruct> characters,
  List<BackgroundStructStruct> backgrounds,
) {
  final text = input.replaceAll('\r\n', '\n').trim();

  // 캐릭터 이름 목록
  final characterNames = characters
      .map((c) => (c.name ?? '').trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  // 배경 placeName 목록
  final bgAssets = backgrounds
      .map((b) => (b.placeName ?? '').trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  // 상황 condition 목록 (모든 캐릭터의 situationImages에서)
  final situationAssets = <String>{};
  for (final c in characters) {
    for (final s in c.situationImages) {
      final cond = (s.condition ?? '').trim();
      if (cond.isNotEmpty) situationAssets.add(cond);
    }
  }

  // 캐릭터별 허용 감정 목록
  final emotionsByChar = <String, Set<String>>{};
  for (final c in characters) {
    final charName = (c.name ?? '').trim();
    final emos = <String>{};
    for (final e in c.emotionimages) {
      final emo = (e.emotion ?? '').trim();
      if (emo.isNotEmpty) emos.add(emo);
    }
    if (charName.isNotEmpty) emotionsByChar[charName] = emos;
  }

  // 전역 감정 리스트
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

  // TURN_HEADER 같은 라인은 무시
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
    if (e.isEmpty) return allowed.contains('무감정') ? '무감정' : '무감정';
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

  // ✅ 결과는 리스트로 쌓아야 "장소 라인"을 맨 앞으로 강제하기 쉬움
  final outLines = <String>[];

  bool keptOneBg = false; // 프롤로그 배경 1개만
  final keptSituations = <String>[]; // 프롤로그 상황 0~2개만

  bool hasPlace = false;
  String? placeName; // 장소: 에서 뽑은 장소

  for (final raw0 in lines) {
    if (headerRe.hasMatch(raw0)) continue;

    // 따옴표 제거 + 괄호연출 제거(문장/대사 공통)
    final raw =
        stripParensInContent(raw0.replaceAll('"', '').replaceAll("'", ""));

    // ✅ 1) 장소: 장소명  -> __PLACE__ + (배경자산 있으면) 배경 SHOW_IMAGE 자동 1개
    if (raw.startsWith('장소:') || raw.startsWith('장소 :')) {
      final p = raw.split(':').sublist(1).join(':').trim();
      if (p.isEmpty) continue;

      // 중복 장소 라인 방지: 첫 번째만 채택
      if (!hasPlace) {
        hasPlace = true;
        placeName = p;

        // __PLACE__ 라인은 반드시 있어야 함
        outLines.add('[NARRATION]__PLACE__$p[/NARRATION]');

        // 배경 자산이 있으면 배경 SHOW_IMAGE 1개 자동 삽입
        if (!keptOneBg && bgAssets.contains(p)) {
          outLines.add('[SHOW_IMAGE="$p"]');
          keptOneBg = true;
        }
      }
      continue;
    }

    // ✅ 2) 상황: 상황태그  -> (자산에 있을 때만) SHOW_IMAGE만 출력 (텍스트 출력 금지)
    if (raw.startsWith('상황:') || raw.startsWith('상황 :')) {
      final sit = raw.split(':').sublist(1).join(':').trim();
      if (sit.isEmpty) continue;

      // 중복/개수 제한
      if (keptSituations.contains(sit)) continue;
      if (keptSituations.length >= 2) continue;

      // ✅ 상황 자산이 있을 때만 이미지 태그 추가
      if (situationAssets.contains(sit)) {
        outLines.add('[SHOW_IMAGE="$sit"]');
        keptSituations.add(sit);
      }

      // ✅ 상황 텍스트는 절대 출력하지 않는다
      continue;
    }

    // ✅ 6) 이름(감정): 대사  또는 이름: 대사
    final m =
        RegExp(r'^(.+?)\s*(?:\(\s*(.+?)\s*\))?\s*:\s*(.+)$').firstMatch(raw);

    if (m != null) {
      final speaker = m.group(1)!.trim();
      final emoRaw = (m.group(2) ?? '').trim();
      var speech = m.group(3)!.trim();
      speech = stripParensInContent(speech);

      if (speaker.isEmpty || speech.isEmpty) continue;

      // {user}가 프롤로그에서 말하면 안 됨
      if (speaker == '{user}') continue;

      // 캐릭터 목록 밖이면 감정 없이
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

    // ✅ 7) 그 외는 전부 "내레이션 문장"으로 처리 (라벨 없는 문장)
    if (raw.isNotEmpty) {
      outLines.add('[NARRATION]$raw[/NARRATION]');
    }
  }

  // ✅ 장소 라인이 없으면 안전장치로 맨 앞에 넣기
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
