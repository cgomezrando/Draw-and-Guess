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

Future<DocumentReference> createRoom(
  String mode,
  DocumentReference hostRef,
  String displayName,
) async {
  final db = FirebaseFirestore.instance;
  final code = await generateRoomCode(); // reutiliza la action anterior

  final roomRef = await db.collection('rooms').add({
    'code': code,
    'mode': mode,
    'status': 'lobby',
    'hostRef': hostRef,
    'currentDrawerRef': null,
    'currentWord': '',
    'wordOptions': <String>[],
    'currentRound': 0,
    'totalRounds': 5,
    'roundEndsAt': null,
    'snapshotUrl': '',
    'aiGuess': '',
    'createdAt': FieldValue.serverTimestamp(),
  });

  // El host entra como primer jugador
  await roomRef.collection('players').add({
    'userRef': hostRef,
    'displayName': displayName,
    'score': 0,
    'team': 'A',
    'isReady': true,
    'hasGuessedCorrect': false,
    'joinedAt': FieldValue.serverTimestamp(),
  });

  return roomRef;
}
