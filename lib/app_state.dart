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

  List<PlaceStructStruct> _places = [];
  List<PlaceStructStruct> get places => _places;
  set places(List<PlaceStructStruct> value) {
    _places = value;
  }

  void addToPlaces(PlaceStructStruct value) {
    places.add(value);
  }

  void removeFromPlaces(PlaceStructStruct value) {
    places.remove(value);
  }

  void removeAtIndexFromPlaces(int index) {
    places.removeAt(index);
  }

  void updatePlacesAtIndex(
    int index,
    PlaceStructStruct Function(PlaceStructStruct) updateFn,
  ) {
    places[index] = updateFn(_places[index]);
  }

  void insertAtIndexInPlaces(int index, PlaceStructStruct value) {
    places.insert(index, value);
  }

  List<AbilityStructStruct> _Abilities = [];
  List<AbilityStructStruct> get Abilities => _Abilities;
  set Abilities(List<AbilityStructStruct> value) {
    _Abilities = value;
  }

  void addToAbilities(AbilityStructStruct value) {
    Abilities.add(value);
  }

  void removeFromAbilities(AbilityStructStruct value) {
    Abilities.remove(value);
  }

  void removeAtIndexFromAbilities(int index) {
    Abilities.removeAt(index);
  }

  void updateAbilitiesAtIndex(
    int index,
    AbilityStructStruct Function(AbilityStructStruct) updateFn,
  ) {
    Abilities[index] = updateFn(_Abilities[index]);
  }

  void insertAtIndexInAbilities(int index, AbilityStructStruct value) {
    Abilities.insert(index, value);
  }

  List<EmotionStructStruct> _emotions = [];
  List<EmotionStructStruct> get emotions => _emotions;
  set emotions(List<EmotionStructStruct> value) {
    _emotions = value;
  }

  void addToEmotions(EmotionStructStruct value) {
    emotions.add(value);
  }

  void removeFromEmotions(EmotionStructStruct value) {
    emotions.remove(value);
  }

  void removeAtIndexFromEmotions(int index) {
    emotions.removeAt(index);
  }

  void updateEmotionsAtIndex(
    int index,
    EmotionStructStruct Function(EmotionStructStruct) updateFn,
  ) {
    emotions[index] = updateFn(_emotions[index]);
  }

  void insertAtIndexInEmotions(int index, EmotionStructStruct value) {
    emotions.insert(index, value);
  }

  bool _isAIGenerating = false;
  bool get isAIGenerating => _isAIGenerating;
  set isAIGenerating(bool value) {
    _isAIGenerating = value;
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
