import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'apiCallAiProxy';

class AnthropicCall {
  static Future<ApiCallResponse> call({dynamic? apiBodyJson}) async {
    final apiBody = _serializeJson(apiBodyJson);
    final ffApiRequestBody = '''
${apiBody}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Anthropic',
      apiUrl: 'https://api.anthropic.com/v1/messages',
      callType: ApiCallType.POST,
      headers: {
        'x-api-key': 'YOUR_API_KEY',
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AnthropicSummaryCall {
  static Future<ApiCallResponse> call({dynamic? summaryPromptJson}) async {
    final summaryPrompt = _serializeJson(summaryPromptJson, true);
    final ffApiRequestBody = '''
{
  "model": "claude-3-haiku-20240307",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "${summaryPrompt}"
    }
  ],
  "temperature": 0.0
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AnthropicSummary',
      apiUrl: 'https://api.anthropic.com/v1/messages',
      callType: ApiCallType.POST,
      headers: {
        'x-api-key': 'YOUR_API_KEY',
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? summaryResult(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.content[:].text'''));
}

class GroqCall {
  static Future<ApiCallResponse> call({dynamic? messagesPayloadJson}) async {
    final messagesPayload = _serializeJson(messagesPayloadJson, true);
    final ffApiRequestBody = '''
{
  "model": "gemma2-9b-it",
  "max_completion_tokens": 2048,
  "temperature": 0.5,
  "messages": ${messagesPayload},
  "response_format": {"type": "json_object"}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'groq',
      apiUrl: 'https://api.groq.com/openai/v1/chat/completions',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? aiGeneratedJsonString1(dynamic response) => castToType<String>(
    getJsonField(response, r'''$.choices[:].message.content'''),
  );
}

class GroqsummaryCall {
  static Future<ApiCallResponse> call({String? summaryPrompt = ''}) async {
    final ffApiRequestBody = '''
{
  "model": "meta-llama/llama-4-scout-17b-16e-instruct",
  "max_completion_tokens": 4096,
  "messages": [
    {
      "role": "user",
      "content": "${escapeStringForJson(summaryPrompt)}"
    }
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'groqsummary',
      apiUrl: 'https://api.groq.com/openai/v1/chat/completions',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? summaryResult(dynamic response) => castToType<String>(
    getJsonField(response, r'''$.choices[:].message.content'''),
  );
}

class AnthropicChoiceCall {
  static Future<ApiCallResponse> call({String? prompt = ''}) async {
    final ffApiRequestBody = '''
{
  "model": "claude-3-haiku-20240307",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "${escapeStringForJson(prompt)}"
    }
  ],
  "temperature": 0.5
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AnthropicChoice',
      apiUrl: 'https://api.anthropic.com/v1/messages',
      callType: ApiCallType.POST,
      headers: {
        'x-api-key': 'YOUR_API_KEY',
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? responseText(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.content[:].text'''));
}

class GetInnerThoughtCall {
  static Future<ApiCallResponse> call({
    dynamic? messagesJson,
    String? systemPrompt = '',
  }) async {
    final messages = _serializeJson(messagesJson, true);
    final ffApiRequestBody = '''
{
  "model": "claude-3-haiku-20240307",
  "system": "${escapeStringForJson(systemPrompt)}",
  "messages": ${messages},
  "max_tokens": 150,
  "stream": false
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getInnerThought',
      apiUrl: 'https://api.anthropic.com/v1/messages',
      callType: ApiCallType.POST,
      headers: {
        'x-api-key': 'YOUR_API_KEY',
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? thoughtText(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.content[0].text'''));
}

class ApiSearchAllCall {
  static Future<ApiCallResponse> call({
    String? query = '',
    String? sortOption = '',
  }) async {
    final ffApiRequestBody = '''
{
  "data": {
    "query": "${escapeStringForJson(query)}",
    "sortOption": "${escapeStringForJson(sortOption)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'apiSearchAll',
      apiUrl:
          'https://asia-northeast3-ssss-ehfczw.cloudfunctions.net/searchAll',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? results(dynamic response) =>
      getJsonField(response, r'''$.result.results''', true) as List?;
}

class ApiCallAiProxyCall {
  static Future<ApiCallResponse> call({
    String? modelName = 'claude-3-5-haiku-20241022',
    String? systemPrompt = '',
    dynamic? messagesJson,
  }) async {
    final messages = _serializeJson(messagesJson, true);
    final ffApiRequestBody = '''
{
  "data": {
    "modelName": "${escapeStringForJson(modelName)}",
    "systemPrompt": "${escapeStringForJson(systemPrompt)}",
    "messages": ${messages}
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'apiCallAiProxy',
      apiUrl:
          'https://asia-northeast3-ssss-ehfczw.cloudfunctions.net/aiProxyHandler',
      callType: ApiCallType.POST,
      headers: {'content-type': 'application/json'},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
