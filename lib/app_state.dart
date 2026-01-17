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
      _availableAiModels =
          prefs.getStringList('ff_availableAiModels') ?? _availableAiModels;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<String> _availableAiModels = [
    'gpt-4o',
    'claude-3-sonnet-20240229',
    'claude-3-haiku-20240307',
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemma-2-9b-instruct',
    'llama3-70b-8192'
  ];
  List<String> get availableAiModels => _availableAiModels;
  set availableAiModels(List<String> value) {
    _availableAiModels = value;
    prefs.setStringList('ff_availableAiModels', value);
  }

  void addToAvailableAiModels(String value) {
    availableAiModels.add(value);
    prefs.setStringList('ff_availableAiModels', _availableAiModels);
  }

  void removeFromAvailableAiModels(String value) {
    availableAiModels.remove(value);
    prefs.setStringList('ff_availableAiModels', _availableAiModels);
  }

  void removeAtIndexFromAvailableAiModels(int index) {
    availableAiModels.removeAt(index);
    prefs.setStringList('ff_availableAiModels', _availableAiModels);
  }

  void updateAvailableAiModelsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    availableAiModels[index] = updateFn(_availableAiModels[index]);
    prefs.setStringList('ff_availableAiModels', _availableAiModels);
  }

  void insertAtIndexInAvailableAiModels(int index, String value) {
    availableAiModels.insert(index, value);
    prefs.setStringList('ff_availableAiModels', _availableAiModels);
  }

  String _tempEnglishPrompt = '';
  String get tempEnglishPrompt => _tempEnglishPrompt;
  set tempEnglishPrompt(String value) {
    _tempEnglishPrompt = value;
  }

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
