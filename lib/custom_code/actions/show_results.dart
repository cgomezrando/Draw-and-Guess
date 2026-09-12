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

import 'package:go_router/go_router.dart';

// ============================================================================
//  Custom Action: showResults
//  Muestra un diálogo con la clasificación final: 🏆 1º, 🥈 2º, 🥉 3º.
//  Recibe nombres y puntuaciones en paralelo (mismo orden/índice).
//
//  ALTA EN FLUTTERFLOW (Custom Action):
//    - Nombre: showResults
//    - Return Type: (ninguno)   → deja "Action" sin valor de retorno
//    - Include BuildContext: ON
//    - Argumentos:
//        · names  : String,  "Is List" = ON
//        · scores : Integer, "Is List" = ON
// ============================================================================

Future<void> showResults(
  BuildContext context,
  List<String> names,
  List<int> scores,
) async {
  const green = Color(0xFF19C08B);
  const ink = Color(0xFF213047);
  const muted = Color(0xFF6B7280);
  const yellow = Color(0xFFF5B301);

  final n = names.length;
  final order = List<int>.generate(n, (i) => i);
  int scoreOf(int i) => (i >= 0 && i < scores.length) ? scores[i] : 0;
  order.sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));

  String medal(int pos) {
    if (pos == 0) return '🏆';
    if (pos == 1) return '🥈';
    if (pos == 2) return '🥉';
    return '${pos + 1}º';
  }

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 460,
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [yellow.withOpacity(0.85), yellow],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: yellow.withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('🏆', style: TextStyle(fontSize: 78)),
                ),
                const SizedBox(height: 16),
                const Text('Resultados',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
                if (order.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('¡Gana ${names[order.first]}! 🎉',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15,
                          color: muted,
                          fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(order.length, (pos) {
                        final i = order[pos];
                        final name = names[i];
                        final score = scoreOf(i);
                        final top = pos == 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: top
                                ? yellow.withOpacity(0.14)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: top
                                ? Border.all(
                                    color: yellow.withOpacity(0.6), width: 2)
                                : null,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 36,
                                child: Text(medal(pos),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: ink)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: ink)),
                              ),
                              Text('$score',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: top ? yellow : ink)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Volver al inicio',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // Al cerrar el diálogo, volver a la pantalla de inicio (reinicia la partida).
  if (context.mounted) {
    context.goNamed('HomePage');
  }
}
