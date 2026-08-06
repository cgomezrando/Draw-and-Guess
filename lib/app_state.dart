import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _currentRoomCode = '';
  String get currentRoomCode => _currentRoomCode;
  set currentRoomCode(String value) {
    _currentRoomCode = value;
  }

  bool _isDrawer = false;
  bool get isDrawer => _isDrawer;
  set isDrawer(bool value) {
    _isDrawer = value;
  }

  String _selectedMode = '';
  String get selectedMode => _selectedMode;
  set selectedMode(String value) {
    _selectedMode = value;
  }

  Color _penColor = Color(4278190080);
  Color get penColor => _penColor;
  set penColor(Color value) {
    _penColor = value;
  }

  double _penWidth = 0.0;
  double get penWidth => _penWidth;
  set penWidth(double value) {
    _penWidth = value;
  }

  DocumentReference? _currentRoomRef;
  DocumentReference? get currentRoomRef => _currentRoomRef;
  set currentRoomRef(DocumentReference? value) {
    _currentRoomRef = value;
  }

  List<LocalPlayerStruct> _localPlayers = [];
  List<LocalPlayerStruct> get localPlayers => _localPlayers;
  set localPlayers(List<LocalPlayerStruct> value) {
    _localPlayers = value;
  }

  void addToLocalPlayers(LocalPlayerStruct value) {
    localPlayers.add(value);
  }

  void removeFromLocalPlayers(LocalPlayerStruct value) {
    localPlayers.remove(value);
  }

  void removeAtIndexFromLocalPlayers(int index) {
    localPlayers.removeAt(index);
  }

  void updateLocalPlayersAtIndex(
    int index,
    LocalPlayerStruct Function(LocalPlayerStruct) updateFn,
  ) {
    localPlayers[index] = updateFn(_localPlayers[index]);
  }

  void insertAtIndexInLocalPlayers(int index, LocalPlayerStruct value) {
    localPlayers.insert(index, value);
  }

  String _localMode = '';
  String get localMode => _localMode;
  set localMode(String value) {
    _localMode = value;
  }

  int _localRound = 0;
  int get localRound => _localRound;
  set localRound(int value) {
    _localRound = value;
  }

  int _localTotalRounds = 5;
  int get localTotalRounds => _localTotalRounds;
  set localTotalRounds(int value) {
    _localTotalRounds = value;
  }

  int _localDrawerIndex = 0;
  int get localDrawerIndex => _localDrawerIndex;
  set localDrawerIndex(int value) {
    _localDrawerIndex = value;
  }

  String _localWord = '';
  String get localWord => _localWord;
  set localWord(String value) {
    _localWord = value;
  }
}

Color? _colorFromIntValue(int? val) {
  if (val == null) {
    return null;
  }
  return Color(val);
}
