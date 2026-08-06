import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RoomsRecord extends FirestoreRecord {
  RoomsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "code" field.
  String? _code;
  String get code => _code ?? '';
  bool hasCode() => _code != null;

  // "mode" field.
  String? _mode;
  String get mode => _mode ?? '';
  bool hasMode() => _mode != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "hostRef" field.
  DocumentReference? _hostRef;
  DocumentReference? get hostRef => _hostRef;
  bool hasHostRef() => _hostRef != null;

  // "currentDrawerRef" field.
  DocumentReference? _currentDrawerRef;
  DocumentReference? get currentDrawerRef => _currentDrawerRef;
  bool hasCurrentDrawerRef() => _currentDrawerRef != null;

  // "currentWord" field.
  String? _currentWord;
  String get currentWord => _currentWord ?? '';
  bool hasCurrentWord() => _currentWord != null;

  // "wordOptions" field.
  List<String>? _wordOptions;
  List<String> get wordOptions => _wordOptions ?? const [];
  bool hasWordOptions() => _wordOptions != null;

  // "currentRound" field.
  int? _currentRound;
  int get currentRound => _currentRound ?? 0;
  bool hasCurrentRound() => _currentRound != null;

  // "totalRounds" field.
  int? _totalRounds;
  int get totalRounds => _totalRounds ?? 0;
  bool hasTotalRounds() => _totalRounds != null;

  // "roundEndsAt" field.
  DateTime? _roundEndsAt;
  DateTime? get roundEndsAt => _roundEndsAt;
  bool hasRoundEndsAt() => _roundEndsAt != null;

  // "snapshotUrl" field.
  String? _snapshotUrl;
  String get snapshotUrl => _snapshotUrl ?? '';
  bool hasSnapshotUrl() => _snapshotUrl != null;

  // "aiGuess" field.
  String? _aiGuess;
  String get aiGuess => _aiGuess ?? '';
  bool hasAiGuess() => _aiGuess != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _code = snapshotData['code'] as String?;
    _mode = snapshotData['mode'] as String?;
    _status = snapshotData['status'] as String?;
    _hostRef = snapshotData['hostRef'] as DocumentReference?;
    _currentDrawerRef = snapshotData['currentDrawerRef'] as DocumentReference?;
    _currentWord = snapshotData['currentWord'] as String?;
    _wordOptions = getDataList(snapshotData['wordOptions']);
    _currentRound = castToType<int>(snapshotData['currentRound']);
    _totalRounds = castToType<int>(snapshotData['totalRounds']);
    _roundEndsAt = snapshotData['roundEndsAt'] as DateTime?;
    _snapshotUrl = snapshotData['snapshotUrl'] as String?;
    _aiGuess = snapshotData['aiGuess'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rooms');

  static Stream<RoomsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RoomsRecord.fromSnapshot(s));

  static Future<RoomsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RoomsRecord.fromSnapshot(s));

  static RoomsRecord fromSnapshot(DocumentSnapshot snapshot) => RoomsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RoomsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RoomsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RoomsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RoomsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRoomsRecordData({
  String? code,
  String? mode,
  String? status,
  DocumentReference? hostRef,
  DocumentReference? currentDrawerRef,
  String? currentWord,
  int? currentRound,
  int? totalRounds,
  DateTime? roundEndsAt,
  String? snapshotUrl,
  String? aiGuess,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'code': code,
      'mode': mode,
      'status': status,
      'hostRef': hostRef,
      'currentDrawerRef': currentDrawerRef,
      'currentWord': currentWord,
      'currentRound': currentRound,
      'totalRounds': totalRounds,
      'roundEndsAt': roundEndsAt,
      'snapshotUrl': snapshotUrl,
      'aiGuess': aiGuess,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class RoomsRecordDocumentEquality implements Equality<RoomsRecord> {
  const RoomsRecordDocumentEquality();

  @override
  bool equals(RoomsRecord? e1, RoomsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.code == e2?.code &&
        e1?.mode == e2?.mode &&
        e1?.status == e2?.status &&
        e1?.hostRef == e2?.hostRef &&
        e1?.currentDrawerRef == e2?.currentDrawerRef &&
        e1?.currentWord == e2?.currentWord &&
        listEquality.equals(e1?.wordOptions, e2?.wordOptions) &&
        e1?.currentRound == e2?.currentRound &&
        e1?.totalRounds == e2?.totalRounds &&
        e1?.roundEndsAt == e2?.roundEndsAt &&
        e1?.snapshotUrl == e2?.snapshotUrl &&
        e1?.aiGuess == e2?.aiGuess &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(RoomsRecord? e) => const ListEquality().hash([
        e?.code,
        e?.mode,
        e?.status,
        e?.hostRef,
        e?.currentDrawerRef,
        e?.currentWord,
        e?.wordOptions,
        e?.currentRound,
        e?.totalRounds,
        e?.roundEndsAt,
        e?.snapshotUrl,
        e?.aiGuess,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is RoomsRecord;
}
