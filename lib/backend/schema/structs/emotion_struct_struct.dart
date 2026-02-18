// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class EmotionStructStruct extends FFFirebaseStruct {
  EmotionStructStruct({
    String? emotion,
    String? imageurl,
    String? place,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _emotion = emotion,
        _imageurl = imageurl,
        _place = place,
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

  // "place" field.
  String? _place;
  String get place => _place ?? '';
  set place(String? val) => _place = val;

  bool hasPlace() => _place != null;

  static EmotionStructStruct fromMap(Map<String, dynamic> data) =>
      EmotionStructStruct(
        emotion: data['emotion'] as String?,
        imageurl: data['imageurl'] as String?,
        place: data['place'] as String?,
      );

  static EmotionStructStruct? maybeFromMap(dynamic data) => data is Map
      ? EmotionStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'emotion': _emotion,
        'imageurl': _imageurl,
        'place': _place,
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
        'place': serializeParam(
          _place,
          ParamType.String,
        ),
      }.withoutNulls;

  static EmotionStructStruct fromSerializableMap(Map<String, dynamic> data) =>
      EmotionStructStruct(
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
        place: deserializeParam(
          data['place'],
          ParamType.String,
          false,
        ),
      );

  static EmotionStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      EmotionStructStruct(
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
        place: convertAlgoliaParam(
          data['place'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'EmotionStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is EmotionStructStruct &&
        emotion == other.emotion &&
        imageurl == other.imageurl &&
        place == other.place;
  }

  @override
  int get hashCode => const ListEquality().hash([emotion, imageurl, place]);
}

EmotionStructStruct createEmotionStructStruct({
  String? emotion,
  String? imageurl,
  String? place,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    EmotionStructStruct(
      emotion: emotion,
      imageurl: imageurl,
      place: place,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

EmotionStructStruct? updateEmotionStructStruct(
  EmotionStructStruct? emotionStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    emotionStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addEmotionStructStructData(
  Map<String, dynamic> firestoreData,
  EmotionStructStruct? emotionStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (emotionStruct == null) {
    return;
  }
  if (emotionStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && emotionStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final emotionStructData =
      getEmotionStructFirestoreData(emotionStruct, forFieldValue);
  final nestedData =
      emotionStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = emotionStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getEmotionStructFirestoreData(
  EmotionStructStruct? emotionStruct, [
  bool forFieldValue = false,
]) {
  if (emotionStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(emotionStruct.toMap());

  // Add any Firestore field values
  emotionStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getEmotionStructListFirestoreData(
  List<EmotionStructStruct>? emotionStructs,
) =>
    emotionStructs
        ?.map((e) => getEmotionStructFirestoreData(e, true))
        .toList() ??
    [];
