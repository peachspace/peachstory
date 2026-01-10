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

import 'package:cloud_functions/cloud_functions.dart';

Future<dynamic> callGenerateImageCloud(
  String mode,
  String prompt,
  String? characterImageUrl,
  int? seed,
  String? basePrompt,
) async {
  try {
    print('📌 [Image Gen] Mode: $mode / Seed: $seed');

    final options = HttpsCallableOptions(timeout: const Duration(seconds: 540));
    final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable('generateReplicateImage', options: options);

    final results = await callable.call(<String, dynamic>{
      'mode': mode,
      'prompt': prompt,
      'characterImageUrl': characterImageUrl,
      'seed': seed,
      'basePrompt': basePrompt,
    });

    final rawData = results.data;
    if (rawData is Map) {
      if (rawData['success'] == false)
        return {'success': false, 'error': rawData['error']};
      return rawData;
    }
    return {'success': false, 'error': 'Invalid format'};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
