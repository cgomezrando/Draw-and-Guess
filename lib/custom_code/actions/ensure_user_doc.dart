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
import 'package:firebase_auth/firebase_auth.dart';

Future<DocumentReference> ensureUserDoc(String displayName) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final ref = FirebaseFirestore.instance.collection('users').doc(uid);
  final snap = await ref.get();
  if (!snap.exists) {
    await ref.set({
      'uid': uid,
      'displayName': displayName,
      'gamesPlayed': 0,
      'totalScore': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } else {
    await ref.update({'displayName': displayName});
  }
  return ref;
}
