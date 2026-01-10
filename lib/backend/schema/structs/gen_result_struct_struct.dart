// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class GenResultStructStruct extends FFFirebaseStruct {
  GenResultStructStruct({
    String? imageurl,
    int? seed,
    String? text,
    String? basePrompt,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _imageurl = imageurl,
        _seed = seed,
        _text = text,
        _basePrompt = basePrompt,
        super(firestoreUtilData);

  // "imageurl" field.
  String? _imageurl;
  String get imageurl => _imageurl ?? '';
  set imageurl(String? val) => _imageurl = val;

  bool hasImageurl() => _imageurl != null;

  // "seed" field.
  int? _seed;
  int get seed => _seed ?? 0;
  set seed(int? val) => _seed = val;

  void incrementSeed(int amount) => seed = seed + amount;

  bool hasSeed() => _seed != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  // "basePrompt" field.
  String? _basePrompt;
  String get basePrompt => _basePrompt ?? '';
  set basePrompt(String? val) => _basePrompt = val;

  bool hasBasePrompt() => _basePrompt != null;

  static GenResultStructStruct fromMap(Map<String, dynamic> data) =>
      GenResultStructStruct(
        imageurl: data['imageurl'] as String?,
        seed: castToType<int>(data['seed']),
        text: data['text'] as String?,
        basePrompt: data['basePrompt'] as String?,
      );

  static GenResultStructStruct? maybeFromMap(dynamic data) => data is Map
      ? GenResultStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'imageurl': _imageurl,
        'seed': _seed,
        'text': _text,
        'basePrompt': _basePrompt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'imageurl': serializeParam(
          _imageurl,
          ParamType.String,
        ),
        'seed': serializeParam(
          _seed,
          ParamType.int,
        ),
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
        'basePrompt': serializeParam(
          _basePrompt,
          ParamType.String,
        ),
      }.withoutNulls;

  static GenResultStructStruct fromSerializableMap(Map<String, dynamic> data) =>
      GenResultStructStruct(
        imageurl: deserializeParam(
          data['imageurl'],
          ParamType.String,
          false,
        ),
        seed: deserializeParam(
          data['seed'],
          ParamType.int,
          false,
        ),
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
        basePrompt: deserializeParam(
          data['basePrompt'],
          ParamType.String,
          false,
        ),
      );

  static GenResultStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      GenResultStructStruct(
        imageurl: convertAlgoliaParam(
          data['imageurl'],
          ParamType.String,
          false,
        ),
        seed: convertAlgoliaParam(
          data['seed'],
          ParamType.int,
          false,
        ),
        text: convertAlgoliaParam(
          data['text'],
          ParamType.String,
          false,
        ),
        basePrompt: convertAlgoliaParam(
          data['basePrompt'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'GenResultStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GenResultStructStruct &&
        imageurl == other.imageurl &&
        seed == other.seed &&
        text == other.text &&
        basePrompt == other.basePrompt;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([imageurl, seed, text, basePrompt]);
}

GenResultStructStruct createGenResultStructStruct({
  String? imageurl,
  int? seed,
  String? text,
  String? basePrompt,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    GenResultStructStruct(
      imageurl: imageurl,
      seed: seed,
      text: text,
      basePrompt: basePrompt,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

GenResultStructStruct? updateGenResultStructStruct(
  GenResultStructStruct? genResultStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    genResultStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addGenResultStructStructData(
  Map<String, dynamic> firestoreData,
  GenResultStructStruct? genResultStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (genResultStruct == null) {
    return;
  }
  if (genResultStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && genResultStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final genResultStructData =
      getGenResultStructFirestoreData(genResultStruct, forFieldValue);
  final nestedData =
      genResultStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = genResultStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getGenResultStructFirestoreData(
  GenResultStructStruct? genResultStruct, [
  bool forFieldValue = false,
]) {
  if (genResultStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(genResultStruct.toMap());

  // Add any Firestore field values
  genResultStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getGenResultStructListFirestoreData(
  List<GenResultStructStruct>? genResultStructs,
) =>
    genResultStructs
        ?.map((e) => getGenResultStructFirestoreData(e, true))
        .toList() ??
    [];
