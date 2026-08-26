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
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> startOnlineGame(BuildContext context) async {
  const purple = Color(0xFF6C5CE7);
  const navy = Color(0xFF203A5C);
  const ink = Color(0xFF213047);

  final nameCtrl = TextEditingController();

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

  Widget btn(String label, VoidCallback? onTap, {Color color = purple}) =>
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

  void showErr(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  final action = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) {
        final ok = nameCtrl.text.trim().isNotEmpty;
        return sheetBox(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              handle(),
              const Text('Jugar online',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                textAlign: TextAlign.center,
                style: const TextStyle(color: ink, fontSize: 16),
                onChanged: (_) => setSt(() {}),
                decoration: deco('Tu nombre'),
              ),
              const SizedBox(height: 16),
              btn('Crear sala', ok ? () => Navigator.pop(ctx, 'create') : null),
              const SizedBox(height: 10),
              btn('Unirse a sala', ok ? () => Navigator.pop(ctx, 'join') : null,
                  color: navy),
            ],
          ),
        );
      },
    ),
  );

  final name = nameCtrl.text.trim();
  nameCtrl.dispose();
  if (action == null || name.isEmpty) return '';

  if (action == 'create') {
    final mode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        Widget card(Color c, IconData icon, String t, String s, String v) =>
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
        return sheetBox(
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
              card(const Color(0xFF19C08B), Icons.groups_rounded, 'Clásico',
                  'Uno dibuja, todos adivinan', 'multi'),
              card(purple, Icons.people_alt_rounded, 'Parejas',
                  'Dibuja uno, adivina su pareja', 'pairs'),
              card(const Color(0xFFF5A623), Icons.auto_awesome_rounded,
                  'Reto IA', 'Dibuja y que la IA lo adivine', 'ai'),
            ],
          ),
        );
      },
    );
    if (mode == null) return '';
    try {
      final userRef = await ensureUserDoc(name);
      final roomRef = await createRoom(mode, userRef, name);
      final snap = await roomRef.get();
      FFAppState().update(() {
        FFAppState().currentRoomRef = roomRef;
        FFAppState().currentRoomCode =
            ((snap.data() as Map)['code'] ?? '') as String;
      });
      return 'created';
    } catch (e) {
      showErr(e);
      return '';
    }
  } else {
    final codeCtrl = TextEditingController();
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final ok = codeCtrl.text.trim().length >= 3;
          return sheetBox(
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                handle(),
                const Text('Código de la sala',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: navy)),
                const SizedBox(height: 14),
                TextField(
                  controller: codeCtrl,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                      color: ink, fontSize: 22, letterSpacing: 4),
                  onChanged: (_) => setSt(() {}),
                  decoration: deco('Ej: K7QF'),
                ),
                const SizedBox(height: 16),
                btn('Entrar',
                    ok ? () => Navigator.pop(ctx, codeCtrl.text.trim()) : null),
              ],
            ),
          );
        },
      ),
    );
    codeCtrl.dispose();
    if (code == null || code.isEmpty) return '';
    try {
      final userRef = await ensureUserDoc(name);
      final roomRef = await joinRoom(code, userRef, name);
      if (roomRef == null) {
        showErr('Sala no encontrada');
        return '';
      }
      final snap = await roomRef.get();
      FFAppState().update(() {
        FFAppState().currentRoomRef = roomRef;
        FFAppState().currentRoomCode =
            ((snap.data() as Map)['code'] ?? '') as String;
      });
      return 'joined';
    } catch (e) {
      showErr(e);
      return '';
    }
  }
}
