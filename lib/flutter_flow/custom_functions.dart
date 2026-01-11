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

bool shouldSummarize(
  int currentCount,
  int lastCount,
) {
  return (currentCount - lastCount) >= 20;
}

String buildStoryPrompt(
  String storyTitle,
  String storySetting,
  List<CharacterStructStruct> characters,
  String userRole,
  String prologue,
  List<BackgroundStructStruct> backgrounds,
  String userNote,
  String userInChatName,
  String? summary,
  bool isNovelMode,
) {
  // 1. 캐릭터 설명 생성
  final characterDescriptions = StringBuffer();
  for (final char in characters) {
    characterDescriptions.writeln('<character>');
    characterDescriptions.writeln('  <name>${char.name}</name>');
    characterDescriptions
        .writeln('  <personality>${char.personality}</personality>');
    characterDescriptions.writeln('</character>');
  }

  // 2. [이사 완료] 시각적 연출 규칙 및 조건 리스트 생성
  // (기존 callAiProxy에 있던 로직을 여기서 처리)
  final conditionBuffer = StringBuffer();

  // 2-1. 배경(Background) 조건 추가
  for (final bg in backgrounds) {
    conditionBuffer.writeln('- [Background]: "${bg.placeName}"');
  }

  // 2-2. 캐릭터별 상황(Situation) 조건 추가
  for (final char in characters) {
    for (final sit in char.situationImages) {
      conditionBuffer.writeln('- [${char.name} Action]: "${sit.condition}"');
    }
  }

  // 2-3. 최종 시각 규칙 문자열 조립
  final String visualRules = '''
### 🎬 VISUAL DIRECTOR RULES
You MUST trigger images when the story matches specific conditions.
Output exactly: `{"type": "show_image", "condition": "Condition Text"}`.
Check the **Condition List** below:
<condition_list>
${conditionBuffer.toString()}
</condition_list>
''';

  // 3. [이사 완료] 감정 연기 규칙 (Emotion Rules)
  const String emotionRules = '''
### 🎭 EMOTION ACTING RULES
When a character speaks, infer their emotion and include it in the `action` attribute.
Keywords: "무감정", "기쁨", "슬픔", "화남", "놀람", "두려움", "행복", "사랑", "설렘", "부끄러움", "짜증", "실망", "우울", "진지".
Example: {"type": "dialogue", "speaker": "Hero", "action": "분노", "content": "Get out!"}
''';

  // 4. 유저 노트
  final userNoteSection = (userNote != null && userNote.isNotEmpty)
      ? '<user_note>\n${userNote}\n</user_note>'
      : '';

  // 5. 요약 (Summary) - 과거 기억
  final summarySection = (summary != null && summary.isNotEmpty)
      ? '''
### 📜 PREVIOUS STORY SUMMARY (MEMORY)
The story so far:
<memory>
${summary}
</memory>
'''
      : '';

  // 6. 프롤로그 (Prologue) - 조건부 생성
  // 내용이 있을 때만 태그를 포함, 없으면 빈 문자열 반환 (2번째 턴부터 자동 숨김)
  final prologueSection = (prologue != null && prologue.isNotEmpty)
      ? '''
<prologue_instruction>
${prologue}
</prologue_instruction>
'''
      : '';

  // 7. 모드별 지침
  String modeGuidelines;

  if (isNovelMode) {
    modeGuidelines = '''
### 🖋️ MODE: WEB NOVEL AUTHOR (PASSIVE / TAP NOVEL)
You are the sole author of a high-quality web novel.
1.  **Protagonist:** You have full control. The user ("${userInChatName}") is an observer.
2.  **Length:** 500~800 characters per response.
3.  **NO Actions in Dialogue:** Do NOT use parenthetical actions (e.g., "(smiling)") inside dialogue. Describe actions in **Narration**.
4.  **★ STRICT FORMATTING RULE:** Separate direct speech into `dialogue` objects.
''';
  } else {
    modeGuidelines = '''
### 🗣️ MODE: INTERACTIVE ROLEPLAY (FREE MODE)
You are interacting with the user ("${userInChatName}").
1.  **Interaction:** Wait for user input.
2.  **NO User Impersonation:** Never speak for the user.
3.  **NO Actions in Dialogue:** Describe actions in **Narration**.
''';
  }

  // 8. 최종 프롬프트 조립
  return '''
### ABSOLUTE ROLE
You are an AI storyteller using the JSON output format.

${modeGuidelines}

${emotionRules}

${visualRules}

### WRITING STYLE
- **Narration:** Detailed, immersive, and descriptive.
- **Dialogue:** Clean speech ONLY. No parentheses.

### OUTPUT FORMAT (CRITICAL)
**You must output a valid JSON list of objects.**
[
  {"type": "narration", "content": "Descriptive text..."},
  {"type": "dialogue", "speaker": "Name", "action": "Emotion", "content": "Speech text only"},
  {"type": "show_image", "condition": "Condition"}
]

### STORY BIBLE
${summarySection}
<title>${storyTitle}</title>
<setting>${storySetting}</setting>
<user_role>${userRole}</user_role>
${userNoteSection}

<characters>
${characterDescriptions.toString()}
</characters>

${prologueSection}

Now, start or continue the story in JSON format. Do NOT include Markdown code blocks (```json). Just the raw JSON array.
''';
}

List<dynamic> prologue(String userPrompt) {
  return [
    {
      'role': 'user',
      'content': userPrompt,
    },
  ];
}

bool isSceneType(
  dynamic scene,
  String expectedType,
) {
// scene이 유효한 JSON(Map 형태)이고 'type'이라는 키를 가지고 있는지 확인
  if (scene is Map<String, dynamic> && scene.containsKey('type')) {
    // scene의 'type' 값과 우리가 기대하는 'expectedType' 문자열이 일치하는지 확인
    return scene['type'] == expectedType;
  }
  // 조건에 맞지 않으면 false 반환
  return false;
}

String? findSituationalImageUrlByCondition(
  String condition,
  List imageList,
) {
// imageList가 null이거나 비어있으면 null을 반환합니다.
  if (imageList == null || imageList.isEmpty) {
    return null;
  }

  // 전달받은 상황별 이미지 리스트를 순회합니다.
  for (final img in imageList) {
    // 만약 리스트의 condition과 AI가 보낸 condition이 일치하면,
    if (img.condition == condition) {
      // 해당 이미지 URL을 반환합니다.
      return img.imageUrl;
    }
  }

  // 리스트 전체를 찾아봐도 일치하는 조건이 없으면, null을 반환합니다.
  return null;
}

String? findCharacterImageByName(
  String speakerName,
  List<CharacterStructStruct> characterList,
  String defaultImage,
) {
// characterList가 null이면 기본 이미지를 반환합니다.
  if (characterList == null) {
    return defaultImage;
  }
  // 전달받은 캐릭터 리스트를 순회합니다.
  for (final char in characterList) {
    // 만약 리스트의 캐릭터 이름과 현재 화자 이름이 일치하면,
    if (char.name == speakerName) {
      // 해당 캐릭터의 이미지 URL을 반환합니다.
      return char.image;
    }
  }
  // 리스트 전체를 찾아봐도 일치하는 이름이 없으면(AI가 만든 임의 캐릭터),
  // 파라미터로 받은 기본 이미지를 반환합니다.
  return defaultImage;
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

  // 👇 생성하는 Struct를 StoryChatMessageStruct로 수정
  return jsonList
      .map((json) =>
          StoryChatMessageStructStruct.fromMap(json as Map<String, dynamic>))
      .toList();
}

List<CharacterChatMessageStructStruct> mapJsonToCharacterChatStructs(
    List<dynamic> jsonList) {
  if (jsonList == null || jsonList.isEmpty) {
    return [];
  }

  return jsonList
      .map((json) => CharacterChatMessageStructStruct.fromMap(
          json as Map<String, dynamic>))
      .toList();
}

bool isCharacterType(CombinedListItemStructStruct? item) {
// 이제 item은 강력한 타입을 가지므로, 'type' 필드에 직접 접근할 수 있습니다.
  if (item != null && item.type == 'character') {
    return true;
  }
  return false;
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

DocumentReference? createStoryRef(String? documentId) {
  if (documentId == null || documentId.isEmpty) return null;
  return FirebaseFirestore.instance.collection('stories').doc(documentId);
}

DocumentReference? createCharacterRef(String? documentId) {
  if (documentId == null || documentId.isEmpty) return null;
  return FirebaseFirestore.instance.collection('character').doc(documentId);
}

String? formatExamplesToString(List<String> dialogueList) {
  final buffer = StringBuffer();
  for (final dialogue in dialogueList) {
    // (원본 코드의 'dialoge' 오타 수정)
    buffer.writeln('<example>${dialogue}</example>');
  }
  return buffer.toString();
}

int calculateCreatorEarning(String? modelName) {
  if (modelName == null || modelName.isEmpty) {
    return 1000; // 기본값을 Gemini 2.5 Pro로 설정
  }

  // 새로운 포인트 정책을 반영합니다.
  switch (modelName) {
    // OpenAI
    case 'gpt-4o':
      return 900;

    // Anthropic
    case 'claude-3-sonnet-20240229':
      return 1500;
    case 'claude-3-haiku-20240307':
      return 200;

    // Google
    case 'gemini-2.5-pro':
      return 1000;
    case 'gemini-2.5-flash':
      return 200;

    // Groq
    case 'gemma-2-9b-instruct':
      return 30;
    case 'llama3-70b-8192':
      return 70;

    default:
      return 200; // 목록에 없는 모델은 기본값으로 처리
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

String getImageSystemPrompt(String imageMode) {
  if (imageMode == 'character') {
    return "You are a character designer. Write a detailed Stable Diffusion prompt (English) for a character appearance based on the context.";
  } else if (imageMode == 'situation') {
    return "You are a storyboard artist. Write a detailed Stable Diffusion prompt (English) for a specific scene based on the context.";
  } else {
    // main
    return "You are a book cover designer. Write a highly artistic Stable Diffusion prompt (English) for a fantasy novel cover.";
  }
}

String stringToImagePath(String imageUrl) {
  return imageUrl;
}

List<dynamic> getEmptyList() {
  return [];
}

bool isValidImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty || imageUrl == 'null') {
    return false;
  }
  return true;
}

String? imageToString(String? imagePath) {
  return imagePath;
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
