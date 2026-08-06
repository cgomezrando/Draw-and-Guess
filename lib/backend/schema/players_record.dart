import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PlayersRecord extends FirestoreRecord {
  PlayersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "displayName" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "score" field.
  int? _score;
  int get score => _score ?? 0;
  bool hasScore() => _score != null;

  // "team" field.
  String? _team;
  String get team => _team ?? '';
  bool hasTeam() => _team != null;

  // "isReady" field.
  bool? _isReady;
  bool get isReady => _isReady ?? false;
  bool hasIsReady() => _isReady != null;

  // "hasGuessedCorrect" field.
  bool? _hasGuessedCorrect;
  bool get hasGuessedCorrect => _hasGuessedCorrect ?? false;
  bool hasHasGuessedCorrect() => _hasGuessedCorrect != null;

  // "joinedAt" field.
  DateTime? _joinedAt;
  DateTime? get joinedAt => _joinedAt;
  bool hasJoinedAt() => _joinedAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _displayName = snapshotData['displayName'] as String?;
    _score = castToType<int>(snapshotData['score']);
    _team = snapshotData['team'] as String?;
    _isReady = snapshotData['isReady'] as bool?;
    _hasGuessedCorrect = snapshotData['hasGuessedCorrect'] as bool?;
    _joinedAt = snapshotData['joinedAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('players')
          : FirebaseFirestore.instance.collectionGroup('players');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('players').doc(id);

  static Stream<PlayersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PlayersRecord.fromSnapshot(s));

  static Future<PlayersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PlayersRecord.fromSnapshot(s));

  static PlayersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PlayersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PlayersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PlayersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PlayersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PlayersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPlayersRecordData({
  DocumentReference? userRef,
  String? displayName,
  int? score,
  String? team,
  bool? isReady,
  bool? hasGuessedCorrect,
  DateTime? joinedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userRef': userRef,
      'displayName': displayName,
      'score': score,
      'team': team,
      'isReady': isReady,
      'hasGuessedCorrect': hasGuessedCorrect,
      'joinedAt': joinedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PlayersRecordDocumentEquality implements Equality<PlayersRecord> {
  const PlayersRecordDocumentEquality();

  @override
  bool equals(PlayersRecord? e1, PlayersRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.displayName == e2?.displayName &&
        e1?.score == e2?.score &&
        e1?.team == e2?.team &&
        e1?.isReady == e2?.isReady &&
        e1?.hasGuessedCorrect == e2?.hasGuessedCorrect &&
        e1?.joinedAt == e2?.joinedAt;
  }

  @override
  int hash(PlayersRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.displayName,
        e?.score,
        e?.team,
        e?.isReady,
        e?.hasGuessedCorrect,
        e?.joinedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is PlayersRecord;
}
