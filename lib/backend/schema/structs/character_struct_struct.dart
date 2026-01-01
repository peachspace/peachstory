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
    String? appearancePrompt,
    int? characterSeed,
    String? imageUrl,
    List<EmotionImageStructStruct>? emotionImages,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _personality = personality,
        _image = image,
        _introduce = introduce,
        _id = id,
        _appearancePrompt = appearancePrompt,
        _characterSeed = characterSeed,
        _imageUrl = imageUrl,
        _emotionImages = emotionImages,
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

  // "appearancePrompt" field.
  String? _appearancePrompt;
  String get appearancePrompt => _appearancePrompt ?? '';
  set appearancePrompt(String? val) => _appearancePrompt = val;

  bool hasAppearancePrompt() => _appearancePrompt != null;

  // "characterSeed" field.
  int? _characterSeed;
  int get characterSeed => _characterSeed ?? 0;
  set characterSeed(int? val) => _characterSeed = val;

  void incrementCharacterSeed(int amount) =>
      characterSeed = characterSeed + amount;

  bool hasCharacterSeed() => _characterSeed != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  // "emotion_images" field.
  List<EmotionImageStructStruct>? _emotionImages;
  List<EmotionImageStructStruct> get emotionImages =>
      _emotionImages ?? const [];
  set emotionImages(List<EmotionImageStructStruct>? val) =>
      _emotionImages = val;

  void updateEmotionImages(Function(List<EmotionImageStructStruct>) updateFn) {
    updateFn(_emotionImages ??= []);
  }

  bool hasEmotionImages() => _emotionImages != null;

  static CharacterStructStruct fromMap(Map<String, dynamic> data) =>
      CharacterStructStruct(
        name: data['name'] as String?,
        personality: data['personality'] as String?,
        image: data['image'] as String?,
        introduce: data['introduce'] as String?,
        id: data['id'] as String?,
        appearancePrompt: data['appearancePrompt'] as String?,
        characterSeed: castToType<int>(data['characterSeed']),
        imageUrl: data['imageUrl'] as String?,
        emotionImages: getStructList(
          data['emotion_images'],
          EmotionImageStructStruct.fromMap,
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
        'appearancePrompt': _appearancePrompt,
        'characterSeed': _characterSeed,
        'imageUrl': _imageUrl,
        'emotion_images': _emotionImages?.map((e) => e.toMap()).toList(),
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
        'appearancePrompt': serializeParam(
          _appearancePrompt,
          ParamType.String,
        ),
        'characterSeed': serializeParam(
          _characterSeed,
          ParamType.int,
        ),
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
        'emotion_images': serializeParam(
          _emotionImages,
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
        appearancePrompt: deserializeParam(
          data['appearancePrompt'],
          ParamType.String,
          false,
        ),
        characterSeed: deserializeParam(
          data['characterSeed'],
          ParamType.int,
          false,
        ),
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        emotionImages: deserializeStructParam<EmotionImageStructStruct>(
          data['emotion_images'],
          ParamType.DataStruct,
          true,
          structBuilder: EmotionImageStructStruct.fromSerializableMap,
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
        appearancePrompt: convertAlgoliaParam(
          data['appearancePrompt'],
          ParamType.String,
          false,
        ),
        characterSeed: convertAlgoliaParam(
          data['characterSeed'],
          ParamType.int,
          false,
        ),
        imageUrl: convertAlgoliaParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        emotionImages: convertAlgoliaParam<EmotionImageStructStruct>(
          data['emotion_images'],
          ParamType.DataStruct,
          true,
          structBuilder: EmotionImageStructStruct.fromAlgoliaData,
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
        appearancePrompt == other.appearancePrompt &&
        characterSeed == other.characterSeed &&
        imageUrl == other.imageUrl &&
        listEquality.equals(emotionImages, other.emotionImages);
  }

  @override
  int get hashCode => const ListEquality().hash([
        name,
        personality,
        image,
        introduce,
        id,
        appearancePrompt,
        characterSeed,
        imageUrl,
        emotionImages
      ]);
}

CharacterStructStruct createCharacterStructStruct({
  String? name,
  String? personality,
  String? image,
  String? introduce,
  String? id,
  String? appearancePrompt,
  int? characterSeed,
  String? imageUrl,
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
      appearancePrompt: appearancePrompt,
      characterSeed: characterSeed,
      imageUrl: imageUrl,
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
