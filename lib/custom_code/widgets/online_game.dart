// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/app_state.dart';
import '/custom_code/actions/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:math';

// ============================================================================
//  OnlineGame  —  ronda Clásico online, con el mismo look que el local:
//  fondo con doodles, lienzo grande, cabecera "Dibujando: X" y cuenta atrás
//  sincronizada (roomRef.roundEndsAt).
// ============================================================================

class OnlineGame extends StatefulWidget {
  const OnlineGame({super.key, this.width, this.height, this.onFinish});

  final double? width;
  final double? height;
  final Future Function()? onFinish;

  @override
  State<OnlineGame> createState() => _OnlineGameState();
}

// ---- Paleta -----------------------------------------------------------------
const Color _green = Color(0xFF19C08B);
const Color _navy = Color(0xFF203A5C);
const Color _ink = Color(0xFF213047);
const Color _muted = Color(0xFF6B7280);
const Color _blue = Color(0xFF4C9AF5);
const Color _orange = Color(0xFFF5A623);
const Color _teal = Color(0xFF17BEBB);
const Color _red = Color(0xFFEF6C5A);

class _Stroke {
  final List<Offset> points; // normalizados 0..1
  final Color color;
  final double width;
  _Stroke(this.points, this.color, this.width);
}

class _OnlineGameState extends State<OnlineGame>
    with SingleTickerProviderStateMixin {
  final List<_Stroke> _local = [];
  _Stroke? _current;
  Color _penColor = _navy;
  int? _lastRound;
  bool _finished = false;
  final _guessCtrl = TextEditingController();

  // "reloj" a 1 Hz sin dart:async (AnimationController de 1s que se reinicia)
  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (mounted) setState(() {});
          _ticker.forward(from: 0);
        }
      });
    _ticker.forward();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _guessCtrl.dispose();
    super.dispose();
  }

  String _hex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  Color _fromHex(String h) {
    h = h.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final roomRef = FFAppState().currentRoomRef;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (roomRef == null) {
      return _bg(const Center(child: Text('No hay sala')));
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _bg(
        StreamBuilder<DocumentSnapshot>(
          stream: roomRef.snapshots(),
          builder: (context, roomSnap) {
            final room = roomSnap.data?.data() as Map<String, dynamic>?;
            if (room == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final status = room['status'] as String? ?? 'drawing';
            final drawerRef = room['currentDrawerRef'] as DocumentReference?;
            final drawerName =
                (room['currentDrawerName'] ?? 'Jugador') as String;
            final word = (room['currentWord'] ?? '') as String;
            final round = (room['currentRound'] ?? 1) as int;
            final total = (room['totalRounds'] ?? 5) as int;
            final hostRef = room['hostRef'] as DocumentReference?;
            final isDrawer = drawerRef != null && drawerRef.id == uid;
            final isHost = hostRef != null && hostRef.id == uid;

            // cuenta atrás desde roundEndsAt
            final endsAt = (room['roundEndsAt'] as Timestamp?)?.toDate();
            int remaining = 0;
            if (endsAt != null) {
              remaining = endsAt.difference(DateTime.now()).inSeconds;
              if (remaining < 0) remaining = 0;
            }
            final low = remaining <= 10;

            if (status == 'finished' && !_finished) {
              _finished = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _showFinalResults(roomRef);
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

            return SafeArea(
              child: Column(
                children: [
                  // ---- Cabecera: Dibujando: NOMBRE  +  cuenta atrás ----
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Text('🎨',
                                    style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 10),
                                const Text('Dibujando:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: _muted,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    drawerName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: _ink,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: low ? _red : _green,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                  color: (low ? _red : _green).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⏱️', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(_fmt(remaining),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ---- Subtítulo: ronda + palabra/adivina ----
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                    child: Column(
                      children: [
                        Text('Ronda $round de $total',
                            style: const TextStyle(
                                fontSize: 13,
                                color: _muted,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        if (isDrawer)
                          _wordChip(word)
                        else
                          const Text('Adivina qué es',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _navy)),
                      ],
                    ),
                  ),
                  // ---- Lienzo grande ----
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: 800, maxHeight: 800),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: LayoutBuilder(
                              builder: (ctx, c) {
                                final side = c.maxWidth;
                                return isDrawer
                                    ? _drawerCanvas(roomRef, side)
                                    : _viewerCanvas(roomRef, side);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ---- Controles: paleta (dibujante) / respuesta (resto) ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: isDrawer ? _palette() : _guessRow(roomRef),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(height: 96, child: _guessesFeed(roomRef)),
                  if (isHost)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _hostControls(roomRef),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // -------- Fondo con doodles (igual que el local) ---------------------------
  Widget _bg(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDF7EC), Color(0xFFF5EAD6)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: _doodleLayer()),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _doodleLayer() {
    const icons = <IconData>[
      Icons.brush,
      Icons.favorite,
      Icons.star_rounded,
      Icons.cloud,
      Icons.palette,
      Icons.lightbulb_outline,
      Icons.emoji_emotions_outlined,
      Icons.auto_awesome,
    ];
    return LayoutBuilder(
      builder: (ctx, c) {
        const cell = 64.0;
        final w = c.maxWidth.isFinite ? c.maxWidth : 400.0;
        final h = c.maxHeight.isFinite ? c.maxHeight : 800.0;
        final cols = (w / cell).ceil() + 1;
        final rows = (h / cell).ceil() + 1;
        final items = <Widget>[];
        for (int r = 0; r < rows; r++) {
          for (int col = 0; col < cols; col++) {
            final hsh = ((r * 73856093) ^ (col * 19349663)) & 0x7fffffff;
            final jx = (hsh % 1000) / 1000.0;
            final jy = ((hsh >> 10) % 1000) / 1000.0;
            final rot = ((hsh >> 20) % 1000) / 1000.0 * 6.28318;
            final sz = 45.0 + (hsh >> 5) % 45;
            final ic = icons[hsh % icons.length];
            final left = col * cell + jx * cell - cell / 2;
            final top = r * cell + jy * cell - cell / 2;
            items.add(Positioned(
              left: left,
              top: top,
              child: Transform.rotate(
                angle: rot,
                child: Icon(ic, size: sz, color: _navy.withOpacity(0.06)),
              ),
            ));
          }
        }
        return ClipRect(child: Stack(children: items));
      },
    );
  }

  Widget _wordChip(String word) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _teal.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _teal.withOpacity(0.5), width: 2),
        ),
        child: Text(
          'Tu palabra: ${word.toUpperCase()}',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0E8C8A)),
        ),
      );

  Widget _canvasBox(Widget child) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(color: Colors.white, child: child),
      );

  Widget _drawerCanvas(DocumentReference roomRef, double side) {
    Offset nrm(Offset p) =>
        Offset((p.dx / side).clamp(0.0, 1.0), (p.dy / side).clamp(0.0, 1.0));
    return _canvasBox(
      GestureDetector(
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
        child: CustomPaint(painter: _Painter(_local), size: Size(side, side)),
      ),
    );
  }

  Widget _viewerCanvas(DocumentReference roomRef, double side) {
    return StreamBuilder<QuerySnapshot>(
      stream: roomRef.collection('strokes').orderBy('order').snapshots(),
      builder: (context, snap) {
        final strokes = <_Stroke>[];
        for (final d in (snap.data?.docs ?? const [])) {
          final m = d.data() as Map<String, dynamic>;
          try {
            final data =
                jsonDecode(m['data'] as String) as Map<String, dynamic>;
            final pts = (data['points'] as List)
                .map<Offset>((e) =>
                    Offset((e[0] as num).toDouble(), (e[1] as num).toDouble()))
                .toList();
            strokes.add(_Stroke(
                pts,
                _fromHex((data['color'] ?? '#000000') as String),
                (data['width'] as num?)?.toDouble() ?? 4.0));
          } catch (_) {}
        }
        return _canvasBox(
            CustomPaint(painter: _Painter(strokes), size: Size(side, side)));
      },
    );
  }

  Widget _palette() {
    final palette = [_navy, _red, _blue, _green, _orange];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
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
              border: Border.all(
                  color: sel ? _ink : Colors.white, width: sel ? 3 : 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ],
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
            style: const TextStyle(color: _ink),
            onSubmitted: (_) => _sendGuess(roomRef),
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _green, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _sendGuess(roomRef),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Enviar',
              style: TextStyle(fontWeight: FontWeight.w800)),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final g = docs[i].data() as Map<String, dynamic>;
            final correct = g['isCorrect'] == true;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(correct ? Icons.check_circle : Icons.chat_bubble_outline,
                      color: correct ? _green : Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correct
                          ? '${g['displayName']} ¡acertó!'
                          : '${g['displayName']}: ${g['text']}',
                      style: TextStyle(
                          color: correct ? _green : _ink,
                          fontWeight:
                              correct ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _hostControls(DocumentReference roomRef) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              await roomRef.update({'status': 'finished'});
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _muted,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
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
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Siguiente ronda',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Future<void> _showFinalResults(DocumentReference roomRef) async {
    final names = <String>[];
    final scores = <int>[];
    try {
      final ps = await roomRef
          .collection('players')
          .orderBy('score', descending: true)
          .get();
      for (final d in ps.docs) {
        final m = d.data() as Map<String, dynamic>;
        names.add((m['displayName'] ?? 'Jugador').toString());
        scores.add(((m['score'] ?? 0) as num).toInt());
      }
    } catch (_) {}
    if (!mounted) return;
    // Limpia la sala y muestra resultados; showResults navega al inicio.
    try {
      FFAppState().update(() {
        FFAppState().currentRoomRef = null;
        FFAppState().currentRoomCode = '';
      });
    } catch (_) {}
    await showResults(context, names, scores);
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
        ..strokeJoin = StrokeJoin.round
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
