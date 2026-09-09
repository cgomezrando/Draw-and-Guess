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
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> submitGuessOnline(DocumentReference roomRef, String text) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

  final room = await roomRef.get();
  final data = (room.data() as Map<String, dynamic>?) ?? {};
  final secret = (data['currentWord'] ?? '') as String;

  String norm(String s) {
    s = s.toLowerCase().trim();
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    return s.replaceAll(RegExp(r'\s+'), ' ');
  }

  final correct = secret.isNotEmpty && norm(text) == norm(secret);

  // Nombre correcto desde la subcolección players (no desde el user doc,
  // cuyos campos van en snake_case y no coinciden).
  final pq = await roomRef
      .collection('players')
      .where('userRef', isEqualTo: userRef)
      .limit(1)
      .get();
  String displayName = 'Jugador';
  DocumentReference? playerRef;
  Map<String, dynamic>? pdata;
  if (pq.docs.isNotEmpty) {
    playerRef = pq.docs.first.reference;
    pdata = pq.docs.first.data() as Map<String, dynamic>;
    displayName = (pdata['displayName'] ?? 'Jugador').toString();
  }

  await roomRef.collection('guesses').add({
    'userRef': userRef,
    'displayName': displayName,
    'text': text,
    'isCorrect': correct,
    'round': data['currentRound'] ?? 0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  if (correct && playerRef != null) {
    final already = pdata?['hasGuessedCorrect'] == true;
    if (already != true) {
      await playerRef.update({
        'score': ((pdata?['score'] ?? 0) as num).toInt() + 100,
        'hasGuessedCorrect': true,
      });
    }
  }
  return correct;
}
