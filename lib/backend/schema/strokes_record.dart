import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StrokesRecord extends FirestoreRecord {
  StrokesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "points" field.
  String? _points;
  String get points => _points ?? '';
  bool hasPoints() => _points != null;

  // "color" field.
  String? _color;
  String get color => _color ?? '';
  bool hasColor() => _color != null;

  // "width" field.
  double? _width;
  double get width => _width ?? 0.0;
  bool hasWidth() => _width != null;

  // "order" field.
  int? _order;
  int get order => _order ?? 0;
  bool hasOrder() => _order != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _points = snapshotData['points'] as String?;
    _color = snapshotData['color'] as String?;
    _width = castToType<double>(snapshotData['width']);
    _order = castToType<int>(snapshotData['order']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('strokes')
          : FirebaseFirestore.instance.collectionGroup('strokes');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('strokes').doc(id);

  static Stream<StrokesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StrokesRecord.fromSnapshot(s));

  static Future<StrokesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StrokesRecord.fromSnapshot(s));

  static StrokesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StrokesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StrokesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StrokesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StrokesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StrokesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStrokesRecordData({
  String? points,
  String? color,
  double? width,
  int? order,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'points': points,
      'color': color,
      'width': width,
      'order': order,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class StrokesRecordDocumentEquality implements Equality<StrokesRecord> {
  const StrokesRecordDocumentEquality();

  @override
  bool equals(StrokesRecord? e1, StrokesRecord? e2) {
    return e1?.points == e2?.points &&
        e1?.color == e2?.color &&
        e1?.width == e2?.width &&
        e1?.order == e2?.order &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(StrokesRecord? e) => const ListEquality()
      .hash([e?.points, e?.color, e?.width, e?.order, e?.createdAt]);

  @override
  bool isValidKey(Object? o) => o is StrokesRecord;
}
