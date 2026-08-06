// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LocalPlayerStruct extends FFFirebaseStruct {
  LocalPlayerStruct({
    String? name,
    int? score,
    String? team,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _score = score,
        _team = team,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "score" field.
  int? _score;
  int get score => _score ?? 0;
  set score(int? val) => _score = val;

  void incrementScore(int amount) => score = score + amount;

  bool hasScore() => _score != null;

  // "team" field.
  String? _team;
  String get team => _team ?? '';
  set team(String? val) => _team = val;

  bool hasTeam() => _team != null;

  static LocalPlayerStruct fromMap(Map<String, dynamic> data) =>
      LocalPlayerStruct(
        name: data['name'] as String?,
        score: castToType<int>(data['score']),
        team: data['team'] as String?,
      );

  static LocalPlayerStruct? maybeFromMap(dynamic data) => data is Map
      ? LocalPlayerStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'score': _score,
        'team': _team,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'score': serializeParam(
          _score,
          ParamType.int,
        ),
        'team': serializeParam(
          _team,
          ParamType.String,
        ),
      }.withoutNulls;

  static LocalPlayerStruct fromSerializableMap(Map<String, dynamic> data) =>
      LocalPlayerStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        score: deserializeParam(
          data['score'],
          ParamType.int,
          false,
        ),
        team: deserializeParam(
          data['team'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'LocalPlayerStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is LocalPlayerStruct &&
        name == other.name &&
        score == other.score &&
        team == other.team;
  }

  @override
  int get hashCode => const ListEquality().hash([name, score, team]);
}

LocalPlayerStruct createLocalPlayerStruct({
  String? name,
  int? score,
  String? team,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    LocalPlayerStruct(
      name: name,
      score: score,
      team: team,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

LocalPlayerStruct? updateLocalPlayerStruct(
  LocalPlayerStruct? localPlayer, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    localPlayer
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addLocalPlayerStructData(
  Map<String, dynamic> firestoreData,
  LocalPlayerStruct? localPlayer,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (localPlayer == null) {
    return;
  }
  if (localPlayer.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && localPlayer.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final localPlayerData =
      getLocalPlayerFirestoreData(localPlayer, forFieldValue);
  final nestedData =
      localPlayerData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = localPlayer.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getLocalPlayerFirestoreData(
  LocalPlayerStruct? localPlayer, [
  bool forFieldValue = false,
]) {
  if (localPlayer == null) {
    return {};
  }
  final firestoreData = mapToFirestore(localPlayer.toMap());

  // Add any Firestore field values
  mapToFirestore(localPlayer.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getLocalPlayerListFirestoreData(
  List<LocalPlayerStruct>? localPlayers,
) =>
    localPlayers?.map((e) => getLocalPlayerFirestoreData(e, true)).toList() ??
    [];
