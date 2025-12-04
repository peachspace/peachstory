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

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> generateStableDiffusionImage(String prompt) async {
  // Stability AI API Key (Secret Manager 등에 저장하는 것이 좋습니다)
  const String apiKey = 'YOUR_STABILITY_AI_API_KEY';
  const String engineId = 'stable-diffusion-xl-1024-v1-0';
  final Uri apiUri = Uri.parse(
      'https://api.stability.ai/v1/generation/$engineId/text-to-image');

  try {
    final response = await http.post(
      apiUri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "text_prompts": [
          {"text": prompt, "weight": 1}
        ],
        "cfg_scale": 7,
        "height": 1024,
        "width": 1024,
        "samples": 1,
        "steps": 30,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 첫 번째 이미지의 Base64 데이터를 가져옵니다.
      String base64Image = data['artifacts'][0]['base64'];

      // Flutter의 Image 위젯에서 바로 쓸 수 있는 포맷으로 반환합니다.
      return "data:image/png;base64,$base64Image";
    } else {
      print('Image Gen Error: ${response.body}');
      return null;
    }
  } catch (e) {
    print('API Call Error: $e');
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
