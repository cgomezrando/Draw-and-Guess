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

/// ============================================================================
/// LocalGame  —  Modo CLÁSICO local (uno dibuja, el resto adivina en voz
/// alta) Flujo: handoff → showword → ready → drawing(cuenta atrás) →
/// timeup/reveal Cuenta atrás con AnimationController (no requiere imports
/// extra).
///
/// ============================================================================
class LocalGame extends StatefulWidget {
  const LocalGame({Key? key, this.width, this.height}) : super(key: key);
  final double? width;
  final double? height;
  @override
  State<LocalGame> createState() => _LocalGameState();
}

// ---- Paleta -----------------------------------------------------------------
const Color _green = Color(0xFF19C08B);
const Color _navy = Color(0xFF203A5C);
const Color _ink = Color(0xFF213047);
const Color _muted = Color(0xFF6B7280);
const Color _blue = Color(0xFF4C9AF5); // 👀 pásale la tablet
const Color _orange = Color(0xFFF5A623); // ✏️ (libre)
const Color _teal = Color(0xFF17BEBB); // 🤫 tu palabra
const Color _purple = Color(0xFF6C5CE7); // 🔄 siguiente jugador
const Color _red = Color(0xFFEF6C5A); // ⏰ se acabó el tiempo
const Color _yellow = Color(0xFFF5B301); // 💡 la palabra era

enum _Phase { handoff, showword, ready, drawing, timeup, reveal }

class _Stroke {
  _Stroke(this.color, this.width);
  final Color color;
  final double width;
  final List<Offset> pts = []; // normalizados 0..1
}

class _LocalGameState extends State<LocalGame>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.handoff;
  String _word = '';
  final List<_Stroke> _strokes = [];
  Color _penColor = _navy;
  late final AnimationController _ctrl;
  int _seconds = 60; // duración elegida (configurable)
  int _left = 60;

  // Generador pseudoaleatorio (Park-Miller, seguro en web)
  int _rng = (DateTime.now().millisecondsSinceEpoch % 2147483646) + 1;
  int _rand() {
    _rng = (_rng * 48271) % 2147483647;
    return _rng;
  }

  final Map<int, int> _scores = {}; // puntos por jugador (índice)
  int? _awardedTo; // a quién se dio el punto en este turno (null = sin elegir)
  // -------- Estado de jugadores (defensivo) ----------------------------------
  // Cada elemento de localPlayers es un LocalPlayerStruct → usamos su .name.
  List<String> get _players {
    try {
      final raw = FFAppState().localPlayers;
      if (raw.isEmpty) return ['Jugador 1', 'Jugador 2'];
      return List<String>.generate(raw.length, (i) {
        final n = raw[i].name.trim();
        return n.isEmpty ? 'Jugador ${i + 1}' : n;
      });
    } catch (_) {
      return ['Jugador 1', 'Jugador 2'];
    }
  }

  int get _drawerIndex {
    try {
      final i = FFAppState().localDrawerIndex as int;
      return i % _players.length;
    } catch (_) {
      return 0;
    }
  }

  int get _round {
    try {
      return FFAppState().localRound as int;
    } catch (_) {
      return 1;
    }
  }

  String get _drawer => _players[_drawerIndex];
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
    super.dispose();
  }

  void _onTick() {
    final rem = (_seconds - _seconds * _ctrl.value).ceil();
    if (rem != _left && rem >= 0) setState(() => _left = rem);
  }

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed && mounted) {
      setState(() => _phase = _Phase.timeup);
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

  void _nextDrawer() {
    _ctrl.stop();
    final n = _players.length;
    final nextIdx = (_drawerIndex + 1) % n;
    try {
      FFAppState().update(() {
        FFAppState().localDrawerIndex = nextIdx;
        if (nextIdx == 0) FFAppState().localRound = _round + 1;
      });
    } catch (_) {}
    setState(() {
      _strokes.clear();
      _word = '';
      _awardedTo = null;
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
      case _Phase.timeup:
        return _timeup();
      case _Phase.reveal:
        return _reveal();
    }
  }

  // -------- Fondo con doodles dispersos --------------------------------------
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
            // hash determinista por celda → posición/rotación/tamaño "aleatorios"
            final hsh = ((r * 73856093) ^ (col * 19349663)) & 0x7fffffff;
            final jx = (hsh % 1000) / 1000.0; // 0..1 dentro de la celda
            final jy = ((hsh >> 10) % 1000) / 1000.0;
            final rot = ((hsh >> 20) % 1000) / 1000.0 * 6.28318; // 0..2π
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
        color: _green.withOpacity(0.14),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        'Ronda $_round · Turno ${_drawerIndex + 1} de ${_players.length}',
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: _green),
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
        _subtitle('Que el resto de jugadores no mire.'),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: _teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _teal.withOpacity(0.6), width: 2),
          ),
          child: Text(
            _word.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0E8C8A)),
          ),
        ),
        const SizedBox(height: 14),
        _subtitle('No se la enseñes a los demás.'),
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

  Widget _timeup() {
    return _centerCard(
      emoji: '⏰',
      badge: _red,
      children: [
        _title('¡Se acabó el tiempo!'),
        const SizedBox(height: 10),
        _subtitle('Veamos las respuestas.'),
        const SizedBox(height: 22),
        _btn('Continuar', _green, () {
          setState(() => _phase = _Phase.reveal);
        }),
      ],
    );
  }

  Widget _reveal() {
    return _centerCard(
      emoji: '💡',
      badge: _yellow,
      children: [
        _title('La palabra era'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: _yellow.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _yellow.withOpacity(0.6), width: 2),
          ),
          child: Text(
            _word.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFFB07D00)),
          ),
        ),
        const SizedBox(height: 18),
        _subtitle('¿Quién la adivinó? (le suma 1 punto)'),
        const SizedBox(height: 12),
        _winnerChips(),
        const SizedBox(height: 20),
        _btn('Siguiente jugador', _purple, _nextDrawer),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            final names = List<String>.from(_players);
            final scores =
                List<int>.generate(_players.length, (i) => _scores[i] ?? 0);
            await showResults(context, names, scores);
          },
          child: const Text('Terminar y ver resultados',
              style: TextStyle(color: _muted, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _winnerChips() {
    final chips = <Widget>[];
    for (int i = 0; i < _players.length; i++) {
      final raw = _players[i].trim();
      final name = raw.isEmpty ? 'Jugador ${i + 1}' : raw;
      chips.add(_awardChip(name, i, canAward: i != _drawerIndex));
    }
    chips.add(_awardChip('Nadie acertó', -1));
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _awardChip(String label, int idx, {bool canAward = true}) {
    final sel = _awardedTo == idx;
    return GestureDetector(
      onTap: !canAward
          ? null
          : () => setState(() {
                // deshacer el punto anterior de este turno si lo había
                if (_awardedTo != null && _awardedTo! >= 0) {
                  _scores[_awardedTo!] = (_scores[_awardedTo!] ?? 0) - 1;
                }
                _awardedTo = idx;
                if (idx >= 0) _scores[idx] = (_scores[idx] ?? 0) + 1;
              }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: sel
              ? _green
              : (canAward ? const Color(0xFFF3F4F6) : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: sel ? _green : const Color(0xFFE2E5EA), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: sel
                ? Colors.white
                : (canAward ? _ink : const Color(0xFF9CA3AF)),
          ),
        ),
      ),
    );
  }

  // -------- Pantalla de dibujo ----------------------------------------------
  Widget _drawing() {
    final low = _left <= 10;
    return SafeArea(
      child: Column(
        children: [
          // Cabecera bonita
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
                // Cuenta atrás
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
          // Lienzo
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
          // Herramientas
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
            child: _btn('Terminé · ¡A puntuar!', _green, () {
              _ctrl.stop();
              setState(() => _phase = _Phase.reveal);
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
