// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CharacterStructStruct extends FFFirebaseStruct {
  CharacterStructStruct({
    String? name,
    String? personality,
    String? image,
    String? introduce,
    String? id,
    int? seed,
    String? profileimage,
    List<EmotionImageStructStruct>? emotionimages,
    String? basePrompt,
    List<SituationalImageStructStruct>? situationImages,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _personality = personality,
        _image = image,
        _introduce = introduce,
        _id = id,
        _seed = seed,
        _profileimage = profileimage,
        _emotionimages = emotionimages,
        _basePrompt = basePrompt,
        _situationImages = situationImages,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "personality" field.
  String? _personality;
  String get personality => _personality ?? '';
  set personality(String? val) => _personality = val;

  bool hasPersonality() => _personality != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "introduce" field.
  String? _introduce;
  String get introduce => _introduce ?? '';
  set introduce(String? val) => _introduce = val;

  bool hasIntroduce() => _introduce != null;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

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

  // "emotionimages" field.
  List<EmotionImageStructStruct>? _emotionimages;
  List<EmotionImageStructStruct> get emotionimages =>
      _emotionimages ?? const [];
  set emotionimages(List<EmotionImageStructStruct>? val) =>
      _emotionimages = val;

  void updateEmotionimages(Function(List<EmotionImageStructStruct>) updateFn) {
    updateFn(_emotionimages ??= []);
  }

  bool hasEmotionimages() => _emotionimages != null;

  // "basePrompt" field.
  String? _basePrompt;
  String get basePrompt => _basePrompt ?? '';
  set basePrompt(String? val) => _basePrompt = val;

  bool hasBasePrompt() => _basePrompt != null;

  // "situationImages" field.
  List<SituationalImageStructStruct>? _situationImages;
  List<SituationalImageStructStruct> get situationImages =>
      _situationImages ?? const [];
  set situationImages(List<SituationalImageStructStruct>? val) =>
      _situationImages = val;

  void updateSituationImages(
      Function(List<SituationalImageStructStruct>) updateFn) {
    updateFn(_situationImages ??= []);
  }

  bool hasSituationImages() => _situationImages != null;

  static CharacterStructStruct fromMap(Map<String, dynamic> data) =>
      CharacterStructStruct(
        name: data['name'] as String?,
        personality: data['personality'] as String?,
        image: data['image'] as String?,
        introduce: data['introduce'] as String?,
        id: data['id'] as String?,
        seed: castToType<int>(data['Seed']),
        profileimage: data['profileimage'] as String?,
        emotionimages: getStructList(
          data['emotionimages'],
          EmotionImageStructStruct.fromMap,
        ),
        basePrompt: data['basePrompt'] as String?,
        situationImages: getStructList(
          data['situationImages'],
          SituationalImageStructStruct.fromMap,
        ),
      );

  static CharacterStructStruct? maybeFromMap(dynamic data) => data is Map
      ? CharacterStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'personality': _personality,
        'image': _image,
        'introduce': _introduce,
        'id': _id,
        'Seed': _seed,
        'profileimage': _profileimage,
        'emotionimages': _emotionimages?.map((e) => e.toMap()).toList(),
        'basePrompt': _basePrompt,
        'situationImages': _situationImages?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'personality': serializeParam(
          _personality,
          ParamType.String,
        ),
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'introduce': serializeParam(
          _introduce,
          ParamType.String,
        ),
        'id': serializeParam(
          _id,
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
        'emotionimages': serializeParam(
          _emotionimages,
          ParamType.DataStruct,
          isList: true,
        ),
        'basePrompt': serializeParam(
          _basePrompt,
          ParamType.String,
        ),
        'situationImages': serializeParam(
          _situationImages,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static CharacterStructStruct fromSerializableMap(Map<String, dynamic> data) =>
      CharacterStructStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        personality: deserializeParam(
          data['personality'],
          ParamType.String,
          false,
        ),
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        introduce: deserializeParam(
          data['introduce'],
          ParamType.String,
          false,
        ),
        id: deserializeParam(
          data['id'],
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
        emotionimages: deserializeStructParam<EmotionImageStructStruct>(
          data['emotionimages'],
          ParamType.DataStruct,
          true,
          structBuilder: EmotionImageStructStruct.fromSerializableMap,
        ),
        basePrompt: deserializeParam(
          data['basePrompt'],
          ParamType.String,
          false,
        ),
        situationImages: deserializeStructParam<SituationalImageStructStruct>(
          data['situationImages'],
          ParamType.DataStruct,
          true,
          structBuilder: SituationalImageStructStruct.fromSerializableMap,
        ),
      );

  static CharacterStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      CharacterStructStruct(
        name: convertAlgoliaParam(
          data['name'],
          ParamType.String,
          false,
        ),
        personality: convertAlgoliaParam(
          data['personality'],
          ParamType.String,
          false,
        ),
        image: convertAlgoliaParam(
          data['image'],
          ParamType.String,
          false,
        ),
        introduce: convertAlgoliaParam(
          data['introduce'],
          ParamType.String,
          false,
        ),
        id: convertAlgoliaParam(
          data['id'],
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
        emotionimages: convertAlgoliaParam<EmotionImageStructStruct>(
          data['emotionimages'],
          ParamType.DataStruct,
          true,
          structBuilder: EmotionImageStructStruct.fromAlgoliaData,
        ),
        basePrompt: convertAlgoliaParam(
          data['basePrompt'],
          ParamType.String,
          false,
        ),
        situationImages: convertAlgoliaParam<SituationalImageStructStruct>(
          data['situationImages'],
          ParamType.DataStruct,
          true,
          structBuilder: SituationalImageStructStruct.fromAlgoliaData,
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
        personality == other.personality &&
        image == other.image &&
        introduce == other.introduce &&
        id == other.id &&
        seed == other.seed &&
        profileimage == other.profileimage &&
        listEquality.equals(emotionimages, other.emotionimages) &&
        basePrompt == other.basePrompt &&
        listEquality.equals(situationImages, other.situationImages);
  }

  @override
  int get hashCode => const ListEquality().hash([
        name,
        personality,
        image,
        introduce,
        id,
        seed,
        profileimage,
        emotionimages,
        basePrompt,
        situationImages
      ]);
}

CharacterStructStruct createCharacterStructStruct({
  String? name,
  String? personality,
  String? image,
  String? introduce,
  String? id,
  int? seed,
  String? profileimage,
  String? basePrompt,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CharacterStructStruct(
      name: name,
      personality: personality,
      image: image,
      introduce: introduce,
      id: id,
      seed: seed,
      profileimage: profileimage,
      basePrompt: basePrompt,
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
