// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CharacterStructStruct extends FFFirebaseStruct {
  CharacterStructStruct({
    String? name,
    String? setting,
    String? introduce,
    int? seed,
    String? profileimage,
    List<EmotionStructStruct>? emotionStruct,
    String? basePrompt,
    List<AbilityStructStruct>? abilityStruct,
    String? appearance,
    String? ability,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _setting = setting,
        _introduce = introduce,
        _seed = seed,
        _profileimage = profileimage,
        _emotionStruct = emotionStruct,
        _basePrompt = basePrompt,
        _abilityStruct = abilityStruct,
        _appearance = appearance,
        _ability = ability,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "setting" field.
  String? _setting;
  String get setting => _setting ?? '';
  set setting(String? val) => _setting = val;

  bool hasSetting() => _setting != null;

  // "introduce" field.
  String? _introduce;
  String get introduce => _introduce ?? '';
  set introduce(String? val) => _introduce = val;

  bool hasIntroduce() => _introduce != null;

  // "Seed" field.
  int? _seed;
  int get seed => _seed ?? 0;
  set seed(int? val) => _seed = val;

  void incrementSeed(int amount) => seed = seed + amount;

  bool hasSeed() => _seed != null;

  // "profileimage" field.
  String? _profileimage;
  String get profileimage => _profileimage ?? '';
  set profileimage(String? val) => _profileimage = val;

  bool hasProfileimage() => _profileimage != null;

  // "emotionStruct" field.
  List<EmotionStructStruct>? _emotionStruct;
  List<EmotionStructStruct> get emotionStruct => _emotionStruct ?? const [];
  set emotionStruct(List<EmotionStructStruct>? val) => _emotionStruct = val;

  void updateEmotionStruct(Function(List<EmotionStructStruct>) updateFn) {
    updateFn(_emotionStruct ??= []);
  }

  bool hasEmotionStruct() => _emotionStruct != null;

  // "basePrompt" field.
  String? _basePrompt;
  String get basePrompt => _basePrompt ?? '';
  set basePrompt(String? val) => _basePrompt = val;

  bool hasBasePrompt() => _basePrompt != null;

  // "abilityStruct" field.
  List<AbilityStructStruct>? _abilityStruct;
  List<AbilityStructStruct> get abilityStruct => _abilityStruct ?? const [];
  set abilityStruct(List<AbilityStructStruct>? val) => _abilityStruct = val;

  void updateAbilityStruct(Function(List<AbilityStructStruct>) updateFn) {
    updateFn(_abilityStruct ??= []);
  }

  bool hasAbilityStruct() => _abilityStruct != null;

  // "appearance" field.
  String? _appearance;
  String get appearance => _appearance ?? '';
  set appearance(String? val) => _appearance = val;

  bool hasAppearance() => _appearance != null;

  // "ability" field.
  String? _ability;
  String get ability => _ability ?? '';
  set ability(String? val) => _ability = val;

  bool hasAbility() => _ability != null;

  static CharacterStructStruct fromMap(Map<String, dynamic> data) =>
      CharacterStructStruct(
        name: data['name'] as String?,
        setting: data['setting'] as String?,
        introduce: data['introduce'] as String?,
        seed: castToType<int>(data['Seed']),
        profileimage: data['profileimage'] as String?,
        emotionStruct: getStructList(
          data['emotionStruct'],
          EmotionStructStruct.fromMap,
        ),
        basePrompt: data['basePrompt'] as String?,
        abilityStruct: getStructList(
          data['abilityStruct'],
          AbilityStructStruct.fromMap,
        ),
        appearance: data['appearance'] as String?,
        ability: data['ability'] as String?,
      );

  static CharacterStructStruct? maybeFromMap(dynamic data) => data is Map
      ? CharacterStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'setting': _setting,
        'introduce': _introduce,
        'Seed': _seed,
        'profileimage': _profileimage,
        'emotionStruct': _emotionStruct?.map((e) => e.toMap()).toList(),
        'basePrompt': _basePrompt,
        'abilityStruct': _abilityStruct?.map((e) => e.toMap()).toList(),
        'appearance': _appearance,
        'ability': _ability,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'setting': serializeParam(
          _setting,
          ParamType.String,
        ),
        'introduce': serializeParam(
          _introduce,
          ParamType.String,
        ),
        'Seed': serializeParam(
          _seed,
          ParamType.int,
        ),
        'profileimage': serializeParam(
          _profileimage,
          ParamType.String,
        ),
        'emotionStruct': serializeParam(
          _emotionStruct,
          ParamType.DataStruct,
          isList: true,
        ),
        'basePrompt': serializeParam(
          _basePrompt,
          ParamType.String,
        ),
        'abilityStruct': serializeParam(
          _abilityStruct,
          ParamType.DataStruct,
          isList: true,
        ),
        'appearance': serializeParam(
          _appearance,
          ParamType.String,
        ),
        'ability': serializeParam(
          _ability,
          ParamType.String,
        ),
      }.withoutNulls;

  static CharacterStructStruct fromSerializableMap(Map<String, dynamic> data) =>
      CharacterStructStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        setting: deserializeParam(
          data['setting'],
          ParamType.String,
          false,
        ),
        introduce: deserializeParam(
          data['introduce'],
          ParamType.String,
          false,
        ),
        seed: deserializeParam(
          data['Seed'],
          ParamType.int,
          false,
        ),
        profileimage: deserializeParam(
          data['profileimage'],
          ParamType.String,
          false,
        ),
        emotionStruct: deserializeStructParam<EmotionStructStruct>(
          data['emotionStruct'],
          ParamType.DataStruct,
          true,
          structBuilder: EmotionStructStruct.fromSerializableMap,
        ),
        basePrompt: deserializeParam(
          data['basePrompt'],
          ParamType.String,
          false,
        ),
        abilityStruct: deserializeStructParam<AbilityStructStruct>(
          data['abilityStruct'],
          ParamType.DataStruct,
          true,
          structBuilder: AbilityStructStruct.fromSerializableMap,
        ),
        appearance: deserializeParam(
          data['appearance'],
          ParamType.String,
          false,
        ),
        ability: deserializeParam(
          data['ability'],
          ParamType.String,
          false,
        ),
      );

  static CharacterStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      CharacterStructStruct(
        name: convertAlgoliaParam(
          data['name'],
          ParamType.String,
          false,
        ),
        setting: convertAlgoliaParam(
          data['setting'],
          ParamType.String,
          false,
        ),
        introduce: convertAlgoliaParam(
          data['introduce'],
          ParamType.String,
          false,
        ),
        seed: convertAlgoliaParam(
          data['Seed'],
          ParamType.int,
          false,
        ),
        profileimage: convertAlgoliaParam(
          data['profileimage'],
          ParamType.String,
          false,
        ),
        emotionStruct: convertAlgoliaParam<EmotionStructStruct>(
          data['emotionStruct'],
          ParamType.DataStruct,
          true,
          structBuilder: EmotionStructStruct.fromAlgoliaData,
        ),
        basePrompt: convertAlgoliaParam(
          data['basePrompt'],
          ParamType.String,
          false,
        ),
        abilityStruct: convertAlgoliaParam<AbilityStructStruct>(
          data['abilityStruct'],
          ParamType.DataStruct,
          true,
          structBuilder: AbilityStructStruct.fromAlgoliaData,
        ),
        appearance: convertAlgoliaParam(
          data['appearance'],
          ParamType.String,
          false,
        ),
        ability: convertAlgoliaParam(
          data['ability'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'CharacterStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is CharacterStructStruct &&
        name == other.name &&
        setting == other.setting &&
        introduce == other.introduce &&
        seed == other.seed &&
        profileimage == other.profileimage &&
        listEquality.equals(emotionStruct, other.emotionStruct) &&
        basePrompt == other.basePrompt &&
        listEquality.equals(abilityStruct, other.abilityStruct) &&
        appearance == other.appearance &&
        ability == other.ability;
  }

  @override
  int get hashCode => const ListEquality().hash([
        name,
        setting,
        introduce,
        seed,
        profileimage,
        emotionStruct,
        basePrompt,
        abilityStruct,
        appearance,
        ability
      ]);
}

CharacterStructStruct createCharacterStructStruct({
  String? name,
  String? setting,
  String? introduce,
  int? seed,
  String? profileimage,
  String? basePrompt,
  String? appearance,
  String? ability,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CharacterStructStruct(
      name: name,
      setting: setting,
      introduce: introduce,
      seed: seed,
      profileimage: profileimage,
      basePrompt: basePrompt,
      appearance: appearance,
      ability: ability,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CharacterStructStruct? updateCharacterStructStruct(
  CharacterStructStruct? characterStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    characterStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCharacterStructStructData(
  Map<String, dynamic> firestoreData,
  CharacterStructStruct? characterStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (characterStruct == null) {
    return;
  }
  if (characterStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && characterStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final characterStructData =
      getCharacterStructFirestoreData(characterStruct, forFieldValue);
  final nestedData =
      characterStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = characterStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCharacterStructFirestoreData(
  CharacterStructStruct? characterStruct, [
  bool forFieldValue = false,
]) {
  if (characterStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(characterStruct.toMap());

  // Add any Firestore field values
  characterStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCharacterStructListFirestoreData(
  List<CharacterStructStruct>? characterStructs,
) =>
    characterStructs
        ?.map((e) => getCharacterStructFirestoreData(e, true))
        .toList() ??
    [];
