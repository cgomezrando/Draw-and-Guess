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

import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentReference?> joinRoom(
  String code,
  DocumentReference userRef,
  String displayName,
) async {
  final db = FirebaseFirestore.instance;
  final q = await db
      .collection('rooms')
      .where('code', isEqualTo: code.toUpperCase())
      .where('status', isEqualTo: 'lobby')
      .limit(1)
      .get();
  if (q.docs.isEmpty) return null;

  final roomRef = q.docs.first.reference;

  // ¿Ya estaba dentro este usuario?
  final existing = await roomRef
      .collection('players')
      .where('userRef', isEqualTo: userRef)
      .limit(1)
      .get();
  if (existing.docs.isNotEmpty) return roomRef;

  // En parejas: asigna equipo B al segundo; en multi, todos "A"
  final playersSnap = await roomRef.collection('players').get();
  final team = playersSnap.docs.length.isEven ? 'A' : 'B';

  await roomRef.collection('players').add({
    'userRef': userRef,
    'displayName': displayName,
    'score': 0,
    'team': team,
    'isReady': false,
    'hasGuessedCorrect': false,
    'joinedAt': FieldValue.serverTimestamp(),
  });

  return roomRef;
}
