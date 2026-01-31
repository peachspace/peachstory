import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _aimodel = prefs.getString('ff_aimodel') ?? _aimodel;
    });
    _safeInit(() {
      _draftId = prefs.getString('ff_draftId') ?? _draftId;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<CharacterStructStruct> _Characters = [];
  List<CharacterStructStruct> get Characters => _Characters;
  set Characters(List<CharacterStructStruct> value) {
    _Characters = value;
  }

  void addToCharacters(CharacterStructStruct value) {
    Characters.add(value);
  }

  void removeFromCharacters(CharacterStructStruct value) {
    Characters.remove(value);
  }

  void removeAtIndexFromCharacters(int index) {
    Characters.removeAt(index);
  }

  void updateCharactersAtIndex(
    int index,
    CharacterStructStruct Function(CharacterStructStruct) updateFn,
  ) {
    Characters[index] = updateFn(_Characters[index]);
  }

  void insertAtIndexInCharacters(int index, CharacterStructStruct value) {
    Characters.insert(index, value);
  }

  String _aimodel = '';
  String get aimodel => _aimodel;
  set aimodel(String value) {
    _aimodel = value;
    prefs.setString('ff_aimodel', value);
  }

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;
  set isGenerating(bool value) {
    _isGenerating = value;
  }

  String _generatingTarget = '';
  String get generatingTarget => _generatingTarget;
  set generatingTarget(String value) {
    _generatingTarget = value;
  }

  String _draftId = '';
  String get draftId => _draftId;
  set draftId(String value) {
    _draftId = value;
    prefs.setString('ff_draftId', value);
  }

  String _poseImageUrl = '';
  String get poseImageUrl => _poseImageUrl;
  set poseImageUrl(String value) {
    _poseImageUrl = value;
  }

  String _storyCurrentTime = '';
  String get storyCurrentTime => _storyCurrentTime;
  set storyCurrentTime(String value) {
    _storyCurrentTime = value;
  }

  String _storyCurrentPlace = '\" \"';
  String get storyCurrentPlace => _storyCurrentPlace;
  set storyCurrentPlace(String value) {
    _storyCurrentPlace = value;
  }

  String _storyLastBgShownPlace = '\" \"';
  String get storyLastBgShownPlace => _storyLastBgShownPlace;
  set storyLastBgShownPlace(String value) {
    _storyLastBgShownPlace = value;
  }

  String _storyUserName = '';
  String get storyUserName => _storyUserName;
  set storyUserName(String value) {
    _storyUserName = value;
  }

  String _storyMode = '';
  String get storyMode => _storyMode;
  set storyMode(String value) {
    _storyMode = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
