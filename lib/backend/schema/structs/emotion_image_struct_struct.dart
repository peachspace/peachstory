// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class EmotionImageStructStruct extends FFFirebaseStruct {
  EmotionImageStructStruct({
    String? emotion,
    String? imageurl,
    DateTime? createdAt,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _emotion = emotion,
        _imageurl = imageurl,
        _createdAt = createdAt,
        super(firestoreUtilData);

  // "emotion" field.
  String? _emotion;
  String get emotion => _emotion ?? '';
  set emotion(String? val) => _emotion = val;

  bool hasEmotion() => _emotion != null;

  // "imageurl" field.
  String? _imageurl;
  String get imageurl => _imageurl ?? '';
  set imageurl(String? val) => _imageurl = val;

  bool hasImageurl() => _imageurl != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  static EmotionImageStructStruct fromMap(Map<String, dynamic> data) =>
      EmotionImageStructStruct(
        emotion: data['emotion'] as String?,
        imageurl: data['imageurl'] as String?,
        createdAt: data['createdAt'] as DateTime?,
      );

  static EmotionImageStructStruct? maybeFromMap(dynamic data) => data is Map
      ? EmotionImageStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'emotion': _emotion,
        'imageurl': _imageurl,
        'createdAt': _createdAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'emotion': serializeParam(
          _emotion,
          ParamType.String,
        ),
        'imageurl': serializeParam(
          _imageurl,
          ParamType.String,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static EmotionImageStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      EmotionImageStructStruct(
        emotion: deserializeParam(
          data['emotion'],
          ParamType.String,
          false,
        ),
        imageurl: deserializeParam(
          data['imageurl'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
      );

  static EmotionImageStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      EmotionImageStructStruct(
        emotion: convertAlgoliaParam(
          data['emotion'],
          ParamType.String,
          false,
        ),
        imageurl: convertAlgoliaParam(
          data['imageurl'],
          ParamType.String,
          false,
        ),
        createdAt: convertAlgoliaParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'EmotionImageStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is EmotionImageStructStruct &&
        emotion == other.emotion &&
        imageurl == other.imageurl &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode => const ListEquality().hash([emotion, imageurl, createdAt]);
}

EmotionImageStructStruct createEmotionImageStructStruct({
  String? emotion,
  String? imageurl,
  DateTime? createdAt,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    EmotionImageStructStruct(
      emotion: emotion,
      imageurl: imageurl,
      createdAt: createdAt,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

EmotionImageStructStruct? updateEmotionImageStructStruct(
  EmotionImageStructStruct? emotionImageStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    emotionImageStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addEmotionImageStructStructData(
  Map<String, dynamic> firestoreData,
  EmotionImageStructStruct? emotionImageStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (emotionImageStruct == null) {
    return;
  }
  if (emotionImageStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && emotionImageStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final emotionImageStructData =
      getEmotionImageStructFirestoreData(emotionImageStruct, forFieldValue);
  final nestedData =
      emotionImageStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      emotionImageStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getEmotionImageStructFirestoreData(
  EmotionImageStructStruct? emotionImageStruct, [
  bool forFieldValue = false,
]) {
  if (emotionImageStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(emotionImageStruct.toMap());

  // Add any Firestore field values
  emotionImageStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getEmotionImageStructListFirestoreData(
  List<EmotionImageStructStruct>? emotionImageStructs,
) =>
    emotionImageStructs
        ?.map((e) => getEmotionImageStructFirestoreData(e, true))
        .toList() ??
    [];
