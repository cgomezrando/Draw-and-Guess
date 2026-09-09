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

// ============================================================================
//  LocalPairsGame  —  Modo PAREJAS local (uno dibuja, su pareja ESCRIBE)
//  Flujo: handoff → showword → ready → drawing(cuenta atrás)
//         → guessing(la pareja escribe) → result
//  Cuenta atrás con AnimationController (no requiere imports extra).
//
//  ⚠ ADAPTA A TU APP STATE: los getters _pairA / _pairB leen cada pareja de
//    FFAppState().localPlayers. Si tus campos NO se llaman .name (miembro A) y
//    .team (miembro B), cambia SÓLO esas dos líneas marcadas con «AJUSTA AQUÍ».
// ============================================================================

class LocalPairsGame extends StatefulWidget {
  const LocalPairsGame({Key? key, this.width, this.height}) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<LocalPairsGame> createState() => _LocalPairsGameState();
}

// ---- Paleta -----------------------------------------------------------------
const Color _green = Color(0xFF19C08B);
const Color _navy = Color(0xFF203A5C);
const Color _ink = Color(0xFF213047);
const Color _muted = Color(0xFF6B7280);
const Color _blue = Color(0xFF4C9AF5); // 👀 pásale la tablet
const Color _orange = Color(0xFFF5A623); // ✏️ (libre)
const Color _teal = Color(0xFF17BEBB); // 🤫 tu palabra
const Color _purple = Color(0xFF6C5CE7); // 💭 adivina
const Color _red = Color(0xFFEF6C5A); // ❌ / ⏰
const Color _yellow = Color(0xFFF5B301); // 🏆

enum _Phase { handoff, showword, ready, drawing, guessing, result }

class _Stroke {
  _Stroke(this.color, this.width);
  final Color color;
  final double width;
  final List<Offset> pts = []; // normalizados 0..1
}

class _LocalPairsGameState extends State<LocalPairsGame>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.handoff;
  String _word = '';
  final List<_Stroke> _strokes = [];
  Color _penColor = _navy;

  final TextEditingController _guessCtrl = TextEditingController();
  bool _lastCorrect = false;

  late final AnimationController _ctrl;
  int _seconds = 60; // duración elegida (configurable)
  int _left = 60;

  // Generador pseudoaleatorio (Park-Miller, seguro en web)
  int _rng = (DateTime.now().millisecondsSinceEpoch % 2147483646) + 1;
  int _rand() {
    _rng = (_rng * 48271) % 2147483647;
    return _rng;
  }

  int _turn = 0; // avanza en cada turno completo
  final Map<int, int> _scores = {}; // puntos por pareja (índice)

  // -------- Lectura de parejas (defensivo) -----------------------------------
  int get _pairCount {
    try {
      final list = FFAppState().localPlayers as List;
      if (list.isNotEmpty) return list.length;
    } catch (_) {}
    return 2;
  }

  int get _pairIndex => _turn % _pairCount;
  bool get _drawerIsA => (_turn ~/ _pairCount) % 2 == 0;

  String _pairA(int i) {
    try {
      final dynamic p = (FFAppState().localPlayers as List)[i];
      return (p.name as String); // « AJUSTA AQUÍ » miembro A
    } catch (_) {
      return 'Jugador ${i * 2 + 1}';
    }
  }

  String _pairB(int i) {
    try {
      final dynamic p = (FFAppState().localPlayers as List)[i];
      return (p.team as String); // « AJUSTA AQUÍ » miembro B
    } catch (_) {
      return 'Jugador ${i * 2 + 2}';
    }
  }

  String get _drawer => _drawerIsA ? _pairA(_pairIndex) : _pairB(_pairIndex);
  String get _guesser => _drawerIsA ? _pairB(_pairIndex) : _pairA(_pairIndex);
  int get _pairScore => _scores[_pairIndex] ?? 0;

  @override
  void initState() {
    super.initState();
    // Tiempo elegido en la pantalla de selección (App State: localSeconds).
    try {
      final s = FFAppState().localSeconds as int;
      if (s > 0) _seconds = s;
    } catch (_) {}
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: _seconds),
    )
      ..addListener(_onTick)
      ..addStatusListener(_onStatus);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _guessCtrl.dispose();
    super.dispose();
  }

  void _onTick() {
    final rem = (_seconds - _seconds * _ctrl.value).ceil();
    if (rem != _left && rem >= 0) setState(() => _left = rem);
  }

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed && mounted) {
      setState(() => _phase = _Phase.guessing); // tiempo agotado → adivina
    }
  }

  // -------- Lógica -----------------------------------------------------------
  void _pickWord() {
    List<String> pool;
    try {
      pool = wordsForLevel(FFAppState().difficulty);
    } catch (_) {
      pool = const ['gato', 'perro', 'sol', 'casa', 'árbol'];
    }
    if (pool.isEmpty) pool = const ['gato', 'perro', 'sol'];
    _word = pool[_rand() % pool.length];
  }

  void _startTimer() {
    _left = _seconds;
    _ctrl.duration = Duration(seconds: _seconds);
    _ctrl.forward(from: 0);
  }

  String _normalize(String s) {
    s = s.trim().toLowerCase();
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final idx = from.indexOf(ch);
      b.write(idx >= 0 ? to[idx] : ch);
    }
    return b.toString().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  void _submitGuess() {
    final ok = _normalize(_guessCtrl.text) == _normalize(_word);
    setState(() {
      _lastCorrect = ok;
      if (ok) _scores[_pairIndex] = _pairScore + 1;
      _phase = _Phase.result;
    });
  }

  void _nextTurn() {
    _ctrl.stop();
    setState(() {
      _turn++;
      _strokes.clear();
      _word = '';
      _guessCtrl.clear();
      _phase = _Phase.handoff;
    });
  }

  // ==========================================================================
  //  BUILD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _bg(_body()),
    );
  }

  Widget _body() {
    switch (_phase) {
      case _Phase.handoff:
        return _handoff();
      case _Phase.showword:
        return _showword();
      case _Phase.ready:
        return _ready();
      case _Phase.drawing:
        return _drawing();
      case _Phase.guessing:
        return _guessing();
      case _Phase.result:
        return _result();
    }
  }

  // -------- Fondo con doodles uniformes --------------------------------------
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
        const cell = 64.0; // densidad; el jitter rompe las líneas rectas
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
            final sz = 45.0 + (hsh >> 5) % 45; // triple: 45..89
            final ic = icons[hsh % icons.length];
            final left = col * cell + jx * cell - cell / 2;
            final top = r * cell + jy * cell - cell / 2;
            items.add(Positioned(
              left: left,
              top: top,
              child: Transform.rotate(
                angle: rot,
                child: Icon(
                  ic,
                  size: sz,
                  color: _navy.withOpacity(0.06),
                ),
              ),
            ));
          }
        }
        return ClipRect(child: Stack(children: items));
      },
    );
  }

  // -------- Tarjeta central --------------------------------------------------
  Widget _centerCard({
    required String emoji,
    required Color badge,
    required List<Widget> children,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [badge.withOpacity(0.85), badge],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: badge.withOpacity(0.45),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 96)),
                ),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: _purple.withOpacity(0.14),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        'Turno ${_turn + 1} · Pareja ${_pairIndex + 1} de $_pairCount',
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: _purple),
      ),
    );
  }

  Widget _title(String t) => Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: _ink,
          height: 1.1,
        ),
      );

  Widget _subtitle(String t) => Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15.5, color: _muted, height: 1.35),
      );

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label,
            style:
                const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _wordBox(String w, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.55), width: 2),
      ),
      child: Text(
        w.toUpperCase(),
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }

  // -------- Pantallas de paso ------------------------------------------------
  Widget _handoff() {
    return _centerCard(
      emoji: '👀',
      badge: _blue,
      children: [
        _roundPill(),
        const SizedBox(height: 14),
        _title('Pásale la tablet'),
        const SizedBox(height: 10),
        Text(
          _drawer,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: _blue),
        ),
        const SizedBox(height: 6),
        _subtitle('Dibuja para tu pareja (${_guesser}). Que nadie más mire.'),
        const SizedBox(height: 22),
        _btn('Ver mi palabra', _green, () {
          _pickWord();
          setState(() => _phase = _Phase.showword);
        }),
      ],
    );
  }

  Widget _showword() {
    return _centerCard(
      emoji: '🤫',
      badge: _teal,
      children: [
        _title('Tu palabra es…'),
        const SizedBox(height: 18),
        _wordBox(_word, _teal),
        const SizedBox(height: 14),
        _subtitle('Dibújala para que ${_guesser} la adivine.'),
        const SizedBox(height: 22),
        _btn('¡Entendido!', _green, () {
          setState(() => _phase = _Phase.ready);
        }),
      ],
    );
  }

  Widget _ready() {
    return _centerCard(
      emoji: '🎨',
      badge: _green,
      children: [
        _title('Ya puedes dibujar'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Tienes $_seconds segundos',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _green)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _btn('¡Empezar!', _green, () {
          setState(() => _phase = _Phase.drawing);
          _startTimer();
        }),
      ],
    );
  }

  Widget _result() {
    final ok = _lastCorrect;
    return _centerCard(
      emoji: ok ? '🎉' : '❌',
      badge: ok ? _green : _red,
      children: [
        _title(ok ? '¡Correcto!' : 'No es correcto'),
        const SizedBox(height: 12),
        if (ok)
          _subtitle('¡Bien hecho, ${_guesser}! +1 punto para la pareja.')
        else ...[
          _subtitle('La palabra era:'),
          const SizedBox(height: 12),
          _wordBox(_word, _red),
        ],
        const SizedBox(height: 14),
        Text('Puntos de la pareja: $_pairScore',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: _muted)),
        const SizedBox(height: 20),
        _btn('Siguiente turno', _purple, _nextTurn),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            final names = List<String>.generate(
                _pairCount, (i) => '${_pairA(i)} & ${_pairB(i)}');
            final scores =
                List<int>.generate(_pairCount, (i) => _scores[i] ?? 0);
            await showResults(context, names, scores);
          },
          child: const Text('Terminar y ver resultados',
              style: TextStyle(color: _muted, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // -------- Pantalla la pareja adivina (escribe) -----------------------------
  Widget _guessing() {
    return _centerCard(
      emoji: '💭',
      badge: _purple,
      children: [
        _title('Adivina la palabra'),
        const SizedBox(height: 8),
        _subtitle('$_guesser, escribe qué ha dibujado ${_drawer}.'),
        const SizedBox(height: 18),
        TextField(
          controller: _guessCtrl,
          autofocus: true,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitGuess(),
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: _ink),
          decoration: InputDecoration(
            hintText: 'Escribe aquí…',
            hintStyle: const TextStyle(color: _muted),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _purple.withOpacity(0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _purple, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _btn('Enviar', _purple, _submitGuess),
      ],
    );
  }

  // -------- Pantalla de dibujo ----------------------------------------------
  Widget _drawing() {
    final low = _left <= 10;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
                        const Text('🎨', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        const Text('Dibujando:',
                            style: TextStyle(
                                fontSize: 16,
                                color: _muted,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _drawer,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      Text('0:${_left.toString().padLeft(2, '0')}',
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 800, maxHeight: 800),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (ctx, c) {
                        final side = c.maxWidth;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            color: Colors.white,
                            child: GestureDetector(
                              onPanStart: (d) {
                                setState(() {
                                  final s = _Stroke(_penColor, 4);
                                  s.pts.add(_norm(d.localPosition, side));
                                  _strokes.add(s);
                                });
                              },
                              onPanUpdate: (d) {
                                setState(() {
                                  if (_strokes.isNotEmpty) {
                                    _strokes.last.pts
                                        .add(_norm(d.localPosition, side));
                                  }
                                });
                              },
                              child: CustomPaint(
                                painter: _Painter(_strokes),
                                size: Size(side, side),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _swatch(_navy),
                _swatch(_red),
                _swatch(_blue),
                _swatch(_green),
                _swatch(_orange),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_strokes.isNotEmpty) _strokes.removeLast();
                    });
                  },
                  icon: const Icon(Icons.undo, color: _ink),
                ),
                IconButton(
                  onPressed: () => setState(() => _strokes.clear()),
                  icon: const Icon(Icons.delete_outline, color: _ink),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
            child: _btn('Terminé · ¡Que adivine!', _green, () {
              _ctrl.stop();
              setState(() => _phase = _Phase.guessing);
            }),
          ),
        ],
      ),
    );
  }

  Offset _norm(Offset p, double side) {
    double x = (p.dx / side).clamp(0.0, 1.0);
    double y = (p.dy / side).clamp(0.0, 1.0);
    return Offset(x, y);
  }

  Widget _swatch(Color c) {
    final sel = _penColor == c;
    return GestureDetector(
      onTap: () => setState(() => _penColor = c),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border:
              Border.all(color: sel ? _ink : Colors.white, width: sel ? 3 : 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
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
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < s.pts.length - 1; i++) {
        final a = Offset(s.pts[i].dx * size.width, s.pts[i].dy * size.height);
        final b =
            Offset(s.pts[i + 1].dx * size.width, s.pts[i + 1].dy * size.height);
        canvas.drawLine(a, b, paint);
      }
      if (s.pts.length == 1) {
        final a = Offset(s.pts[0].dx * size.width, s.pts[0].dy * size.height);
        canvas.drawCircle(a, s.width / 2, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
