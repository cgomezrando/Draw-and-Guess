// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// ============================================================================
//  Custom Action: scoreDrawingAi
//  Recibe los TRAZOS del dibujo (como List<String>) + la palabra objetivo,
//  los rasteriza a un PNG en un lienzo off-screen y se lo pasa a GPT-4o-mini
//  (visión). Devuelve un AiResultStruct { score, guess, reason }.
//
//  Formato de cada trazo (string):  "RRGGBB:x1,y1;x2,y2;..."
//    · RRGGBB  = color en hex (sin alfa)
//    · xN,yN   = puntos normalizados 0..1
//
//  ALTA EN FLUTTERFLOW (Custom Action):
//    - Nombre: scoreDrawingAi
//    - Return Type: Data Type → AiResult  (lista OFF)
//    - Argumentos:
//        · strokes : String, "Is List" = ON
//        · word    : String
//    - Include BuildContext: OFF
//    - Dependencia (Custom Code → pubspec):  http: ^1.2.0
// ============================================================================

import '/app_state.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

Future<AiResultStruct> scoreDrawingAi(
  List<String> strokes,
  String word,
) async {
  final key = FFAppState().openaiKey;
  if (key.trim().isEmpty) {
    return AiResultStruct(
      score: -1,
      guess: '',
      reason: 'Falta la API key. Pégala en App State → openaiKey.',
    );
  }

  try {
    // 1) Rasterizar los trazos a PNG (lienzo blanco 512x512)
    const double size = 512.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, size, size));
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size, size),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    for (final s in strokes) {
      final sep = s.indexOf(':');
      if (sep < 0) continue;
      final hex = s.substring(0, sep);
      final rest = s.substring(sep + 1);
      final colorVal = 0xFF000000 | (int.tryParse(hex, radix: 16) ?? 0);
      final paint = ui.Paint()
        ..color = ui.Color(colorVal)
        ..strokeWidth = 5
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..style = ui.PaintingStyle.stroke;

      final pts = <ui.Offset>[];
      for (final pair in rest.split(';')) {
        if (pair.isEmpty) continue;
        final xy = pair.split(',');
        if (xy.length != 2) continue;
        final x = double.tryParse(xy[0]) ?? 0;
        final y = double.tryParse(xy[1]) ?? 0;
        pts.add(ui.Offset(x * size, y * size));
      }
      for (int i = 0; i < pts.length - 1; i++) {
        canvas.drawLine(pts[i], pts[i + 1], paint);
      }
      if (pts.length == 1) {
        canvas.drawCircle(pts[0], 2.5, paint..style = ui.PaintingStyle.fill);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    if (bd == null) {
      return AiResultStruct(
          score: -1, guess: '', reason: 'No se pudo generar la imagen.');
    }
    final b64 = base64Encode(bd.buffer.asUint8List());

    // 2) Preguntar a la IA
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final payload = jsonEncode({
      'model': 'gpt-4o-mini',
      'temperature': 0.2,
      'max_tokens': 200,
      'messages': [
        {
          'role': 'system',
          'content': 'Eres un juez ESTRICTO de un juego de dibujar y adivinar. '
              'Evalúas cuán claramente un dibujo hecho a mano representa una '
              'palabra concreta. Sé exigente y crítico: la mayoría de los '
              'dibujos amateur deben quedar por debajo de 50. Reglas de '
              'puntuación: 0-10 si el lienzo está casi vacío, es una sola '
              'línea, garabatos o algo irreconocible; 10-40 si se intuye '
              'algo pero es dudoso; 40-70 si se reconoce con esfuerzo; '
              '70-100 solo si es claramente identificable como esa palabra '
              'concreta (no una categoría vaga). No premies el parecido con '
              'una categoría general (p. ej. "un animal"): puntúa el parecido '
              'con la palabra EXACTA. Responde SIEMPRE solo con un objeto '
              'JSON, sin texto adicional.'
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'El dibujo intenta representar la palabra "$word". Puntúa de 0 '
                  'a 100 cuán claramente se reconoce como "$word" siguiendo '
                  'las reglas estrictas. Si está casi vacío o es solo una '
                  'línea o garabatos, pon 0-10. En "guess" di honestamente '
                  'qué parece (incluso "nada" o "un garabato"). Devuelve SOLO '
                  'este JSON: {"score": <entero 0-100>, "guess": "<qué parece '
                  'que es>", "reason": "<motivo breve en español>"}'
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/png;base64,$b64',
                'detail': 'low',
              }
            }
          ]
        }
      ]
    });

    final resp = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: payload,
    );

    if (resp.statusCode != 200) {
      return AiResultStruct(
        score: -1,
        guess: '',
        reason: 'Error ${resp.statusCode}. Revisa la API key o el saldo.',
      );
    }

    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    var content =
        (data['choices'][0]['message']['content'] ?? '').toString().trim();
    if (content.startsWith('```')) {
      content = content
          .replaceAll(RegExp(r'^```[a-zA-Z]*'), '')
          .replaceAll('```', '')
          .trim();
    }

    final parsed = jsonDecode(content);
    int score = 0;
    if (parsed['score'] is num) {
      score = (parsed['score'] as num).round();
    } else {
      score = int.tryParse('${parsed['score']}') ?? 0;
    }
    if (score < 0) score = 0;
    if (score > 100) score = 100;

    return AiResultStruct(
      score: score,
      guess: (parsed['guess'] ?? '').toString(),
      reason: (parsed['reason'] ?? '').toString(),
    );
  } catch (e) {
    return AiResultStruct(score: -1, guess: '', reason: 'Error: $e');
  }
}
