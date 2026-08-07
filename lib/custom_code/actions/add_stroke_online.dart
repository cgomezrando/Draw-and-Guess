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

Future addStrokeOnline(DocumentReference roomRef, String strokeJson) async {
  await roomRef.collection('strokes').add({
    'data': strokeJson,
    'order': DateTime.now().millisecondsSinceEpoch,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
