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

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _chathistory = prefs
              .getStringList('ff_chathistory')
              ?.map((x) {
                try {
                  return ChatMessageStructStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _chathistory;
    });
    _safeInit(() {
      _availableAiModels =
          prefs.getStringList('ff_availableAiModels') ?? _availableAiModels;
    });
    _safeInit(() {
      _cachedMyCreations = prefs
              .getStringList('ff_cachedMyCreations')
              ?.map((x) {
                try {
                  return CombinedListItemStructStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _cachedMyCreations;
    });
    _safeInit(() {
      _cachedMyChats = prefs
              .getStringList('ff_cachedMyChats')
              ?.map((x) {
                try {
                  return CombinedListItemStructStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _cachedMyChats;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<ChatMessageStructStruct> _chathistory = [];
  List<ChatMessageStructStruct> get chathistory => _chathistory;
  set chathistory(List<ChatMessageStructStruct> value) {
    _chathistory = value;
    prefs.setStringList(
        'ff_chathistory', value.map((x) => x.serialize()).toList());
  }

  void addToChathistory(ChatMessageStructStruct value) {
    chathistory.add(value);
    prefs.setStringList(
        'ff_chathistory', _chathistory.map((x) => x.serialize()).toList());
  }

  void removeFromChathistory(ChatMessageStructStruct value) {
    chathistory.remove(value);
    prefs.setStringList(
        'ff_chathistory', _chathistory.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromChathistory(int index) {
    chathistory.removeAt(index);
    prefs.setStringList(
        'ff_chathistory', _chathistory.map((x) => x.serialize()).toList());
  }

  void updateChathistoryAtIndex(
    int index,
    ChatMessageStructStruct Function(ChatMessageStructStruct) updateFn,
  ) {
    chathistory[index] = updateFn(_chathistory[index]);
    prefs.setStringList(
        'ff_chathistory', _chathistory.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInChathistory(int index, ChatMessageStructStruct value) {
    chathistory.insert(index, value);
    prefs.setStringList(
        'ff_chathistory', _chathistory.map((x) => x.serialize()).toList());
  }

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

  List<CombinedListItemStructStruct> _cachedMyCreations = [];
  List<CombinedListItemStructStruct> get cachedMyCreations =>
      _cachedMyCreations;
  set cachedMyCreations(List<CombinedListItemStructStruct> value) {
    _cachedMyCreations = value;
    prefs.setStringList(
        'ff_cachedMyCreations', value.map((x) => x.serialize()).toList());
  }

  void addToCachedMyCreations(CombinedListItemStructStruct value) {
    cachedMyCreations.add(value);
    prefs.setStringList('ff_cachedMyCreations',
        _cachedMyCreations.map((x) => x.serialize()).toList());
  }

  void removeFromCachedMyCreations(CombinedListItemStructStruct value) {
    cachedMyCreations.remove(value);
    prefs.setStringList('ff_cachedMyCreations',
        _cachedMyCreations.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromCachedMyCreations(int index) {
    cachedMyCreations.removeAt(index);
    prefs.setStringList('ff_cachedMyCreations',
        _cachedMyCreations.map((x) => x.serialize()).toList());
  }

  void updateCachedMyCreationsAtIndex(
    int index,
    CombinedListItemStructStruct Function(CombinedListItemStructStruct)
        updateFn,
  ) {
    cachedMyCreations[index] = updateFn(_cachedMyCreations[index]);
    prefs.setStringList('ff_cachedMyCreations',
        _cachedMyCreations.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInCachedMyCreations(
      int index, CombinedListItemStructStruct value) {
    cachedMyCreations.insert(index, value);
    prefs.setStringList('ff_cachedMyCreations',
        _cachedMyCreations.map((x) => x.serialize()).toList());
  }

  List<CombinedListItemStructStruct> _cachedMyChats = [];
  List<CombinedListItemStructStruct> get cachedMyChats => _cachedMyChats;
  set cachedMyChats(List<CombinedListItemStructStruct> value) {
    _cachedMyChats = value;
    prefs.setStringList(
        'ff_cachedMyChats', value.map((x) => x.serialize()).toList());
  }

  void addToCachedMyChats(CombinedListItemStructStruct value) {
    cachedMyChats.add(value);
    prefs.setStringList(
        'ff_cachedMyChats', _cachedMyChats.map((x) => x.serialize()).toList());
  }

  void removeFromCachedMyChats(CombinedListItemStructStruct value) {
    cachedMyChats.remove(value);
    prefs.setStringList(
        'ff_cachedMyChats', _cachedMyChats.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromCachedMyChats(int index) {
    cachedMyChats.removeAt(index);
    prefs.setStringList(
        'ff_cachedMyChats', _cachedMyChats.map((x) => x.serialize()).toList());
  }

  void updateCachedMyChatsAtIndex(
    int index,
    CombinedListItemStructStruct Function(CombinedListItemStructStruct)
        updateFn,
  ) {
    cachedMyChats[index] = updateFn(_cachedMyChats[index]);
    prefs.setStringList(
        'ff_cachedMyChats', _cachedMyChats.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInCachedMyChats(
      int index, CombinedListItemStructStruct value) {
    cachedMyChats.insert(index, value);
    prefs.setStringList(
        'ff_cachedMyChats', _cachedMyChats.map((x) => x.serialize()).toList());
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
