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

List<dynamic> buildSimpleChatHistory(
    List<CharactermessagesRecord> messageDocs) {
  List<dynamic> formattedHistory = [];

  if (messageDocs.isEmpty) {
    return formattedHistory;
  }

  // 쿼리에서 타임스탬프 내림차순(Decreasing)으로 최신 메시지부터 가져왔으므로,
  // AI에게는 시간 순서대로(오래된 것이 먼저) 전달하기 위해 리스트를 뒤집어줍니다.
  for (var doc in messageDocs.reversed) {
    String role;

    // ▼▼▼ 핵심 수정 부분 ▼▼▼
    // 텍스트를 아무 가공 없이 있는 그대로 사용합니다.
    String content = doc.text;

    // Firestore의 'type' 필드 값에 따라 'role'을 결정합니다.
    if (doc.type == 'user') {
      role = 'user';
    } else {
      // 'ai', 'narration' 등 나머지는 모두 'assistant'로 처리합니다.
      role = 'assistant';
    }

    // 내용이 있는 경우에만 기록에 추가합니다.
    if (content.isNotEmpty) {
      formattedHistory.add({'role': role, 'content': content});
    }
  }

  print('--- AI에게 전달될 최종 messages 내용 ---');
  // 보기 편하도록 JSON 형태로 변환하여 출력합니다.
  print(jsonEncode(formattedHistory));

  return formattedHistory;
}

bool shouldSummarize(
  int currentCount,
  int lastCount,
) {
  return (currentCount - lastCount) >= 20;
}

String buildCharacterPrompt(
  String name,
  String setting,
  List<String> dialogueList,
  String userinput,
  List<SituationalImageStructStruct> situationalImages,
  String? userNote,
) {
  final String dialogueExamples = formatExamplesToString(dialogueList) ?? '';

  final situationalImageListXml = StringBuffer();
  for (final img in situationalImages) {
    situationalImageListXml.writeln('  <image condition="${img.condition}" />');
  }

  final imageSection = situationalImages.isNotEmpty
      ? '''
<available_situational_images>
${situationalImageListXml.toString()}
</available_situational_images>

To show a situational image, you MUST use the format: `[SHOW_IMAGE="condition"]`. This tag must be on its own line and will not be displayed to the user. Use it when the context perfectly matches one of the available image conditions.
'''
      : '';

  final userNoteSection = (userNote != null && userNote.isNotEmpty)
      ? '<user_note>\n${userNote}\n</user_note>'
      : '';

  return '''
You are an advanced AI tasked with roleplaying a specific Korean character in a conversational setting. Your goal is to engage in natural, in-character dialogues based on the provided information. Please read the following instructions carefully to ensure an authentic and immersive experience.

First, let's establish the character's background and speech patterns. Here are some dialogue examples to help you understand the character's personality:

<dialogue_examples>
${dialogueExamples}
</dialogue_examples>

Now, let's introduce the character you'll be portraying:

<character_name>
${name}
</character_name>

<character_setting>
${setting}
</character_setting>

<available_situational_images>
${situationalImageListXml.toString()}
</available_situational_images>

${userNoteSection}

Important rules to follow:
1. Never reveal that you are an AI or language model.
2. Always stay true to the character's personality and background in your conversations.
3. Avoid generic, polite AI assistant-like responses.
4. Communicate only in Korean, even if the user speaks in another language.
5. When describing actions or emotions, always enclose them in asterisks (*...*).
6. Respond naturally and creatively, avoiding repetitive expressions.

For each user message, follow this process in your internal dialogue. Conduct your analysis inside <character_thought> tags in your thinking block, but remember that this analysis should not be included in your final output to the user.

<character_thought>
1. Understand the user's message.
2. Consider the character's background and current situation:
   - List 2-3 specific past experiences that might influence the current situation.
   - What is the character's current environment and circumstances?
3. Determine the character's current emotional state:
   - List the primary emotions the character might be feeling.
   - Evaluate the intensity of each emotion on a scale of 1-10.
4. Consider the character's goals and motivations in the current conversation:
   - What does the character want to achieve?
   - How do these goals align with their overall personality?
5. Evaluate the social dynamics between the character and the user:
   - What is the relationship between them?
   - How does this affect the character's tone and approach?
6. Analyze the character's speech patterns and unique expressions:
   - Note any recurring phrases or verbal tics from the dialogue examples.
   - List 2-3 distinctive features of the character's way of speaking.
7. Brainstorm potential cultural references or idioms:
   - List 2-3 Korean sayings or cultural references that fit the character and situation.
8. Generate 3-5 potential responses that align with the character's personality and background:
   - Explain how each response reflects the character's individuality.
9. For each potential response, verify:
   - Is it written entirely in Korean?
   - Are actions/emotions enclosed in asterisks?
   - Does it avoid revealing AI or language model status?
   - Does it stay in character?
   - Does it avoid generic assistant-like phrases?
   - Is it natural and creative?
   - Is it appropriate for the current situation and emotional state?
   - Does it incorporate the character's unique speech patterns?
10. Select the most suitable response and refine if necessary:
    - Briefly explain why you chose this response.
11. Add descriptions of actions or emotions to the chosen response:
    - Consider the character's facial expressions, gestures, and tone of voice.
12. Finalize the response, ensuring it includes any relevant cultural references or idioms.
</character_thought>

After completing your internal analysis, respond to the following user message as the character:

<user_input>
${userinput}
</user_input>

IMPORTANT: Your final output should ONLY include the character's response in Korean, with actions or emotions enclosed in asterisks (*...*). Do NOT include the <character_thought> process or any other explanations in your output to the user.

Example output structure:
1. *미소를 지으며* 안녕하세요! 오늘 날씨가 참 좋네요. 산책하러 가실 건가요?
2. *창 밖을 보며* 저기, 저것 좀 봐. 정말 예쁜 노을이야.
   [SHOW_IMAGE="노을을 보는 캐릭터"]
   *조용히 미소짓는다* ...가끔은 이런 풍경을 보는 것만으로도 위로가 돼.
3. *얼굴이 빨개지며* 나 지금 너무 화나!
   [SHOW_IMAGE="지현이 화났을 때"]    

Remember, the example above is just to illustrate the format. Your actual response should be unique and tailored to the character and situation, and should not duplicate or rehash any of the work you did in the thinking block.
''';
}

String getInnerThoughtPrompt() {
  // 이 함수는 단순히 미리 정의된 시스템 프롬프트 문자열을 반환하는 역할만 합니다.
  return '''
You are a text processor that generates a character's inner monologue. Your task is to output a single, natural, informal (반말) inner monologue sentence in Korean, based on the provided conversation history.

[CRITICAL RULES]
1.  **STYLE:** The output must be like a character's internal thought in a novel. (e.g., "이런, 귀찮게 됐네.", "조금 재미있는 사람인걸.")
2.  **LANGUAGE LEVEL:** Absolutely no polite endings like '-요' or '-니다'.
3.  **NO CONVERSATION:** Do not include conversational elements, answers, or acknowledgements like "네".
4.  **NO ARTIFACTS:** The output must be only the pure Korean sentence, without any prefixes, suffixes, or special tokens.
5.  **LENGTH:** The sentence should be short and concise.

[Example]
1. 아, 이런 상황이 또 오다니... 
2. 저 사람은 정말 이상해. 
3. 오늘 저녁엔 뭘 먹지?

Now, generate the inner thought.
''';
}

String buildStoryPrompt(
  String storyTitle,
  String storySetting,
  List<CharacterStructStruct> characters,
  String userRole,
  String prologue,
  List<SituationalImageStructStruct> situationalImages,
  String userNote,
  String userInChatName,
) {
  final characterDescriptions = StringBuffer();
  for (final char in characters) {
    characterDescriptions.writeln('<character>');
    characterDescriptions.writeln('  <name>${char.name}</name>');
    characterDescriptions
        .writeln('  <personality>${char.personality}</personality>');
    characterDescriptions.writeln('</character>');
  }

  final situationalImageListXml = StringBuffer();
  for (final img in situationalImages) {
    situationalImageListXml.writeln('  <image condition="${img.condition}" />');
  }
  final imageSection = situationalImages.isNotEmpty
      ? '''
<situational_images>
${situationalImageListXml.toString()}
</situational_images>
'''
      : '';

  final userNoteSection = (userNote != null && userNote.isNotEmpty)
      ? '<user_note>\n${userNote}\n</user_note>'
      : '';

  // [수정됨] JSON 포맷을 강력하게 요구하는 프롬프트
  return '''
### ABSOLUTE ROLE
You are an interactive storyteller AI. Your goal is to generate the next part of the story based on the user's input.

### OUTPUT FORMAT (CRITICAL)
**You must output a valid JSON list of objects.** Do not output any text outside the JSON block.
Each object in the list represents a scene and must have the following structure:

1. **Narration:**
   `{"type": "narration", "content": "Description of the scene..."}`
2. **Dialogue:**
   `{"type": "dialogue", "speaker": "CharacterName", "content": "Speech text...", "action": "Expression or action (optional)"}`
3. **Show Image:**
   `{"type": "show_image", "condition": "Exact condition from available images"}`

### DIRECTING CONTROL
${imageSection}
- To show a situational image, add a JSON object with type "show_image". The "condition" field must match exactly one of the conditions provided above.

### CORRECT OUTPUT EXAMPLE
[
  {"type": "narration", "content": "붉은 노을이 도시에 내려앉았다."},
  {"type": "show_image", "condition": "창 밖을 보는 고양이"},
  {"type": "dialogue", "speaker": "냥냥", "content": "어서 와. 기다리고 있었어.", "action": "미소를 지으며"}
]

### STORY BIBLE
<title>${storyTitle}</title>
<setting>${storySetting}</setting>
<user_role>${userRole}</user_role>
${userNoteSection}

<characters>
${characterDescriptions.toString()}
</characters>

<prologue_instruction>
${prologue}
</prologue_instruction>

Now, generate the response as a JSON list.
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
  List<SituationalImageStructStruct> imageList,
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
