// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

Future startRoundOnline(DocumentReference roomRef) async {
  final db = FirebaseFirestore.instance;
  const bank = [
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
  final word = bank[Random().nextInt(bank.length)];

  final players = await roomRef.collection('players').orderBy('joinedAt').get();
  if (players.docs.isEmpty) return;
  final ids =
      players.docs.map((d) => d['userRef'] as DocumentReference).toList();

  final room = await roomRef.get();
  final data = (room.data() as Map<String, dynamic>?) ?? {};
  final currentDrawer = data['currentDrawerRef'] as DocumentReference?;
  final status = data['status'] as String?;
  final currentRound = (data['currentRound'] ?? 0) as int;

  int idx = 0;
  int nextRound = 1;
  if (currentDrawer != null && status != 'lobby') {
    final pos = ids.indexWhere((r) => r.id == currentDrawer.id);
    idx = (pos + 1) % ids.length;
    nextRound = idx == 0 ? currentRound + 1 : currentRound;
  }

  // limpiar trazos
  final sSnap = await roomRef.collection('strokes').get();
  final b1 = db.batch();
  for (final d in sSnap.docs) {
    b1.delete(d.reference);
  }
  await b1.commit();

  // limpiar respuestas
  final gSnap = await roomRef.collection('guesses').get();
  final b2 = db.batch();
  for (final d in gSnap.docs) {
    b2.delete(d.reference);
  }
  await b2.commit();

  // reiniciar aciertos
  final b3 = db.batch();
  for (final p in players.docs) {
    b3.update(p.reference, {'hasGuessedCorrect': false});
  }
  await b3.commit();

  await roomRef.update({
    'status': 'drawing',
    'currentDrawerRef': ids[idx],
    'currentWord': word,
    'currentRound': nextRound,
  });
}
