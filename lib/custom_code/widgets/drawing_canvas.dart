// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    super.key,
    this.width,
    this.height,
    required this.strokeColor,
    required this.strokeWidth,
    this.onStrokeFinished,
  });

  final double? width;
  final double? height;
  final Color strokeColor;
  final double strokeWidth;
  // Callback declarado como Action(String) en FlutterFlow:
  final Future Function(String strokeJson)? onStrokeFinished;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  _Stroke(this.points, this.color, this.width);
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<_Stroke> _strokes = [];
  _Stroke? _current;

  void _start(Offset p) {
    _current = _Stroke([p], widget.strokeColor, widget.strokeWidth);
    setState(() => _strokes.add(_current!));
  }

  void _update(Offset p) {
    if (_current == null) return;
    setState(() => _current!.points.add(p));
  }

  Future<void> _end() async {
    if (_current == null) return;
    final s = _current!;
    _current = null;
    // Serializa el trazo terminado a JSON y avisa a FlutterFlow
    final payload = jsonEncode({
      'points': s.points.map((o) => [o.dx, o.dy]).toList(),
      'color':
          '#${s.color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'width': s.width,
    });
    if (widget.onStrokeFinished != null) {
      await widget.onStrokeFinished!(payload);
    }
  }

  // Métodos públicos que puedes exponer con un GlobalKey si quieres
  void undo() => setState(() {
        if (_strokes.isNotEmpty) _strokes.removeLast();
      });
  void clearAll() => setState(() => _strokes.clear());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 320,
      child: GestureDetector(
        onPanStart: (d) => _start(d.localPosition),
        onPanUpdate: (d) => _update(d.localPosition),
        onPanEnd: (_) => _end(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            painter: _CanvasPainter(_strokes),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter(this.strokes);
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.width
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < s.points.length - 1; i++) {
        canvas.drawLine(s.points[i], s.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}
