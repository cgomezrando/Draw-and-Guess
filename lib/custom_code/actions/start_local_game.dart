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

import '/app_state.dart';

Future<String> startLocalGame(BuildContext context) async {
  const green = Color(0xFF19C08B);
  const purple = Color(0xFF6C5CE7);
  const orange = Color(0xFFF5A623);
  const navy = Color(0xFF203A5C);
  const ink = Color(0xFF213047);

  InputDecoration deco(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: const Color(0xFFF3F5F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  Widget handle() => Center(
        child: Container(
          width: 44,
          height: 5,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );

  Widget primaryBtn(String label, VoidCallback? onTap) => SizedBox(
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
          child: Text(label),
        ),
      );

  Widget sheetBox(Widget child) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: child,
      );

  // Selector de dificultad reutilizable
  Widget diffChips(String current, void Function(String) onPick) {
    final opts = [
      ['facil', 'Fácil', green],
      ['medio', 'Medio', purple],
      ['dificil', 'Difícil', orange],
    ];
    return Row(
      children: opts.map((o) {
        final val = o[0] as String;
        final label = o[1] as String;
        final col = o[2] as Color;
        final sel = val == current;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onPick(val),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? col : const Color(0xFFF3F5F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(label,
                    style: TextStyle(
                        color: sel ? Colors.white : navy,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Selector de tiempo de dibujo (segundos)
  Widget timeChips(int current, void Function(int) onPick) {
    final opts = [30, 60, 90];
    return Row(
      children: opts.map((s) {
        final sel = s == current;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onPick(s),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? green : const Color(0xFFF3F5F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${s}s',
                    style: TextStyle(
                        color: sel ? Colors.white : navy,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Selector de nº de dibujos por partida (5, 10 o ∞=indefinido)
  Widget roundsChips(int current, void Function(int) onPick) {
    final opts = [5, 10, 0]; // 0 = indefinido
    return Row(
      children: opts.map((s) {
        final sel = s == current;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onPick(s),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? green : const Color(0xFFF3F5F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(s == 0 ? '∞' : '$s',
                    style: TextStyle(
                        color: sel ? Colors.white : navy,
                        fontWeight: FontWeight.bold,
                        fontSize: s == 0 ? 20 : 16)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String initialLevel() {
    final d = FFAppState().difficulty;
    return ['facil', 'medio', 'dificil'].contains(d) ? d : 'facil';
  }

  int initialSeconds() {
    try {
      final s = FFAppState().localSeconds;
      if (s == 30 || s == 60 || s == 90) return s;
    } catch (_) {}
    return 60;
  }

  int initialRounds() {
    try {
      final r = FFAppState().localRounds;
      if (r == 0 || r == 5 || r == 10) return r;
    } catch (_) {}
    return 0;
  }

  Future<String?> chooseMode() {
    Widget card(Color c, IconData icon, String t, String s, String v,
            BuildContext ctx) =>
        InkWell(
          onTap: () => Navigator.pop(ctx, v),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.withOpacity(0.35), width: 1.5),
            ),
            child: Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: navy)),
                    const SizedBox(height: 2),
                    Text(s,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c),
            ]),
          ),
        );
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => sheetBox(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            handle(),
            const Text('Elige una modalidad',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
            const SizedBox(height: 16),
            card(green, Icons.groups_rounded, 'Clásico',
                'Uno dibuja, todos adivinan', 'multi', ctx),
            card(purple, Icons.people_alt_rounded, 'Parejas',
                'Dibuja uno, adivina su pareja', 'pairs', ctx),
            card(orange, Icons.auto_awesome_rounded, 'Reto IA',
                'Dibuja y que la IA lo adivine', 'ai', ctx),
          ],
        ),
      ),
    );
  }

  Future<bool> setupPlayers(String mode) async {
    const int maxCount = 4;
    int count = mode == 'ai' ? 1 : 2;
    var level = initialLevel();
    var seconds = initialSeconds();
    var rounds = initialRounds();
    final ctrls = List.generate(maxCount, (_) => TextEditingController());
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          bool canStart() {
            for (var i = 0; i < count; i++) {
              if (ctrls[i].text.trim().isEmpty) return false;
            }
            return true;
          }

          return sheetBox(
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  handle(),
                  const Text('Dificultad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy)),
                  const SizedBox(height: 8),
                  diffChips(level, (v) => setSt(() => level = v)),
                  const SizedBox(height: 18),
                  const Text('Tiempo para dibujar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy)),
                  const SizedBox(height: 8),
                  timeChips(seconds, (v) => setSt(() => seconds = v)),
                  const SizedBox(height: 18),
                  const Text('¿Cuántos dibujos?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy)),
                  const SizedBox(height: 8),
                  roundsChips(rounds, (v) => setSt(() => rounds = v)),
                  const SizedBox(height: 18),
                  const Text('¿Cuántos jugadores?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(maxCount, (i) {
                      final n = i + 1;
                      final sel = n == count;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setSt(() => count = n),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sel ? green : const Color(0xFFF3F5F8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('$n',
                                  style: TextStyle(
                                      color: sel ? Colors.white : navy,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(count, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: ctrls[i],
                        onChanged: (_) => setSt(() {}),
                        style: const TextStyle(color: ink, fontSize: 16),
                        decoration: deco('Jugador ${i + 1}'),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  primaryBtn('Empezar a jugar',
                      canStart() ? () => Navigator.pop(ctx, true) : null),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (ok == true) {
      final players = <LocalPlayerStruct>[];
      for (var i = 0; i < count; i++) {
        players.add(
            LocalPlayerStruct(name: ctrls[i].text.trim(), score: 0, team: ''));
      }
      FFAppState().update(() {
        FFAppState().localPlayers = players;
        FFAppState().localMode = mode;
        FFAppState().difficulty = level;
        FFAppState().localSeconds = seconds;
        FFAppState().localRounds = rounds;
        FFAppState().localDrawerIndex = 0;
        FFAppState().localRound = 1;
      });
    }
    for (final c in ctrls) {
      c.dispose();
    }
    return ok == true;
  }

  Future<bool> setupPairs() async {
    const int maxPairs = 4;
    int count = 2;
    var level = initialLevel();
    var seconds = initialSeconds();
    var rounds = initialRounds();
    final a = List.generate(maxPairs, (_) => TextEditingController());
    final b = List.generate(maxPairs, (_) => TextEditingController());
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          bool canStart() {
            for (var i = 0; i < count; i++) {
              if (a[i].text.trim().isEmpty || b[i].text.trim().isEmpty) {
                return false;
              }
            }
            return true;
          }

          return sheetBox(
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  handle(),
                  const Text('Dificultad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy)),
                  const SizedBox(height: 8),
                  diffChips(level, (v) => setSt(() => level = v)),
                  const SizedBox(height: 18),
                  const Text('Tiempo para dibujar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy)),
                  const SizedBox(height: 8),
                  timeChips(seconds, (v) => setSt(() => seconds = v)),
                  const SizedBox(height: 18),
                  const Text('¿Cuántos dibujos?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy)),
                  const SizedBox(height: 8),
                  roundsChips(rounds, (v) => setSt(() => rounds = v)),
                  const SizedBox(height: 18),
                  const Text('¿Cuántas parejas?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: navy)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(maxPairs, (i) {
                      final n = i + 1;
                      final sel = n == count;
                      final dis = n < 2;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: dis ? null : () => setSt(() => count = n),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sel ? purple : const Color(0xFFF3F5F8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('$n',
                                  style: TextStyle(
                                      color: sel
                                          ? Colors.white
                                          : (dis ? Colors.grey.shade400 : navy),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(count, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pareja ${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: purple)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: a[i],
                            onChanged: (_) => setSt(() {}),
                            style: const TextStyle(color: ink, fontSize: 16),
                            decoration: deco('Jugador 1'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: b[i],
                            onChanged: (_) => setSt(() {}),
                            style: const TextStyle(color: ink, fontSize: 16),
                            decoration: deco('Jugador 2'),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  primaryBtn('Empezar a jugar',
                      canStart() ? () => Navigator.pop(ctx, true) : null),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (ok == true) {
      final pairs = <LocalPlayerStruct>[];
      for (var i = 0; i < count; i++) {
        pairs.add(LocalPlayerStruct(
            name: a[i].text.trim(), team: b[i].text.trim(), score: 0));
      }
      FFAppState().update(() {
        FFAppState().localPlayers = pairs;
        FFAppState().localMode = 'pairs';
        FFAppState().difficulty = level;
        FFAppState().localSeconds = seconds;
        FFAppState().localRounds = rounds;
        FFAppState().localDrawerIndex = 0;
        FFAppState().localRound = 1;
      });
    }
    for (final c in [...a, ...b]) {
      c.dispose();
    }
    return ok == true;
  }

  final mode = await chooseMode();
  if (mode == null) return '';
  final done = mode == 'pairs' ? await setupPairs() : await setupPlayers(mode);
  return done ? mode : '';
}
