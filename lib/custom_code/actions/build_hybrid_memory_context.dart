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
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:http/http.dart' as http;

class _MemoryChunk {
  const _MemoryChunk({
    required this.id,
    required this.text,
    required this.tsMillis,
    required this.tokens,
    required this.tf,
    required this.vector,
    required this.roleHint,
  });

  final String id;
  final String text;
  final int tsMillis;
  final Set<String> tokens;
  final Map<String, int> tf;
  final List<double> vector;
  final String roleHint;
}

Future<String> buildHybridMemoryContext(
  DocumentReference? storyChatRef,
  String? currentQuery,
) async {
  const vectorToggleRaw =
      String.fromEnvironment('VECTOR_SEARCH_ON', defaultValue: 'ON');
  const qdrantUrlRaw = String.fromEnvironment(
    'QDRANT_URL',
    defaultValue: 'http://127.0.0.1:6333',
  );
  const qdrantCollection = String.fromEnvironment(
    'QDRANT_COLLECTION',
    defaultValue: 'story_memory_chunks_v1',
  );
  const qdrantTimeoutMs = int.fromEnvironment(
    'QDRANT_TIMEOUT_MS',
    defaultValue: 2500,
  );

  final vectorSearchOn = vectorToggleRaw.trim().toUpperCase() != 'OFF';
  final qdrantBaseUrl = qdrantUrlRaw.trim();

  if (storyChatRef == null) {
    return '';
  }

  final msgSnap = await storyChatRef
      .collection('storymessages')
      .orderBy('timestamp', descending: true)
      .limit(220)
      .get();

  if (msgSnap.docs.isEmpty) {
    return '';
  }

  int tsToMillis(dynamic raw) {
    if (raw is firestore.Timestamp) return raw.millisecondsSinceEpoch;
    if (raw is DateTime) return raw.millisecondsSinceEpoch;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return 0;
  }

  String clean(String raw) {
    return raw
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('```', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  final stopwords = <String>{
    '은',
    '는',
    '이',
    '가',
    '을',
    '를',
    '에',
    '의',
    '도',
    '로',
    '와',
    '과',
    '한',
    '또',
    '그리고',
    '그러나',
    '하지만',
    '에서',
    '에게',
    '하다',
    '했다',
    'the',
    'a',
    'an',
    'to',
    'for',
    'and',
    'or',
    'is',
    'are',
    'be',
    'was',
    'were',
    'of',
    'in',
    'on',
    'with',
  };

  List<String> tokenize(String raw) {
    final matches =
        RegExp(r'[가-힣A-Za-z0-9]+').allMatches(raw.toLowerCase()).toList();
    return matches
        .map((m) => m.group(0) ?? '')
        .where((t) => t.length > 1 && !stopwords.contains(t))
        .toList();
  }

  List<double> embed(String raw, {int dim = 64}) {
    final vec = List<double>.filled(dim, 0.0);
    final tokens = tokenize(raw);
    if (tokens.isEmpty) return vec;

    int fnv1a(String s) {
      const int offset = 0x811C9DC5;
      const int prime = 0x01000193;
      var hash = offset;
      for (final c in s.codeUnits) {
        hash ^= c;
        hash = (hash * prime) & 0xFFFFFFFF;
      }
      return hash & 0x7FFFFFFF;
    }

    for (final token in tokens) {
      final h = fnv1a(token);
      final index = h % dim;
      final sign = ((h >> 5) & 1) == 0 ? 1.0 : -1.0;
      final weight = 1.0 + (token.length / 12.0);
      vec[index] += sign * weight;
    }

    final norm = sqrt(vec.fold<double>(0.0, (acc, v) => acc + (v * v)));
    if (norm <= 1e-9) return vec;
    return vec.map((v) => v / norm).toList();
  }

  double cosine(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;
    var dot = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  final units = <Map<String, dynamic>>[];
  final docs = msgSnap.docs.toList().reversed.toList();
  for (final doc in docs) {
    final data = doc.data();
    final type = (data['type'] ?? '').toString().trim();
    if (type == 'thinking' || type == 'turn_header' || type == 'story_image') {
      continue;
    }
    final text = clean((data['text'] ?? '').toString());
    if (text.isEmpty || text == '생각 중') continue;

    final speaker = clean((data['speakerName'] ?? '').toString());
    final role = type == 'user' ? 'user' : 'assistant';
    final tsMillis = tsToMillis(data['timestamp']);
    final normalized = role == 'assistant' && speaker.isNotEmpty
        ? '[$speaker] $text'
        : text;

    units.add({
      'docId': doc.id,
      'text': normalized,
      'role': role,
      'tsMillis': tsMillis,
      'type': type,
    });
  }

  if (units.isEmpty) {
    return '';
  }

  // Chunk optimization: 4-message windows with 1-message overlap.
  final chunks = <_MemoryChunk>[];
  const windowSize = 4;
  const stepSize = 3;
  for (var start = 0; start < units.length; start += stepSize) {
    final endExclusive = min(start + windowSize, units.length);
    final window = units.sublist(start, endExclusive);
    if (window.isEmpty) continue;

    final lines = <String>[];
    final tf = <String, int>{};
    final tokenSet = <String>{};
    var latestTs = 0;
    final roles = <String>{};

    for (final unit in window) {
      final role = (unit['role'] ?? '').toString();
      final text = clean((unit['text'] ?? '').toString());
      if (text.isEmpty) continue;

      roles.add(role);
      lines.add(role == 'user' ? 'U: $text' : 'A: $text');
      latestTs = max(latestTs, (unit['tsMillis'] as int?) ?? 0);

      for (final tok in tokenize(text)) {
        tokenSet.add(tok);
        tf[tok] = (tf[tok] ?? 0) + 1;
      }
    }

    if (lines.isEmpty) continue;
    var chunkText = lines.join('\n').trim();
    if (chunkText.length > 420) {
      chunkText = '${chunkText.substring(0, 420).trim()}...';
    }

    final baseId = '${window.first['docId']}_${start ~/ stepSize}';
    chunks.add(
      _MemoryChunk(
        id: baseId,
        text: chunkText,
        tsMillis: latestTs,
        tokens: tokenSet,
        tf: tf,
        vector: embed(chunkText),
        roleHint: roles.join('+'),
      ),
    );
  }

  if (chunks.isEmpty) return '';

  String seedQuery = clean(currentQuery ?? '');
  if (seedQuery.isEmpty) {
    for (var i = units.length - 1; i >= 0; i--) {
      if ((units[i]['role'] ?? '') == 'user') {
        seedQuery = clean((units[i]['text'] ?? '').toString());
        break;
      }
    }
  }
  if (seedQuery.isEmpty) {
    seedQuery = clean(chunks.last.text);
  }

  final seedTokens = tokenize(seedQuery);
  final tokenFreq = <String, int>{};
  for (final tok in seedTokens) {
    tokenFreq[tok] = (tokenFreq[tok] ?? 0) + 1;
  }
  final topKeywords = tokenFreq.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final keywordQuery = topKeywords.take(8).map((e) => e.key).join(' ');

  final rewrittenQueries = <String>[
    seedQuery,
    keywordQuery,
    [
      ...topKeywords.take(5).map((e) => e.key),
      '갈등',
      '감정',
      '목표',
      '장소',
    ].where((t) => t.trim().isNotEmpty).join(' '),
  ].map(clean).where((q) => q.isNotEmpty).toSet().toList();

  final df = <String, int>{};
  for (final chunk in chunks) {
    for (final tok in chunk.tokens) {
      df[tok] = (df[tok] ?? 0) + 1;
    }
  }
  final chunkCount = max(chunks.length, 1);

  double lexicalScore(_MemoryChunk chunk, String query) {
    final qTokens = tokenize(query);
    if (qTokens.isEmpty) return 0.0;
    var score = 0.0;
    final denom = max(1.0, chunk.tokens.length.toDouble());
    for (final q in qTokens) {
      final tf = (chunk.tf[q] ?? 0).toDouble();
      if (tf <= 0.0) continue;
      final docFreq = (df[q] ?? 1).toDouble();
      final idf = log((chunkCount + 1) / (docFreq + 1)) + 1.0;
      score += (tf / denom) * idf;
    }
    if (chunk.text.contains(query.trim()) && query.trim().length >= 4) {
      score += 0.12;
    }
    return score;
  }

  final denseLocal = <String, double>{};
  final lexicalLocal = <String, double>{};
  for (final chunk in chunks) {
    denseLocal[chunk.id] = 0.0;
    lexicalLocal[chunk.id] = 0.0;
  }

  final queryEmbeds = <String, List<double>>{};
  for (final query in rewrittenQueries) {
    final qVec = embed(query);
    queryEmbeds[query] = qVec;
    for (final chunk in chunks) {
      final d = cosine(qVec, chunk.vector);
      if (d > (denseLocal[chunk.id] ?? 0.0)) {
        denseLocal[chunk.id] = d;
      }
      final l = lexicalScore(chunk, query);
      if (l > (lexicalLocal[chunk.id] ?? 0.0)) {
        lexicalLocal[chunk.id] = l;
      }
    }
  }

  final qdrantScores = <String, double>{};
  var qdrantHealthy = false;
  var qdrantUsed = false;

  Future<Map<String, String>> jsonHeaders() async {
    return {
      'Content-Type': 'application/json',
    };
  }

  Future<void> ensureCollection() async {
    final headers = await jsonHeaders();
    final readUrl = Uri.parse('$qdrantBaseUrl/collections/$qdrantCollection');
    final readRes = await http
        .get(readUrl, headers: headers)
        .timeout(Duration(milliseconds: qdrantTimeoutMs));
    if (readRes.statusCode >= 200 && readRes.statusCode < 300) {
      return;
    }

    final createUrl = Uri.parse('$qdrantBaseUrl/collections/$qdrantCollection');
    final body = jsonEncode({
      'vectors': {
        'size': 64,
        'distance': 'Cosine',
      },
    });
    await http
        .put(createUrl, headers: headers, body: body)
        .timeout(Duration(milliseconds: qdrantTimeoutMs));
  }

  Future<void> upsertChunksToQdrant() async {
    final headers = await jsonHeaders();
    final points = chunks
        .map(
          (chunk) => {
            'id': chunk.id,
            'vector': chunk.vector,
            'payload': {
              'storyChatPath': storyChatRef.path,
              'chunkText': chunk.text,
              'tsMillis': chunk.tsMillis,
              'roleHint': chunk.roleHint,
            }
          },
        )
        .toList();

    final upsertUrl = Uri.parse(
      '$qdrantBaseUrl/collections/$qdrantCollection/points?wait=false',
    );
    await http
        .put(
          upsertUrl,
          headers: headers,
          body: jsonEncode({'points': points}),
        )
        .timeout(Duration(milliseconds: qdrantTimeoutMs));
  }

  Future<void> searchQdrant() async {
    final headers = await jsonHeaders();
    for (final query in rewrittenQueries) {
      final qVec = queryEmbeds[query] ?? const <double>[];
      if (qVec.isEmpty) continue;

      final searchUrl = Uri.parse(
        '$qdrantBaseUrl/collections/$qdrantCollection/points/search',
      );
      final body = jsonEncode({
        'vector': qVec,
        'limit': 14,
        'with_payload': true,
        'filter': {
          'must': [
            {
              'key': 'storyChatPath',
              'match': {'value': storyChatRef.path}
            }
          ]
        },
      });

      final res = await http
          .post(searchUrl, headers: headers, body: body)
          .timeout(Duration(milliseconds: qdrantTimeoutMs));
      if (res.statusCode < 200 || res.statusCode >= 300) continue;

      final decoded = jsonDecode(res.body);
      final resultList = (decoded is Map<String, dynamic>)
          ? (decoded['result'] as List<dynamic>? ?? const <dynamic>[])
          : const <dynamic>[];

      for (final item in resultList) {
        if (item is! Map<String, dynamic>) continue;
        final id = (item['id'] ?? '').toString().trim();
        if (id.isEmpty) continue;
        final score = (item['score'] is num) ? (item['score'] as num).toDouble() : 0.0;
        final old = qdrantScores[id] ?? -1.0;
        if (score > old) qdrantScores[id] = score;
      }
    }
  }

  if (vectorSearchOn && qdrantBaseUrl.isNotEmpty) {
    try {
      final healthRes = await http
          .get(Uri.parse('$qdrantBaseUrl/healthz'))
          .timeout(Duration(milliseconds: qdrantTimeoutMs));
      qdrantHealthy = healthRes.statusCode >= 200 && healthRes.statusCode < 300;
      if (qdrantHealthy) {
        await ensureCollection();
        await upsertChunksToQdrant();
        await searchQdrant();
        qdrantUsed = true;
      }
    } catch (_) {
      qdrantUsed = false;
    }
  }

  final maxTs = chunks.fold<int>(0, (acc, c) => max(acc, c.tsMillis));
  final minTs =
      chunks.fold<int>(maxTs, (acc, c) => (acc == 0 ? c.tsMillis : min(acc, c.tsMillis)));
  final span = max(1, maxTs - minTs);

  final candidates = <Map<String, dynamic>>[];
  for (final chunk in chunks) {
    final dense = denseLocal[chunk.id] ?? 0.0;
    final lexical = lexicalLocal[chunk.id] ?? 0.0;
    final qdrantDense = qdrantScores[chunk.id] ?? 0.0;
    final recency = ((chunk.tsMillis - minTs) / span).clamp(0.0, 1.0).toDouble();
    final hybridDense = qdrantUsed ? ((dense * 0.55) + (qdrantDense * 0.45)) : dense;

    var score = (hybridDense * 0.48) + (lexical * 0.34) + (recency * 0.18);
    if (chunk.roleHint.contains('assistant') && chunk.roleHint.contains('user')) {
      score += 0.03;
    }
    if (chunk.text.length >= 90 && chunk.text.length <= 280) {
      score += 0.02;
    }

    candidates.add({
      'chunk': chunk,
      'score': score,
      'dense': hybridDense,
      'lex': lexical,
    });
  }

  candidates.sort((a, b) => ((b['score'] as double).compareTo(a['score'] as double)));

  final selectedLines = <String>[];
  final seenFingerprints = <String>{};
  var totalChars = 0;
  for (final row in candidates) {
    final score = (row['score'] as double?) ?? 0.0;
    final chunk = row['chunk'] as _MemoryChunk;

    if (score < 0.14) continue;

    final lowered = chunk.text.toLowerCase();
    if (lowered.contains('api_key') ||
        lowered.contains('password') ||
        lowered.contains('secret') ||
        lowered.contains('token=')) {
      continue;
    }

    var compact = chunk.text
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (compact.length > 220) {
      compact = '${compact.substring(0, 220).trim()}...';
    }
    final fp = compact.length > 70 ? compact.substring(0, 70) : compact;
    if (fp.isEmpty || !seenFingerprints.add(fp)) continue;

    if (totalChars + compact.length > 1200) break;

    selectedLines.add(
      '- (score:${score.toStringAsFixed(3)}) $compact',
    );
    totalChars += compact.length;
    if (selectedLines.length >= 6) break;
  }

  if (selectedLines.isEmpty) {
    return '';
  }

  final modeText = (!vectorSearchOn)
      ? 'Firestore-only fallback (VECTOR_SEARCH_ON=OFF)'
      : (qdrantUsed ? 'Hybrid(Vector+Lexical+Rerank)' : 'Firestore-only fallback');

  final queryLines = rewrittenQueries.take(3).map((q) => '- $q').join('\n');
  final memoryBlock = '''
[HYBRID_MEMORY]
MODE: $modeText
QUERY_REWRITE:
$queryLines

RETRIEVED_CHUNKS:
${selectedLines.join('\n')}

[ANSWER_GUARDRAILS]
- 최신 대화(최근 턴)와 유저의 이번 입력을 최우선으로 따른다.
- 위 기억은 보조 근거이며, 충돌 시 가장 최근 사실을 채택한다.
- 근거 없는 시간/장소 점프를 만들지 않는다.
- 기억에 없는 고유명사/사건을 단정하지 않는다.
[/ANSWER_GUARDRAILS]
[/HYBRID_MEMORY]
'''
      .trim();

  return memoryBlock;
}
