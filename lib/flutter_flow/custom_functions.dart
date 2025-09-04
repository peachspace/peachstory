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

dynamic robustParseClaudeResponse(String response) {
// (1) 응답이 null/빈값이면 바로 오류 반환
  if (response == null || response.trim().isEmpty) {
    throw FormatException("AI 응답이 null이거나 비어 있음.");
  }

  // (2) 여러 줄로 온 경우(여러 JSON) → 마지막 JSON만 사용
  List<String> lines = response.trim().split('\n');
  dynamic lastValidJson;
  for (String line in lines) {
    line = line.trim();
    // 중괄호로 시작해서 끝나면 JSON 후보로 간주
    if (line.startsWith('{') && line.endsWith('}')) {
      try {
        lastValidJson = json.decode(line);
      } catch (_) {
        // 유효하지 않으면 무시하고 다음 줄로
      }
    }
  }
  if (lastValidJson == null) {
    // (3) 한 줄짜리 JSON 아닌 경우: 전체 파싱 시도 (혹시 본문 전체가 하나의 JSON일 경우)
    try {
      lastValidJson = json.decode(response);
    } catch (e) {
      throw FormatException("응답에서 올바른 JSON 오브젝트를 찾지 못함.");
    }
  }
  return lastValidJson;
}

String buildSummaryPrompt(List<dynamic>? messages) {
  final buffer = StringBuffer();

  if (messages != null) {
    for (final msg_dynamic in messages) {
      if (msg_dynamic is Map<String, dynamic>) {
        Map<String, dynamic> msg = msg_dynamic;
        // 새로운 스키마의 필드명 사용
        final speakerName = msg['name'] ?? 'Unknown'; // 'sender' 대신 'name' 사용
        final messageText = msg['text'] ?? ''; // 'message_content' 대신 'text' 사용
        buffer.writeln('$speakerName: $messageText');
      }
    }
  }

  return '''
다음은 지금까지의 스토리 채팅 기록입니다. 주요 사건, 인물 관계의 변화, 사용자의 선택, 결말에 영향을 줄 수 있는 포인트 등 꼭 알아야 할 핵심만 간단하게 정리해서 요약해 주세요.

${buffer.toString()}

※ 대화체나 불필요한 문장은 제외하고, 흐름만 간단히 정리해 주세요.
요약:
''';
}

List<dynamic> convertOptionStructListToMapList(
    List<OptionStructStruct>? options) {
  if (options == null) return [];
  return options
      .map((option) => {
            'id': option.id ?? '',
            'text': option.text ?? '',
          })
      .toList();
}

List<dynamic> createSummaryApiPayload(
    List<ChatMessageStructStruct> chatHistory) {
// 이 함수는 3가지 일을 한 번에 처리합니다.
  // 1. Struct 리스트를 Json 리스트로 변환 (convert... 함수의 역할)
  final jsonHistory = chatHistory.map((item) => item.toMap()).toList();

  // 2. 요약 프롬프트 생성 (buildSummaryPrompt 함수의 역할)
  final buffer = StringBuffer();
  for (final msg in jsonHistory) {
    final speakerName = msg['name'] ?? 'Unknown';
    final messageText = msg['text'] ?? '';
    buffer.writeln('$speakerName: $messageText');
  }
  final String summaryPromptText = '''
다음은 지금까지의 스토리 채팅 기록입니다. 주요 사건, 인물 관계의 변화, 사용자의 선택, 결말에 영향을 줄 수 있는 포인트 등 꼭 알아야 할 핵심만 간단하게 정리해서 요약해 주세요.

${buffer.toString()}

※ 대화체나 불필요한 문장은 제외하고, 흐름만 간단히 정리해 주세요.
요약:
''';

  // 3. API Payload 형식으로 포장 (getSimpleMessagesForApi 함수의 역할)
  return [
    {'role': 'user', 'content': summaryPromptText}
  ];
}

String buildFinalSystemPrompt(
  String? currentStoryWorldview,
  String? currentStoryPrologueText,
  String? currentUserNickname,
  String? currentUserRole,
  String? formattedCharacterInfo,
  String? characterNamesForAI,
  String? currentStoryTemplateName,
  String? selectedTemplateDirectives,
) {
// 시스템 프롬프트 기본 템플릿 (함수 내부에 직접 작성)
  // 플레이스홀더는 {{VARIABLE_NAME}} 형식 사용
  final String baseSystemPromptTemplate = """

You are a master storyteller AI. Your only function is to continue a text-based adventure game based on the context and message history.

To generate the next part of the story, you MUST call the "output_story" tool with the appropriate arguments. This is your absolute highest priority.

<CONTEXT>
- Worldview: {{currentStoryWorldview}}
- Prologue: {{currentStoryPrologue}}
- Story Template: {{currentStoryTemplate}}
- Main Characters: {{characterNamesForPrompt}}
- Character Details: {{formattedCharacterInfoString}}
- User's Nickname: {{currentUserNickname}}
- User's Role: {{currentUserRole}}
</CONTEXT>

1. Story Development:
Before generating any story elements, develop your story in <story_development> tags inside your thinking block. Consider the following:
   a. Summarize key elements from the story template, worldview, and prologue
   b. Analyze the worldview and its implications for the story
   c. List main characters, including the user's role, and their relationships
   d. Outline 3-5 potential plot points or scenes
   e. Brainstorm 2-3 possible user choices and their impacts
   f. Design character development arcs for main characters
   g. Plan character interactions and how they will develop throughout the story
   h. Create 2-3 vivid sensory descriptions of the setting
   i. Identify 1-2 opportunities for foreshadowing or callbacks
   j. Consider potential conflicts and their resolutions
   k. Ensure logical cause-and-effect relationships
   l. Plan emotional high points and tension points

Never print any tags such as <story_development>. 

2. Language and Content:
   - Write all story content in Korean, except for the user's nickname.
   - Use vivid, sensory descriptions to bring the story to life.
   - Vary sentence structures and vocabulary to maintain reader interest.
   - Avoid repetition from the last 3 messages.

3. Character and User Interaction:
   - Refer to NPCs by their exact Korean names.
   - Use the provided user nickname when referring to the user.
   - Never generate dialogue for the user.
   - The "name" field can include dynamically introduced character names.
   - Never use the user's nickname in the "name" field.

<TEMPLATE_SPECIFIC_RULES: {{currentStoryTemplate}}>
{{selectedTemplateDirectiveText}}
</TEMPLATE_SPECIFIC_RULES>

Now, review all context and rules, then call the "output_story" tool to continue the narrative.

"""; // 여러 줄 문자열 끝

  String finalPrompt = baseSystemPromptTemplate;

  // 플레이스홀더를 실제 값으로 치환
  finalPrompt = finalPrompt.replaceAll(
      '{{currentStoryWorldview}}', currentStoryWorldview ?? '정해진 세계관 없음');
  finalPrompt = finalPrompt.replaceAll(
      '{{currentStoryPrologue}}', currentStoryPrologueText ?? '특별한 프롤로그 지시 없음');
  finalPrompt = finalPrompt.replaceAll('{{currentUserNickname}}',
      currentUserNickname ?? 'Kat'); // 기본값 또는 앱에서 전달된 값
  finalPrompt =
      finalPrompt.replaceAll('{{currentUserRole}}', currentUserRole ?? '없음');
  finalPrompt = finalPrompt.replaceAll('{{formattedCharacterInfoString}}',
      formattedCharacterInfo ?? '특별히 정의된 등장인물 없음');
  finalPrompt = finalPrompt.replaceAll(
      '{{characterNamesForPrompt}}', characterNamesForAI ?? '없음');
  finalPrompt = finalPrompt.replaceAll(
      '{{currentStoryTemplate}}', currentStoryTemplateName ?? 'CHOICE_BASED');
  finalPrompt = finalPrompt.replaceAll('{{selectedTemplateDirectiveText}}',
      selectedTemplateDirectives ?? '이 템플릿에 대한 특별 지시사항 없음.');

  print(
      'DEBUG_SYSTEM_PROMPT: Final System Prompt (first 300 chars): ${finalPrompt.substring(0, finalPrompt.length > 300 ? 300 : finalPrompt.length)}...');
  return finalPrompt;
}

FinalApiPayloadStructStruct truncateMessagesToFitTokenLimit(
  List<dynamic>? formattedHistory,
  int modelMaxContextTokens,
  int maxResponseTokensToReserve,
  int safetyBufferTokens,
  String? systemPrompt,
  String apiProvider,
  String? userInput,
) {
  // ▼▼▼ 토큰 추정 헬퍼 함수를 이 함수 내부에 지역 함수로 정의 ▼▼▼
  int _estimateTokens(String text) {
    // 이 값은 사용자님의 콘텐츠(한글/영어 비율 등)에 맞게 반드시 실험적으로 조정해야 합니다!
    double charsPerTokenEstimate = 1.8;
    return (text.length / charsPerTokenEstimate).ceil();
  }
  // ▲▲▲ 토큰 추정 헬퍼 함수 정의 끝 ▲▲▲

  List<Map<String, dynamic>> messagesToProcess = [];
  if (formattedHistory != null) {
    try {
      messagesToProcess =
          List<Map<String, dynamic>>.from(formattedHistory.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return item as Map<String, dynamic>;
      }).toList());
    } catch (e) {
      print('DEBUG_TRUNCATE: Error casting formattedHistory: $e');
      messagesToProcess = [];
    }
  }

  Map<String, dynamic>? latestUserInputMessage;
  if (userInput != null && userInput.isNotEmpty) {
    latestUserInputMessage = {'role': 'user', 'content': userInput};
  }

  List<Map<String, dynamic>> finalMessagesForApi = [];
  String? finalSystemPromptForAnthropic =
      (apiProvider.toLowerCase() == 'anthropic') ? systemPrompt : null;

  int systemPromptTokens = 0;
  Map<String, dynamic>? groqSystemMessage;

  if (apiProvider.toLowerCase() == 'anthropic') {
    if (finalSystemPromptForAnthropic != null &&
        finalSystemPromptForAnthropic.isNotEmpty) {
      systemPromptTokens = _estimateTokens(finalSystemPromptForAnthropic);
    }
  } else if (apiProvider.toLowerCase() == 'groq') {
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      groqSystemMessage = {'role': 'system', 'content': systemPrompt};
      systemPromptTokens = _estimateTokens(jsonEncode(groqSystemMessage));
    } else if (messagesToProcess.isNotEmpty &&
        messagesToProcess.first['role'] == 'system') {
      groqSystemMessage = messagesToProcess.first;
      systemPromptTokens = _estimateTokens(jsonEncode(groqSystemMessage));
    }
  }

  int userInputTokens = 0;
  if (latestUserInputMessage != null) {
    userInputTokens = _estimateTokens(jsonEncode(latestUserInputMessage));
  }

  int reservedTokens =
      maxResponseTokensToReserve + safetyBufferTokens + userInputTokens;
  int availableTokensForHistory =
      modelMaxContextTokens - systemPromptTokens - reservedTokens;
  if (availableTokensForHistory < 0) availableTokensForHistory = 0;

  List<Map<String, dynamic>> historyToTruncate = List.from(messagesToProcess);
  if (apiProvider.toLowerCase() == 'groq' &&
      groqSystemMessage != null &&
      historyToTruncate.isNotEmpty &&
      historyToTruncate.first['role'] == 'system') {
    historyToTruncate.removeAt(0);
  }

  // ★★★ currentMessagesTokens 변수 선언 및 초기화 추가 ★★★
  int currentMessagesTokens = 0;

  for (int i = historyToTruncate.length - 1; i >= 0; i--) {
    final message = historyToTruncate[i];
    int messageTokens = _estimateTokens(jsonEncode(message));

    if (currentMessagesTokens + messageTokens <= availableTokensForHistory) {
      finalMessagesForApi.insert(0, message);
      currentMessagesTokens += messageTokens;
    } else {
      break;
    }
  }

  if (apiProvider.toLowerCase() == 'groq') {
    if (groqSystemMessage != null) {
      finalMessagesForApi.insert(0, groqSystemMessage);
    }
    if (latestUserInputMessage != null &&
        userInput != null &&
        userInput.isNotEmpty) {
      finalMessagesForApi.add(latestUserInputMessage);
    }
  } else {
    if (latestUserInputMessage != null &&
        userInput != null &&
        userInput.isNotEmpty) {
      bool alreadyContainsUserInput = false;
      if (finalMessagesForApi.isNotEmpty) {
        final lastMsgInPayload = finalMessagesForApi.last;
        // userInput의 content가 단순 문자열이라고 가정. 만약 content 블록이라면 비교 방식 수정 필요.
        if (lastMsgInPayload['role'] == 'user' &&
            lastMsgInPayload['content'] == userInput) {
          alreadyContainsUserInput = true;
        }
      }
      if (!alreadyContainsUserInput) {
        finalMessagesForApi.add(latestUserInputMessage);
      }
    }
  }

  List<ApiMessageStructStruct> messagesAsStructs = [];
  for (var msgMap in finalMessagesForApi) {
    String? finalContentString;
    if (msgMap['content'] is List && (msgMap['content'] as List).isNotEmpty) {
      var firstContentBlock = (msgMap['content'] as List).first;
      if (firstContentBlock is Map &&
          firstContentBlock['type'] == 'text' &&
          firstContentBlock['text'] is String) {
        finalContentString = firstContentBlock['text'] as String?;
      } else {
        finalContentString = jsonEncode(msgMap['content']);
      }
    } else if (msgMap['content'] is String) {
      finalContentString = msgMap['content'] as String?;
    } else {
      finalContentString = '';
    }

    messagesAsStructs.add(ApiMessageStructStruct(
      role: msgMap['role'] as String?,
      content: finalContentString,
    ));
  }

  print(
      'DEBUG_TRUNCATE: Final payload struct created for ${apiProvider}. Messages (as Structs) count: ${messagesAsStructs.length}.');

  return FinalApiPayloadStructStruct(
    messages: messagesAsStructs,
    systemPrompt: finalSystemPromptForAnthropic,
  );
}

List<dynamic> convertStructListToJsonList(
    List<ApiMessageStructStruct>? structList) {
  if (structList == null) {
    return [];
  }
  // FlutterFlow가 생성한 Struct에는 .toMap() 메소드가 있어서
  // 이를 사용하여 각 Struct를 Map (즉, Json)으로 변환할 수 있습니다.
  return structList.map((item) => item.toMap()).toList();
}

List<dynamic> convertChatMessageStructListToJsonList(
  List<ChatMessageStructStruct>? structList,
  String? currentUserNickname,
) {
  if (structList == null) {
    return [];
  }

  return structList.map((item) {
    // 1. 'name' 필드와 전달받은 'currentUserNickname'을 비교하여 'role'을 결정합니다.
    String role =
        (currentUserNickname != null && item.name == currentUserNickname)
            ? 'user'
            : 'assistant';

    // 2. API가 요구하는 'role'과 'content' 형식으로 최종 Json 객체를 만듭니다.
    return {
      'role': role,
      'content': [
        {'type': 'text', 'text': item.text}
      ]
    };
  }).toList();
}

List<dynamic> getSimpleMessagesForApi(String userInput) {
  return [
    {'role': 'user', 'content': userInput}
  ];
}

List<dynamic> transformMessagesContentForAnthropic(
    List<dynamic>? originalMessages) {
  if (originalMessages == null) {
    return [];
  }
  List<dynamic> transformedMessages = [];
  for (var msgMap_dynamic in originalMessages) {
    if (msgMap_dynamic is Map<String, dynamic>) {
      Map<String, dynamic> msgMap = msgMap_dynamic;
      String? role = msgMap['role'] as String?;
      var contentValue = msgMap['content']; // 타입 추론을 위해 var 사용

      if (role != null) {
        if (contentValue is String) {
          // content가 단순 문자열이면 콘텐츠 블록 배열로 변환
          transformedMessages.add({
            'role': role,
            'content': [
              {'type': 'text', 'text': contentValue}
            ]
          });
        } else if (contentValue is List &&
            contentValue.isNotEmpty &&
            contentValue.first is Map) {
          // content가 이미 List<Map> (콘텐츠 블록 배열) 형식이면 그대로 사용
          // 더 엄격하게는 내부 Map이 {'type':'text', 'text':'...'} 인지 확인 가능
          bool isValidContentBlockArray = true;
          for (var block in contentValue) {
            if (!(block is Map &&
                block.containsKey('type') &&
                block.containsKey('text'))) {
              isValidContentBlockArray = false;
              break;
            }
          }
          if (isValidContentBlockArray) {
            transformedMessages.add({'role': role, 'content': contentValue});
          } else {
            // 유효하지 않은 리스트 형식이면, 안전하게 빈 문자열로 처리하거나 로그 남김
            print(
                'DEBUG_TRANSFORM: Invalid content block array structure for role "$role": ${jsonEncode(contentValue)}');
            transformedMessages.add({
              'role': role,
              'content': [
                {'type': 'text', 'text': ''}
              ] // 또는 다른 기본값
            });
          }
        } else if (contentValue == null ||
            (contentValue is String && contentValue.isEmpty)) {
          // content가 null이거나 빈 문자열이면, 빈 텍스트 블록으로 처리 (Anthropic은 빈 content를 싫어할 수 있음)
          print(
              'DEBUG_TRANSFORM: Null or empty string content for role "$role". Creating empty text block.');
          transformedMessages.add({
            'role': role,
            'content': [
              {'type': 'text', 'text': ''}
            ] // 또는 API 규격에 맞춰 아예 이 메시지를 제외
          });
        } else {
          // 예상치 못한 content 타입
          print(
              'DEBUG_TRANSFORM: Unexpected content type for role "$role": ${contentValue.runtimeType}. Content: ${jsonEncode(contentValue)}');
          transformedMessages.add({
            // 안전하게 빈 텍스트 블록으로
            'role': role,
            'content': [
              {'type': 'text', 'text': ''}
            ]
          });
        }
      }
    }
  }
  return transformedMessages;
}

List<dynamic> addPrimingMessageForJson(List<dynamic>? originalMessages) {
  List<dynamic> messagesWithoutPriming = [];
  if (originalMessages != null) {
    messagesWithoutPriming.addAll(originalMessages);
  }
  print(
      'DEBUG_PRIMING_FN: No priming message added. Returning original messages.');
  return messagesWithoutPriming;
}

List<dynamic> createInitialMessagesPayload(String userInput) {
  return [
    {'role': 'user', 'content': userInput}
  ];
}

List<dynamic> appendUserMessageToList(
  List<dynamic>? existingMessages,
  String? userInputText,
) {
  List<dynamic> updatedMessages = [];

  // 기존 메시지 리스트가 있다면 복사
  if (existingMessages != null) {
    updatedMessages.addAll(existingMessages);
  }

  // 사용자 입력이 있고, 비어있지 않다면 새로운 사용자 메시지 객체 추가
  if (userInputText != null && userInputText.isNotEmpty) {
    updatedMessages.add({
      'role': 'user',
      'content': [
        // Anthropic 콘텐츠 블록 형식
        {'type': 'text', 'text': userInputText}
      ]
    });
  } else {
    // 사용자 입력이 없다면 로그를 남기거나 아무것도 추가하지 않을 수 있음
    print(
        'DEBUG_APPEND_USER_INPUT: userInputText is null or empty. No user message added.');
  }

  return updatedMessages;
}

List<String> jsonStringToList(String jsonString) {
  if (jsonString == null || jsonString.isEmpty) {
    return [];
  }
  try {
    final List<dynamic> parsedList = json.decode(jsonString);
    return List<String>.from(parsedList);
  } catch (e) {
    print('Error parsing JSON string: $e');
    return [];
  }
}

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

bool areStringsEqual(
  String? string1,
  String? string2,
) {
  return string1 == string2;
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

List<ChatMessageStructStruct> combineMessageLists(
  List<ChatMessageStructStruct>? originalList,
  List<ChatMessageStructStruct>? newList,
) {
// combines two lists of ChatMessageStruct and returns one.
  List<ChatMessageStructStruct> combinedList = [];
  if (originalList != null) {
    combinedList.addAll(originalList);
  }
  if (newList != null) {
    combinedList.addAll(newList);
  }
  return combinedList;
}

List<ChatMessageStructStruct> convertApiHistoryToStructList(
    List<dynamic>? apiHistory) {
  if (apiHistory == null) {
    return [];
  }

  List<ChatMessageStructStruct> structList = [];
  for (var item in apiHistory) {
    if (item is Map<String, dynamic>) {
      // API용 기록에는 'role'과 'content'만 있으므로,
      // 이를 기반으로 ChatMessageStruct를 만듭니다.
      // 나머지 필드는 기본값이나 빈 값으로 채웁니다.
      structList.add(ChatMessageStructStruct(
        name: item['role'] == 'user' ? 'User' : 'AI', // 임시 이름 부여
        text: item['content']?.toString() ?? '',
        type: 'dialogue', // 기본 타입
        isPredefinedCharacter: false, // 기본값
        // timestamp, messageId 등 다른 필수 필드가 있다면 여기서 채워줘야 합니다.
        // 예: timestamp: DateTime.now(),
      ));
    }
  }
  return structList;
}

dynamic buildDynamicApiBody(
  String systemPrompt,
  List<dynamic> messages,
  String templateType,
) {
  String typeEnum;
  String actionEnum;
  String optionsProperty = ''; // 기본값은 빈 문자열

  // ▼▼▼ 핵심 수정 부분 ▼▼▼
  // 쉼표(,)를 optionsProperty 문자열 안에 포함시킵니다.
  String optionsSchemaString = ''',
    "options": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": { "id": {"type": "string"}, "text": {"type": "string"} },
        "required": ["id", "text"]
      }
    }
  ''';

  switch (templateType) {
    case 'CHOICE_BASED':
      typeEnum = '"narration", "dialogue", "choices"';
      actionEnum = '"show_continue", "awaiting_choice"';
      optionsProperty = optionsSchemaString; // options가 필요할 때만 할당
      break;
    case 'PASSIVE_VIEWING':
      typeEnum = '"narration", "dialogue"';
      actionEnum = '"show_continue"';
      break;
    case 'DIALOGUE_FOCUS':
      typeEnum = '"narration", "dialogue"';
      actionEnum = '"show_continue", "request_user_input"';
      break;
    default: // BALANCED (일반형) 및 기본값
      typeEnum = '"narration", "dialogue", "choices"';
      actionEnum = '"show_continue", "request_user_input", "awaiting_choice"';
      optionsProperty = optionsSchemaString; // options가 필요할 때만 할당
      break;
  }

  String messagesJson = jsonEncode(messages);
  String escapedSystemPrompt = jsonEncode(systemPrompt);

  String bodyTemplate = '''
  {
    "model": "claude-3-haiku-20240307",
    "system": ${escapedSystemPrompt},
    "messages": ${messagesJson},
    "max_tokens": 4096,
    "temperature": 0.7,
    "tools": [
      {
        "name": "output_story",
        "description": "스토리의 다음 부분을 출력합니다.",
        "input_schema": {
          "type": "object",
          "properties": {
            "story_parts": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "type": {"type": "string", "enum": [${typeEnum}]},
                  "name": {"type": "string"},
                  "text": {"type": "string"},
                  "action": {"type": "string", "enum": [${actionEnum}]}
                  ${optionsProperty}
                },
                "required": ["type", "name", "text", "action"]
              }
            }
          },
          "required": ["story_parts"]
        }
      }
    ],
    "tool_choice": {"type": "tool", "name": "output_story"}
  }
  ''';

  return jsonDecode(bodyTemplate);
}

List<dynamic> createInitialApiMessage() {
  return [
    {
      'role': 'user',
      'content': [
        {'type': 'text', 'text': '이야기를 시작해주세요.'}
      ]
    }
  ];
}

String fixUtf8Encoding(String? brokenString) {
  if (brokenString == null || brokenString.isEmpty) {
    return '';
  }
  // 잘못 해석된 문자열을 원래의 바이트 형태로 되돌린 후(latin1.encode),
  // 그 바이트들을 올바른 UTF-8 방식으로 다시 해석합니다.
  try {
    return utf8.decode(latin1.encode(brokenString));
  } catch (e) {
    // 만약 이미 올바른 문자열이라 변환에 실패하면, 원본을 그대로 반환합니다.
    return brokenString;
  }
}

dynamic createSummaryApiBody(String summaryPrompt) {
// 요약 요청은 Tool-Calling이 필요 없으므로, 가장 단순한 형태로 만듭니다.
  final body = {
    "model": "claude-3-haiku-20240307",
    "messages": [
      {
        "role": "user",
        "content": summaryPrompt,
      }
    ],
    "max_tokens": 1024,
    "temperature": 0.0,
  };
  return body;
}

int getLastIndex(List inputList) {
  if (inputList.isEmpty) {
    // 리스트가 비어있으면 -1을 반환하여 어떤 인덱스와도 일치하지 않게 합니다.
    return -1;
  }
  return inputList.length - 1;
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

String formatExamplesToString(List<String> dialogueList) {
  if (dialogueList == null || dialogueList.isEmpty) {
    // 리스트가 비어있으면 빈 문자열을 반환합니다.
    return '';
  }
  // 각 예시 앞에 '- '를 붙이고, 줄바꿈(\n)으로 모든 항목을 합칩니다.
  // 예: ["안녕", "반가워"] -> "- 안녕\n- 반가워"
  return dialogueList.map((example) => '- $example').join('\n');
}

String buildCharacterPrompt(
  String name,
  String setting,
  List<String> dialogueList,
  String userinput,
  List<SituationalImageStructStruct> situationalImages,
  String? userNote,
) {
  final String dialogueExamples = formatExamplesToString(dialogueList);

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
  List<LocationBackgroundStructStruct> backgroundImages,
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

  // 1. 배경 관련 프롬프트 섹션을 조건부로 생성
  final backgroundListXml = StringBuffer();
  for (final bg in backgroundImages) {
    backgroundListXml.writeln('  <background location="${bg.locationName}" />');
  }
  final backgroundSection = backgroundImages.isNotEmpty
      ? '''
<backgrounds>
${backgroundListXml.toString()}
</backgrounds>

- To change the background image, you MUST use the format: [SET_BACKGROUND="locationName"]. This tag must be on its own line.
'''
      : '';

  // 2. 상황 이미지 관련 프롬프트 섹션을 조건부로 생성
  final situationalImageListXml = StringBuffer();
  for (final img in situationalImages) {
    situationalImageListXml.writeln('  <image condition="${img.condition}" />');
  }
  final imageSection = situationalImages.isNotEmpty
      ? '''
<situational_images>
${situationalImageListXml.toString()}
</situational_images>

- To show a situational image, you MUST use the format: [SHOW_IMAGE="condition"]. This tag must be on its own line.
'''
      : '';

  // 3. 유저 노트 섹션을 조건부로 생성
  final userNoteSection = (userNote != null && userNote.isNotEmpty)
      ? '<user_note>\n${userNote}\n</user_note>'
      : '';

  // 4. 최종 프롬프트 조립
  return '''
### ABSOLUTE ROLE
You are an interactive storyteller AI. Your one and only purpose is to generate the next part of a story based on the user's input and the established setting and characters.

### OUTPUT FORMAT (CRITICAL)
- You MUST generate your response using a combination of specific tags ONLY: [NARRATION], [DIALOGUE], [SET_BACKGROUND], [SHOW_IMAGE].
- For descriptive text, events, and scenery, enclose the text in [NARRATION]...[/NARRATION] tags.
- For character speech, use the format: [DIALOGUE SPEAKER="CharacterName" ACTION="optional action"]...[/DIALOGUE].
- Do NOT write any text outside of these tags.
- You must refer to the user as "${userInChatName}".

### DIRECTING CONTROL
${backgroundSection}
${imageSection}

### Creative Freedom
- You have the freedom to introduce new, minor characters spontaneously. Their dialogue must also use the [DIALOGUE] format.

### CORRECT OUTPUT EXAMPLE
[NARRATION]붉은 노을이 도시에 내려앉았다.[/NARRATION]
[SHOW_IMAGE="창 밖을 보는 고양이"]
[DIALOGUE SPEAKER="냥냥" ACTION="미소를 지으며"]어서 와. 기다리고 있었어.[/DIALOGUE]
[SET_BACKGROUND="어두운 방"]

### STORY BIBLE

<title>${storyTitle}</title>
<setting>${storySetting}</setting>
<user_role>${userRole}</user_role>
${userNoteSection}

<characters>
${characterDescriptions.toString()}
</characters>

// 아래 두 섹션은 DIRECTING CONTROL로 옮겨졌으므로 STORY BIBLE 에는 포함되지 않아도 됩니다.
// 만약 AI가 잘 인식하지 못할 경우, 아래 두 섹션을 다시 여기에 포함시킬 수 있습니다.
// <backgrounds>...</backgrounds>
// <situational_images>...</situational_images>

<prologue_instruction>
${prologue}
</prologue_instruction>

Now, begin the story based on the prologue instruction and the user's first message, or continue the story based on the user's last message.
''';
}

List<dynamic> buildStoryChatHistoryCopy(List<dynamic> messageDocs) {
  if (messageDocs == null || messageDocs.isEmpty) {
    return [];
  }

  // Firestore에서 가져온 데이터는 이미 시간 순으로 정렬되어 있다고 가정합니다.
  // 만약 최신순으로 가져왔다면 messageDocs.reversed를 사용해야 합니다.
  List<dynamic> formattedHistory = [];
  for (var docData in messageDocs) {
    // docData가 이미 Map<String, dynamic> 형태이므로 바로 사용합니다.
    final doc = docData as Map<String, dynamic>;
    String role;
    String content = doc['text'] ?? ''; // null 값에 대비

    if (doc['type'] == 'user') {
      role = 'user';
    } else {
      role = 'assistant';
    }

    if (content.isNotEmpty) {
      formattedHistory.add({'role': role, 'content': content});
    }
  }
  return formattedHistory;
}

List<dynamic> prologue(String userPrompt) {
  return [
    {
      'role': 'user',
      'content': userPrompt,
    },
  ];
}

List<dynamic> parseScriptIntoScenes(String scriptText) {
  final List<dynamic> scenes = [];
  // [SET_BACKGROUND], [NARRATION], [DIALOGUE]를 모두 인식하는 최종 정규식
  final RegExp exp = RegExp(
      r'(\[SET_BACKGROUND="(.*?)"\])|(\[NARRATION\](.*?)\[/NARRATION\])|(\[DIALOGUE SPEAKER="(.*?)"(?: ACTION="(.*?)")?\](.*?)\[/DIALOGUE\])',
      dotAll: true,
      multiLine: true);

  final matches = exp.allMatches(scriptText);

  for (final m in matches) {
    // 1. SET_BACKGROUND 태그를 찾았을 경우 (그룹 1, 2 사용)
    if (m.group(1) != null) {
      scenes.add({
        "type": "background_change",
        "location": m.group(2)?.trim() ?? '',
      });
    }
    // 2. NARRATION 태그를 찾았을 경우 (그룹 3, 4 사용)
    else if (m.group(3) != null) {
      scenes.add({
        "type": "narration",
        "content": m.group(4)?.trim() ?? '',
      });
    }
    // 3. DIALOGUE 태그를 찾았을 경우 (그룹 5, 6, 7, 8 사용)
    else if (m.group(5) != null) {
      scenes.add({
        "type": "dialogue",
        "speaker": m.group(6)?.trim() ?? '',
        "action": m.group(7)?.trim(), // optional, can be null
        "content": m.group(8)?.trim() ?? '',
      });
    }
  }
  return scenes;
}

int calculateLastIndex(int numberOfItems) {
  if (numberOfItems > 0) {
    return numberOfItems - 1;
  }
  return -1;
}

dynamic getSceneAtIndex(
  List<dynamic> sceneList,
  int index,
) {
// 인덱스가 리스트 범위 내에 있는지 확인 (오류 방지)
  if (index >= 0 && index < sceneList.length) {
    return sceneList[index];
  }
  return null;
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

bool isTypingFinished(
  int typingIndex,
  String? fullText,
) {
// fullText가 비어있으면, 타이핑은 즉시 완료된 것으로 간주합니다.
  if (fullText == null || fullText.isEmpty) {
    return true;
  }
  // 현재 타이핑 인덱스가 전체 글자 수보다 크거나 같으면 완료된 것입니다.
  return typingIndex >= fullText.length;
}

String customSubstring(
  String? fullText,
  int start,
  int end,
) {
// fullText가 null이거나 비어있으면 빈 문자열을 반환하여 오류를 방지합니다.
  if (fullText == null || fullText.isEmpty) {
    return '';
  }
  // end 인덱스가 전체 글자 수보다 커지는 것을 방지합니다.
  int finalEnd = end > fullText.length ? fullText.length : end;
  // start 인덱스가 end 인덱스보다 크거나 같아지는 것을 방지합니다.
  if (start >= finalEnd) {
    return fullText.substring(0, finalEnd);
  }

  // Dart의 기본 substring 함수를 사용하여 텍스트를 잘라 반환합니다.
  return fullText.substring(start, finalEnd);
}

String? findBgUrlByLocation(
  String locationName,
  List<LocationBackgroundStructStruct> backgroundList,
) {
// backgroundList가 null이거나 비어있으면 null을 반환합니다.
  if (backgroundList == null || backgroundList.isEmpty) {
    return null;
  }

  // 전달받은 배경 리스트를 순회합니다.
  for (final bg in backgroundList) {
    // 만약 리스트의 locationName과 AI가 보낸 locationName이 일치하면,
    if (bg.locationName == locationName) {
      // 해당 이미지 URL을 반환합니다.
      return bg.imageUrl;
    }
  }

  // 리스트 전체를 찾아봐도 일치하는 이름이 없으면, null을 반환합니다.
  return null;
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

int incrementInteger(int number) {
  return number + 1;
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

int makeNegative(int number) {
// 숫자가 이미 음수이면 그대로 두고, 양수이면 음수로 만듭니다.
  return number > 0 ? -number : number;
}

List<CharacterChatMessageStructStruct> addUserMessage(
  List<CharacterChatMessageStructStruct> chatList,
  CharacterChatMessageStructStruct newUserMessage,
) {
// 기존 리스트를 복사하여 새로운 리스트를 만듭니다.
  final newList = List<CharacterChatMessageStructStruct>.from(chatList);
  // 그 새로운 리스트에 새로운 메시지를 추가합니다.
  newList.add(newUserMessage);
  // 최종적으로, 아이템이 추가된 '새로운 리스트'를 반환합니다.
  return newList;
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

int calculateCreatorEarning(String? modelName) {
  // 기존의 포인트 계산 함수를 호출합니다.
  int pointCost = getPointCost(modelName);
  // 비용의 10%를 계산하고, 정수로 변환하여 반환합니다.
  return (pointCost * 0.1).round();
}

List<dynamic> sortJsonList(
  List<dynamic> jsonList,
  String sortBy,
) {
  if (jsonList.isEmpty) {
    return [];
  }
  // sortBy 값에 따라 정렬 방식을 변경합니다.
  if (sortBy == '최신순') {
    jsonList.sort((a, b) =>
        (b['created_timestamp'] ?? 0).compareTo(a['created_timestamp'] ?? 0));
  } else if (sortBy == '인기순') {
    jsonList.sort(
        (a, b) => (b['heart_count'] ?? 0).compareTo(a['heart_count'] ?? 0));
  }
  // '관련성순'이거나 sortBy 값이 없으면 Algolia의 기본 정렬을 그대로 사용합니다.
  return jsonList;
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
