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
import 'dart:math';

class LocalGame extends StatefulWidget {
  const LocalGame({
    super.key,
    this.width,
    this.height,
    this.onGameEnd,
  });

  final double? width;
  final double? height;
  final Future Function()? onGameEnd;

  @override
  State<LocalGame> createState() => _LocalGameState();
}

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  _Stroke(this.points, this.color, this.width);
}

class _LocalGameState extends State<LocalGame> {
  static const green = Color(0xFF19C08B);
  static const navy = Color(0xFF203A5C);
  static const ink = Color(0xFF213047);
  static const bg = Color(0xFFF7F4EF);
  static const muted = Color(0xFF6B7280);

  late List<Map<String, dynamic>> _players;
  int _drawerIndex = 0;
  int _round = 1;
  String _phase = 'handoff';
  String _word = '';

  final List<_Stroke> _strokes = [];
  _Stroke? _current;
  Color _penColor = Colors.black;
  final double _penWidth = 4.0;

  final _rand = Random();
  final List<String> _bank = const [
    'gato',
    'perro',
    'elefante',
    'casa',
    'coche',
    'árbol',
    'sol',
    'pizza',
    'avión',
    'flor',
    'pez',
    'barco',
    'guitarra',
    'robot',
    'montaña',
    'estrella',
    'llave',
    'reloj',
    'pelota',
    'sombrero',
    'plátano',
    'luna',
    'tren',
    'cohete',
    'dragón',
    'silla',
    'gafas',
    'paraguas',
    'helado',
    'tortuga',
  ];

  int get _totalRounds {
    final r = FFAppState().localTotalRounds;
    return r > 0 ? r : 3;
  }

  @override
  void initState() {
    super.initState();
    _players = FFAppState()
        .localPlayers
        .map((p) => {'name': p.name, 'score': p.score})
        .toList();
    if (_players.isEmpty) {
      _players = [
        {'name': 'Jugador 1', 'score': 0},
        {'name': 'Jugador 2', 'score': 0},
      ];
    }
    _pickWord();
  }

  void _pickWord() => _word = _bank[_rand.nextInt(_bank.length)];

  String get _drawerName => _players[_drawerIndex]['name'] as String;

  void _syncScores() {
    FFAppState().update(() {
      FFAppState().localPlayers = _players
          .map((p) => LocalPlayerStruct(
                name: p['name'] as String,
                score: p['score'] as int,
                team: '',
              ))
          .toList();
    });
  }

  void _awardPoint(int i) {
    setState(() => _players[i]['score'] = (_players[i]['score'] as int) + 1);
    _syncScores();
  }

  Future<void> _nextTurn() async {
    var next = _drawerIndex + 1;
    var round = _round;
    if (next >= _players.length) {
      next = 0;
      round += 1;
    }
    if (round > _totalRounds) {
      _syncScores();
      if (widget.onGameEnd != null) await widget.onGameEnd!();
      return;
    }
    setState(() {
      _drawerIndex = next;
      _round = round;
      _strokes.clear();
      _current = null;
      _pickWord();
      _phase = 'handoff';
    });
  }

  Widget _btn(String label, VoidCallback? onTap) => SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle:
                const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_phase) {
      case 'showword':
        body = _showWord();
        break;
      case 'drawing':
        body = _drawing();
        break;
      case 'reveal':
        body = _reveal();
        break;
      default:
        body = _handoff();
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: bg,
      child: DefaultTextStyle(
        style: const TextStyle(color: ink, fontSize: 14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: body,
        ),
      ),
    );
  }

  Widget _handoff() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ronda $_round de $_totalRounds',
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted)),
          const SizedBox(height: 24),
          const Text('Le toca dibujar a',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: ink)),
          const SizedBox(height: 8),
          Text(_drawerName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 12),
          const Text('Pásale la tablet. Que el resto no mire.',
              textAlign: TextAlign.center, style: TextStyle(color: ink)),
          const SizedBox(height: 28),
          _btn('Ver mi palabra', () => setState(() => _phase = 'showword')),
        ],
      );

  Widget _showWord() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$_drawerName, tu palabra es:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: ink)),
          const SizedBox(height: 16),
          Text(_word,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 8),
          const Text('No la digas en voz alta.',
              textAlign: TextAlign.center, style: TextStyle(color: ink)),
          const SizedBox(height: 28),
          _btn('Empezar a dibujar', () {
            setState(() {
              _strokes.clear();
              _current = null;
              _phase = 'drawing';
            });
          }),
          TextButton(
              onPressed: () => setState(_pickWord),
              child:
                  const Text('Otra palabra', style: TextStyle(color: green))),
        ],
      );

  Widget _drawing() {
    final palette = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
                child: Text('Dibujando: $_drawerName',
                    style: const TextStyle(color: muted))),
            IconButton(
                icon: const Icon(Icons.undo, color: navy),
                onPressed: () => setState(() {
                      if (_strokes.isNotEmpty) _strokes.removeLast();
                    })),
            IconButton(
                icon: const Icon(Icons.delete_outline, color: navy),
                onPressed: () => setState(() => _strokes.clear())),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, c) {
            final side =
                min(c.maxWidth, MediaQuery.of(context).size.height * 0.55);
            return Center(
              child: SizedBox(
                width: side,
                height: side,
                child: GestureDetector(
                  onPanStart: (d) {
                    _current = _Stroke([d.localPosition], _penColor, _penWidth);
                    setState(() => _strokes.add(_current!));
                  },
                  onPanUpdate: (d) =>
                      setState(() => _current?.points.add(d.localPosition)),
                  onPanEnd: (_) => _current = null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                        painter: _Painter(_strokes), size: Size.infinite),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: palette.map((col) {
            final sel = col == _penColor;
            return GestureDetector(
              onTap: () => setState(() => _penColor = col),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: col,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: sel ? navy : Colors.transparent, width: 3),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        _btn('Terminé · ¡A puntuar!', () => setState(() => _phase = 'reveal')),
      ],
    );
  }

  Widget _reveal() {
    final others = <int>[];
    for (var i = 0; i < _players.length; i++) {
      if (i != _drawerIndex) others.add(i);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('La palabra era:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: ink)),
        Text(_word,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 34, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 12),
        const Text('¿Quién ha acertado? Toca para dar +1.',
            textAlign: TextAlign.center, style: TextStyle(color: ink)),
        const SizedBox(height: 12),
        ...others.map((i) => Card(
              color: Colors.white,
              child: ListTile(
                title: Text(_players[i]['name'] as String,
                    style: const TextStyle(color: ink)),
                trailing: Text('${_players[i]['score']} pts',
                    style: const TextStyle(color: muted)),
                onTap: () => _awardPoint(i),
              ),
            )),
        const SizedBox(height: 12),
        _btn('Siguiente turno', _nextTurn),
      ],
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
        canvas.drawLine(s.points[i], s.points[i + 1], p);
      }
    }
  }

  @override
  bool shouldRepaint(_Painter old) => true;
}
