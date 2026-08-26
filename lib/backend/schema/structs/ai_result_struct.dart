// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AiResultStruct extends FFFirebaseStruct {
  AiResultStruct({
    int? score,
    String? guess,
    String? reason,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _score = score,
        _guess = guess,
        _reason = reason,
        super(firestoreUtilData);

  // "score" field.
  int? _score;
  int get score => _score ?? 0;
  set score(int? val) => _score = val;

  void incrementScore(int amount) => score = score + amount;

  bool hasScore() => _score != null;

  // "guess" field.
  String? _guess;
  String get guess => _guess ?? '';
  set guess(String? val) => _guess = val;

  bool hasGuess() => _guess != null;

  // "reason" field.
  String? _reason;
  String get reason => _reason ?? '';
  set reason(String? val) => _reason = val;

  bool hasReason() => _reason != null;

  static AiResultStruct fromMap(Map<String, dynamic> data) => AiResultStruct(
        score: castToType<int>(data['score']),
        guess: data['guess'] as String?,
        reason: data['reason'] as String?,
      );

  static AiResultStruct? maybeFromMap(dynamic data) =>
      data is Map ? AiResultStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'score': _score,
        'guess': _guess,
        'reason': _reason,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'score': serializeParam(
          _score,
          ParamType.int,
        ),
        'guess': serializeParam(
          _guess,
          ParamType.String,
        ),
        'reason': serializeParam(
          _reason,
          ParamType.String,
        ),
      }.withoutNulls;

  static AiResultStruct fromSerializableMap(Map<String, dynamic> data) =>
      AiResultStruct(
        score: deserializeParam(
          data['score'],
          ParamType.int,
          false,
        ),
        guess: deserializeParam(
          data['guess'],
          ParamType.String,
          false,
        ),
        reason: deserializeParam(
          data['reason'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'AiResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AiResultStruct &&
        score == other.score &&
        guess == other.guess &&
        reason == other.reason;
  }

  @override
  int get hashCode => const ListEquality().hash([score, guess, reason]);
}

AiResultStruct createAiResultStruct({
  int? score,
  String? guess,
  String? reason,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    AiResultStruct(
      score: score,
      guess: guess,
      reason: reason,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

AiResultStruct? updateAiResultStruct(
  AiResultStruct? aiResult, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    aiResult
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addAiResultStructData(
  Map<String, dynamic> firestoreData,
  AiResultStruct? aiResult,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (aiResult == null) {
    return;
  }
  if (aiResult.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && aiResult.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final aiResultData = getAiResultFirestoreData(aiResult, forFieldValue);
  final nestedData = aiResultData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = aiResult.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getAiResultFirestoreData(
  AiResultStruct? aiResult, [
  bool forFieldValue = false,
]) {
  if (aiResult == null) {
    return {};
  }
  final firestoreData = mapToFirestore(aiResult.toMap());

  // Add any Firestore field values
  mapToFirestore(aiResult.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getAiResultListFirestoreData(
  List<AiResultStruct>? aiResults,
) =>
    aiResults?.map((e) => getAiResultFirestoreData(e, true)).toList() ?? [];
