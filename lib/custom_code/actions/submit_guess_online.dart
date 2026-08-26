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

  final userSnap = await userRef.get();
  final displayName =
      ((userSnap.data() as Map?)?['display_name'] ?? 'Jugador') as String;

  await roomRef.collection('guesses').add({
    'userRef': userRef,
    'displayName': displayName,
    'text': text,
    'isCorrect': correct,
    'round': data['currentRound'] ?? 0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  if (correct) {
    final pq = await roomRef
        .collection('players')
        .where('userRef', isEqualTo: userRef)
        .limit(1)
        .get();
    if (pq.docs.isNotEmpty) {
      final p = pq.docs.first;
      final already = (p.data() as Map)['hasGuessedCorrect'] == true;
      if (!already) {
        await p.reference.update({
          'score': ((p.data() as Map)['score'] ?? 0) + 100,
          'hasGuessedCorrect': true,
        });
      }
    }
  }
  return correct;
}
