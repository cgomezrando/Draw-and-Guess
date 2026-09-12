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
//  Custom Action: guessDrawingAi
//  La IA ADIVINA el dibujo SIN saber la palabra. Rasteriza los trazos a PNG
//  y llama a la Cloud Function en modo "guess". Devuelve la palabra que la IA
//  cree que es (String, vacío si falla).
//
//  ALTA EN FLUTTERFLOW (Custom Action):
//    - Nombre: guessDrawingAi
//    - Return Type: String   (lista OFF)
//    - Argumentos: strokes (String, "Is List" ON)
//    - Include BuildContext: OFF
//    - Dependencia (pubspec): http: ^1.2.0
//  ⚠ Usa la MISMA URL de tu Cloud Function que en scoreDrawingAi.
// ============================================================================

import 'dart:convert';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

const String _scoreFnUrl =
    'https://us-central1-draw-and-guess-29e50.cloudfunctions.net/scoreDrawing';

Future<String> guessDrawingAi(List<String> strokes) async {
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
    if (bd == null) return '';
    final b64 = base64Encode(bd.buffer.asUint8List());

    // 2) Llamar a la Cloud Function en modo "guess"
    final resp = await http.post(
      Uri.parse(_scoreFnUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': b64, 'mode': 'guess'}),
    );
    if (resp.statusCode != 200) return '';

    final parsed = jsonDecode(utf8.decode(resp.bodyBytes));
    return (parsed['guess'] ?? '').toString().trim();
  } catch (e) {
    return '';
  }
}
