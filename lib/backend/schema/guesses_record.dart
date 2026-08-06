import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GuessesRecord extends FirestoreRecord {
  GuessesRecord._(
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

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "isCorrect" field.
  bool? _isCorrect;
  bool get isCorrect => _isCorrect ?? false;
  bool hasIsCorrect() => _isCorrect != null;

  // "round" field.
  int? _round;
  int get round => _round ?? 0;
  bool hasRound() => _round != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _displayName = snapshotData['displayName'] as String?;
    _text = snapshotData['text'] as String?;
    _isCorrect = snapshotData['isCorrect'] as bool?;
    _round = castToType<int>(snapshotData['round']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('guesses')
          : FirebaseFirestore.instance.collectionGroup('guesses');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('guesses').doc(id);

  static Stream<GuessesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GuessesRecord.fromSnapshot(s));

  static Future<GuessesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GuessesRecord.fromSnapshot(s));

  static GuessesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      GuessesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GuessesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GuessesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GuessesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GuessesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGuessesRecordData({
  DocumentReference? userRef,
  String? displayName,
  String? text,
  bool? isCorrect,
  int? round,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userRef': userRef,
      'displayName': displayName,
      'text': text,
      'isCorrect': isCorrect,
      'round': round,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class GuessesRecordDocumentEquality implements Equality<GuessesRecord> {
  const GuessesRecordDocumentEquality();

  @override
  bool equals(GuessesRecord? e1, GuessesRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.displayName == e2?.displayName &&
        e1?.text == e2?.text &&
        e1?.isCorrect == e2?.isCorrect &&
        e1?.round == e2?.round &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(GuessesRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.displayName,
        e?.text,
        e?.isCorrect,
        e?.round,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is GuessesRecord;
}
