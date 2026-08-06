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

class LocalPairsGame extends StatefulWidget {
  const LocalPairsGame({
    super.key,
    this.width,
    this.height,
    this.onGameEnd,
  });

  final double? width;
  final double? height;
  final Future Function()? onGameEnd;

  @override
  State<LocalPairsGame> createState() => _LocalPairsGameState();
}

class _Stroke {
  final List<Offset> points; // coordenadas normalizadas 0..1
  final Color color;
  final double width;
  _Stroke(this.points, this.color, this.width);
}

class _LocalPairsGameState extends State<LocalPairsGame> {
  static const green = Color(0xFF19C08B);
  static const purple = Color(0xFF6C5CE7);
  static const navy = Color(0xFF203A5C);
  static const ink = Color(0xFF213047);
  static const bg = Color(0xFFF7F4EF);

  late List<Map<String, dynamic>> _pairs; // {a, b, score, plays}
  int _pairIndex = 0;
  int _round = 1;
  String _phase = 'handoff'; // handoff|showword|drawing|guessing|result
  String _word = '';
  bool _lastCorrect = false;
  String _feedback = '';
  final _guessCtrl = TextEditingController();

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
    _pairs = FFAppState().localPlayers.map((p) {
      return {
        'a': p.name,
        'b': p.team.isEmpty ? 'Compañero' : p.team,
        'score': p.score,
        'plays': 0,
      };
    }).toList();
    if (_pairs.isEmpty) {
      _pairs = [
        {'a': 'Ana', 'b': 'Luis', 'score': 0, 'plays': 0},
        {'a': 'Sara', 'b': 'Marc', 'score': 0, 'plays': 0},
      ];
    }
    _pickWord();
  }

  @override
  void dispose() {
    _guessCtrl.dispose();
    super.dispose();
  }

  void _pickWord() => _word = _bank[_rand.nextInt(_bank.length)];

  Map<String, dynamic> get _pair => _pairs[_pairIndex];
  bool get _drawerIsA => (_pair['plays'] as int) % 2 == 0;
  String get _drawerName =>
      _drawerIsA ? _pair['a'] as String : _pair['b'] as String;
  String get _guesserName =>
      _drawerIsA ? _pair['b'] as String : _pair['a'] as String;
  String get _pairName => '${_pair['a']} & ${_pair['b']}';

  String _norm(String s) {
    s = s.toLowerCase().trim();
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    return s.replaceAll(RegExp(r'\s+'), ' ');
  }

  Offset _normPt(Offset p, double side) =>
      Offset((p.dx / side).clamp(0.0, 1.0), (p.dy / side).clamp(0.0, 1.0));

  void _syncScores() {
    FFAppState().update(() {
      FFAppState().localPlayers = _pairs
          .map((p) => LocalPlayerStruct(
                name: p['a'] as String,
                team: p['b'] as String,
                score: p['score'] as int,
              ))
          .toList();
    });
  }

  void _check() {
    if (_norm(_guessCtrl.text) == _norm(_word)) {
      setState(() {
        _pair['score'] = (_pair['score'] as int) + 1;
        _lastCorrect = true;
        _phase = 'result';
      });
      _syncScores();
    } else {
      setState(() => _feedback = 'Casi… prueba otra vez');
    }
  }

  void _pass() {
    setState(() {
      _lastCorrect = false;
      _phase = 'result';
    });
  }

  Future<void> _nextTurn() async {
    _pair['plays'] = (_pair['plays'] as int) + 1;
    var next = _pairIndex + 1;
    var round = _round;
    if (next >= _pairs.length) {
      next = 0;
      round += 1;
    }
    if (round > _totalRounds) {
      _syncScores();
      if (widget.onGameEnd != null) await widget.onGameEnd!();
      return;
    }
    setState(() {
      _pairIndex = next;
      _round = round;
      _strokes.clear();
      _current = null;
      _guessCtrl.clear();
      _feedback = '';
      _pickWord();
      _phase = 'handoff';
    });
  }

  Widget _btn(String label, VoidCallback? onTap, {Color color = green}) =>
      SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
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
      case 'guessing':
        body = _guessing();
        break;
      case 'result':
        body = _result();
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
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 18),
          Text('Turno de $_pairName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: purple)),
          const SizedBox(height: 18),
          const Text('Le toca dibujar a',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: ink)),
          const SizedBox(height: 6),
          Text(_drawerName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 10),
          Text('Pásale la tablet. ¡$_guesserName, no mires!',
              textAlign: TextAlign.center, style: const TextStyle(color: ink)),
          const SizedBox(height: 26),
          _btn('Ver mi palabra', () => setState(() => _phase = 'showword')),
        ],
      );

  Widget _showWord() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$_drawerName, dibuja:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: ink)),
          const SizedBox(height: 16),
          Text(_word,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 8),
          Text('Que $_guesserName no la vea.',
              textAlign: TextAlign.center, style: const TextStyle(color: ink)),
          const SizedBox(height: 26),
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

  Widget _canvas({required bool interactive, required double side}) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(painter: _Painter(_strokes), size: Size.infinite),
      ),
    );
    return SizedBox(
      width: side,
      height: side,
      child: interactive
          ? GestureDetector(
              onPanStart: (d) {
                _current = _Stroke(
                    [_normPt(d.localPosition, side)], _penColor, _penWidth);
                setState(() => _strokes.add(_current!));
              },
              onPanUpdate: (d) => setState(
                  () => _current?.points.add(_normPt(d.localPosition, side))),
              onPanEnd: (_) => _current = null,
              child: child,
            )
          : child,
    );
  }

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
                    style: TextStyle(color: Colors.grey.shade600))),
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
            return Center(child: _canvas(interactive: true, side: side));
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
        _btn('Listo · que adivine $_guesserName',
            () => setState(() => _phase = 'guessing')),
      ],
    );
  }

  Widget _guessing() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$_guesserName, ¿qué ha dibujado $_drawerName?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: ink)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final side =
                  min(c.maxWidth, MediaQuery.of(context).size.height * 0.34);
              return Center(child: _canvas(interactive: false, side: side));
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _guessCtrl,
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(color: ink, fontSize: 18),
            onChanged: (_) {
              if (_feedback.isNotEmpty) setState(() => _feedback = '');
            },
            onSubmitted: (_) => _check(),
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: const Color(0xFFF3F5F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_feedback,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 12),
          _btn('Comprobar', _check),
          const SizedBox(height: 6),
          TextButton(
              onPressed: _pass,
              child: Text('No lo sabemos / pasar',
                  style: TextStyle(color: Colors.grey.shade600))),
        ],
      ),
    );
  }

  Widget _result() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(_lastCorrect ? Icons.check_circle : Icons.info_outline,
              size: 64, color: _lastCorrect ? green : Colors.grey),
          const SizedBox(height: 8),
          Text(_lastCorrect ? '¡Correcto!' : 'Nadie lo pilló',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 6),
          Text(
              _lastCorrect
                  ? '+1 punto para $_pairName'
                  : 'La palabra era "$_word"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          const SizedBox(height: 26),
          _btn('Siguiente turno', _nextTurn),
        ],
      );
}

class _Painter extends CustomPainter {
  _Painter(this.strokes);
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
        final p1 =
            Offset(s.points[i].dx * size.width, s.points[i].dy * size.height);
        final p2 = Offset(
            s.points[i + 1].dx * size.width, s.points[i + 1].dy * size.height);
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_Painter old) => true;
}
