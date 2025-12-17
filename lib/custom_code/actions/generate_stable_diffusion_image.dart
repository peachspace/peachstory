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

Future<String?> generateStableDiffusionImage(
  String prompt,
  int imageWidth, // [추가됨] 가로 크기
  int imageHeight, // [추가됨] 세로 크기
  int? seed, // [추가] 시드값 받기 (Nullable)
) async {
  // Stability AI API Key
  const String apiKey =
      'sk-Ua3OUI4YD0QZGr1t8upUwWU0jjx7PgYLSlXyQrzX5wf7aPMt'; // 본인의 키 사용
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
          {
            "text":
                "$prompt, masterpiece, best quality, japanese anime style, 2d, flat color, cel shading, vibrant colors, character design",
            "weight": 1
          },
          {
            "text":
                "photorealistic, 3d, realistic, nose, lips, ugly, bad anatomy, bad hands, text, watermark, signature",
            "weight": -1
          }
        ],
        "cfg_scale": 7,
        // [수정됨] 입력받은 크기를 API에 전달
        "height": imageHeight,
        "width": imageWidth,
        "samples": 1,
        "steps": 30,
        if (seed != null && seed != 0) "seed": seed,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String base64Image = data['artifacts'][0]['base64'];
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
