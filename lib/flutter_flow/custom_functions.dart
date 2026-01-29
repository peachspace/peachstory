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
) {
  final characterDescriptions = StringBuffer();

  for (final char in characters) {
    String availableEmotions =
        char.emotionimages.map((e) => '"${e.emotion}"').join(', ');
    if (availableEmotions.isEmpty) availableEmotions = 'None';

    // 상황(조건) 리스트도 같이 보여주면 모델이 SHOW_IMAGE 조건을 더 잘 맞춤
    final availableSituations =
        char.situationImages.map((s) => '"${s.condition}"').join(', ');
    final sitText = availableSituations.isEmpty ? 'None' : availableSituations;

    characterDescriptions.writeln('<character>');
    characterDescriptions.writeln('  <name>${char.name}</name>');
    characterDescriptions
        .writeln('  <personality>${char.personality}</personality>');
    characterDescriptions
        .writeln('  <asset_emotions>[${availableEmotions}]</asset_emotions>');
    characterDescriptions
        .writeln('  <asset_situations>[${sitText}]</asset_situations>');
    characterDescriptions.writeln('</character>');
  }

  final backgroundListString =
      backgrounds.map((bg) => '"${bg.placeName}"').join(', ');

  final userNoteSection =
      (userNote.isNotEmpty) ? '<user_note>\n$userNote\n</user_note>' : '';

  final summarySection = (summary != null && summary.isNotEmpty)
      ? '<memory>\n$summary\n</memory>'
      : '';

  final modeGuidelines = isNovelMode
      ? '''
### MODE: WEB NOVEL
- User("$userInChatName") is an observer. Do NOT write user's lines as if they spoke.
- Keep going without waiting for user input.
'''
      : '''
### MODE: INTERACTIVE ROLEPLAY
- Wait for user input.
- Never speak for the user("$userInChatName").
- End with a clear prompt/question to the user.
''';

  return '''
### SYSTEM (STATIC)
You are an AI storyteller.

$modeGuidelines

### OUTPUT FORMAT (STRICT)
Output ONLY the following tags. No JSON. No markdown. No extra commentary.

1) Background / situation image trigger:
[SHOW_IMAGE="ConditionOrPlaceName"]

2) Narration:
[NARRATION]...[/NARRATION]

3) Dialogue (ALWAYS for spoken lines):
[DIALOGUE SPEAKER="NAME" ACTION="EMOTION_KEY_OR_EMPTY"]...[/DIALOGUE]

RULES:
- Spoken lines MUST be DIALOGUE tags. Never wrap dialogue in quotes.
- Do NOT use parentheses like (숨이 멎을 듯한...). No stage directions.
- If a speaker is not in the main character list, invent a role-based name (e.g. "재판장", "병사1") and still use DIALOGUE.
- Use SHOW_IMAGE ONLY when it matches an asset condition/place below.

### ASSET LIST (STRICT MATCHING)
[Background Assets] = [$backgroundListString]
- If story matches a place exactly (or very similar), output: [SHOW_IMAGE="AssetName"]
- If totally different, output no SHOW_IMAGE.

[Characters]
$characterDescriptions

Emotion ACTION:
- For each character, ACTION must be one of that character's <asset_emotions>.
- If no match, use ACTION="무감정".

Situation SHOW_IMAGE:
- If a situation happens and matches any <asset_situations> exactly, output [SHOW_IMAGE="that_condition"].

### WORLD BIBLE
<title>$storyTitle</title>
<setting>$storySetting</setting>
<user_role>$userRole</user_role>

### DYNAMIC CONTEXT
$summarySection
$userNoteSection
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
