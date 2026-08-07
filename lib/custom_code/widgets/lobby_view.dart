// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/app_state.dart';
import '/custom_code/actions/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LobbyView extends StatefulWidget {
  const LobbyView({super.key, this.width, this.height, this.onStart});

  final double? width;
  final double? height;
  final Future Function()? onStart;

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF19C08B);
    const navy = Color(0xFF203A5C);
    const ink = Color(0xFF213047);

    final roomRef = FFAppState().currentRoomRef;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (roomRef == null) {
      return const Center(child: Text('No hay sala activa'));
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFFF7F4EF),
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<DocumentSnapshot>(
        stream: roomRef.snapshots(),
        builder: (context, roomSnap) {
          final room = roomSnap.data?.data() as Map<String, dynamic>?;
          final code = (room?['code'] ?? FFAppState().currentRoomCode) ?? '';
          final hostRef = room?['hostRef'] as DocumentReference?;
          final isHost = hostRef != null && hostRef.id == uid;
          final status = room?['status'] as String?;

          if (status == 'drawing' && !_navigated && widget.onStart != null) {
            _navigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await widget.onStart!();
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Código de la sala',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: ink)),
              const SizedBox(height: 6),
              Text('$code',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: navy,
                      letterSpacing: 8)),
              const SizedBox(height: 4),
              Text('Compártelo para que se unan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              Text('Jugadores',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: navy)),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: roomRef
                      .collection('players')
                      .orderBy('joinedAt')
                      .snapshots(),
                  builder: (context, snap) {
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                          child: Text('Esperando jugadores…',
                              style: TextStyle(color: Colors.grey.shade600)));
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final p = docs[i].data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            leading: const Icon(Icons.person, color: green),
                            title: Text('${p['displayName'] ?? '—'}',
                                style: TextStyle(color: ink)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (isHost)
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      await startRoundOnline(roomRef);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Empezar partida',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Text('Esperando a que el anfitrión empiece…',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600)),
            ],
          );
        },
      ),
    );
  }
}
