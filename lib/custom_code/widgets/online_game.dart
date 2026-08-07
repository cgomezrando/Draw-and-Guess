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

import '/app_state.dart';
import '/custom_code/actions/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:math';

class OnlineGame extends StatefulWidget {
  const OnlineGame({super.key, this.width, this.height, this.onFinish});

  final double? width;
  final double? height;
  final Future Function()? onFinish;

  @override
  State<OnlineGame> createState() => _OnlineGameState();
}

class _Stroke {
  final List<Offset> points; // normalizados 0..1
  final Color color;
  final double width;
  _Stroke(this.points, this.color, this.width);
}

class _OnlineGameState extends State<OnlineGame> {
  static const green = Color(0xFF19C08B);
  static const navy = Color(0xFF203A5C);
  static const ink = Color(0xFF213047);
  static const bg = Color(0xFFF7F4EF);

  final List<_Stroke> _local = [];
  _Stroke? _current;
  Color _penColor = Colors.black;
  int? _lastRound;
  bool _finished = false;
  final _guessCtrl = TextEditingController();

  @override
  void dispose() {
    _guessCtrl.dispose();
    super.dispose();
  }

  String _hex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  Color _fromHex(String h) {
    h = h.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final roomRef = FFAppState().currentRoomRef;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (roomRef == null) {
      return const Center(child: Text('No hay sala'));
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: bg,
      padding: const EdgeInsets.all(14),
      child: StreamBuilder<DocumentSnapshot>(
        stream: roomRef.snapshots(),
        builder: (context, roomSnap) {
          final room = roomSnap.data?.data() as Map<String, dynamic>?;
          if (room == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final status = room['status'] as String? ?? 'drawing';
          final drawerRef = room['currentDrawerRef'] as DocumentReference?;
          final word = (room['currentWord'] ?? '') as String;
          final round = (room['currentRound'] ?? 1) as int;
          final total = (room['totalRounds'] ?? 5) as int;
          final hostRef = room['hostRef'] as DocumentReference?;
          final isDrawer = drawerRef != null && drawerRef.id == uid;
          final isHost = hostRef != null && hostRef.id == uid;

          if (status == 'finished' && !_finished && widget.onFinish != null) {
            _finished = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await widget.onFinish!();
            });
          }
          if (isDrawer && _lastRound != round) {
            _lastRound = round;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _local.clear();
                  _current = null;
                });
              }
            });
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Ronda $round de $total',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(isDrawer ? 'Dibuja: $word' : 'Adivina qué es',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, c) {
                  final side = min(min(c.maxWidth, 460.0),
                      MediaQuery.of(context).size.height * 0.42);
                  return Center(
                    child: isDrawer
                        ? _drawerCanvas(roomRef, side)
                        : _viewerCanvas(roomRef, side),
                  );
                },
              ),
              const SizedBox(height: 10),
              if (isDrawer) _palette() else _guessRow(roomRef),
              const SizedBox(height: 8),
              SizedBox(height: 130, child: _guessesFeed(roomRef)),
              if (isHost) _hostControls(roomRef),
            ],
          );
        },
      ),
    );
  }

  Widget _canvasBox(Widget child) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      );

  Widget _drawerCanvas(DocumentReference roomRef, double side) {
    Offset nrm(Offset p) =>
        Offset((p.dx / side).clamp(0.0, 1.0), (p.dy / side).clamp(0.0, 1.0));
    return SizedBox(
      width: side,
      height: side,
      child: GestureDetector(
        onPanStart: (d) {
          _current = _Stroke([nrm(d.localPosition)], _penColor, 4.0);
          setState(() => _local.add(_current!));
        },
        onPanUpdate: (d) =>
            setState(() => _current?.points.add(nrm(d.localPosition))),
        onPanEnd: (_) async {
          final s = _current;
          _current = null;
          if (s == null) return;
          final json = jsonEncode({
            'points': s.points.map((o) => [o.dx, o.dy]).toList(),
            'color': _hex(s.color),
            'width': s.width,
          });
          await addStrokeOnline(roomRef, json);
        },
        child: _canvasBox(
            CustomPaint(painter: _Painter(_local), size: Size.infinite)),
      ),
    );
  }

  Widget _viewerCanvas(DocumentReference roomRef, double side) {
    return SizedBox(
      width: side,
      height: side,
      child: StreamBuilder<QuerySnapshot>(
        stream: roomRef.collection('strokes').orderBy('order').snapshots(),
        builder: (context, snap) {
          final strokes = <_Stroke>[];
          for (final d in (snap.data?.docs ?? const [])) {
            final m = d.data() as Map<String, dynamic>;
            try {
              final data =
                  jsonDecode(m['data'] as String) as Map<String, dynamic>;
              final pts = (data['points'] as List)
                  .map<Offset>((e) => Offset(
                      (e[0] as num).toDouble(), (e[1] as num).toDouble()))
                  .toList();
              strokes.add(_Stroke(
                  pts,
                  _fromHex((data['color'] ?? '#000000') as String),
                  (data['width'] as num?)?.toDouble() ?? 4.0));
            } catch (_) {}
          }
          return _canvasBox(
              CustomPaint(painter: _Painter(strokes), size: Size.infinite));
        },
      ),
    );
  }

  Widget _palette() {
    final palette = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: palette.map((col) {
        final sel = col == _penColor;
        return GestureDetector(
          onTap: () => setState(() => _penColor = col),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: col,
              shape: BoxShape.circle,
              border:
                  Border.all(color: sel ? navy : Colors.transparent, width: 3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _guessRow(DocumentReference roomRef) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _guessCtrl,
            style: const TextStyle(color: ink),
            onSubmitted: (_) => _sendGuess(roomRef),
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _sendGuess(roomRef),
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Enviar'),
        ),
      ],
    );
  }

  Future<void> _sendGuess(DocumentReference roomRef) async {
    final t = _guessCtrl.text.trim();
    if (t.isEmpty) return;
    _guessCtrl.clear();
    await submitGuessOnline(roomRef, t);
  }

  Widget _guessesFeed(DocumentReference roomRef) {
    return StreamBuilder<QuerySnapshot>(
      stream: roomRef
          .collection('guesses')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? const [];
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final g = docs[i].data() as Map<String, dynamic>;
            final correct = g['isCorrect'] == true;
            return ListTile(
              dense: true,
              leading: Icon(
                  correct ? Icons.check_circle : Icons.chat_bubble_outline,
                  color: correct ? green : Colors.grey,
                  size: 20),
              title: Text(
                correct
                    ? '${g['displayName']} ¡acertó!'
                    : '${g['displayName']}: ${g['text']}',
                style: TextStyle(
                    color: correct ? green : ink,
                    fontWeight: correct ? FontWeight.bold : FontWeight.normal),
              ),
            );
          },
        );
      },
    );
  }

  Widget _hostControls(DocumentReference roomRef) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                await roomRef.update({'status': 'finished'});
              },
              child: const Text('Terminar'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                await startRoundOnline(roomRef);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Siguiente ronda'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter(this.strokes);
  final List<_Stroke> strokes;
  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final p = Paint()
        ..color = s.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.width
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < s.points.length - 1; i++) {
        final a =
            Offset(s.points[i].dx * size.width, s.points[i].dy * size.height);
        final b = Offset(
            s.points[i + 1].dx * size.width, s.points[i + 1].dy * size.height);
        canvas.drawLine(a, b, p);
      }
    }
  }

  @override
  bool shouldRepaint(_Painter old) => true;
}
