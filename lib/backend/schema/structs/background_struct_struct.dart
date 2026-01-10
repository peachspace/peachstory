// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class BackgroundStructStruct extends FFFirebaseStruct {
  BackgroundStructStruct({
    String? imageUrl,
    String? placeName,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _imageUrl = imageUrl,
        _placeName = placeName,
        super(firestoreUtilData);

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  // "placeName" field.
  String? _placeName;
  String get placeName => _placeName ?? '';
  set placeName(String? val) => _placeName = val;

  bool hasPlaceName() => _placeName != null;

  static BackgroundStructStruct fromMap(Map<String, dynamic> data) =>
      BackgroundStructStruct(
        imageUrl: data['imageUrl'] as String?,
        placeName: data['placeName'] as String?,
      );

  static BackgroundStructStruct? maybeFromMap(dynamic data) => data is Map
      ? BackgroundStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'imageUrl': _imageUrl,
        'placeName': _placeName,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
        'placeName': serializeParam(
          _placeName,
          ParamType.String,
        ),
      }.withoutNulls;

  static BackgroundStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      BackgroundStructStruct(
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        placeName: deserializeParam(
          data['placeName'],
          ParamType.String,
          false,
        ),
      );

  static BackgroundStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      BackgroundStructStruct(
        imageUrl: convertAlgoliaParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        placeName: convertAlgoliaParam(
          data['placeName'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'BackgroundStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is BackgroundStructStruct &&
        imageUrl == other.imageUrl &&
        placeName == other.placeName;
  }

  @override
  int get hashCode => const ListEquality().hash([imageUrl, placeName]);
}

BackgroundStructStruct createBackgroundStructStruct({
  String? imageUrl,
  String? placeName,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    BackgroundStructStruct(
      imageUrl: imageUrl,
      placeName: placeName,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

BackgroundStructStruct? updateBackgroundStructStruct(
  BackgroundStructStruct? backgroundStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    backgroundStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addBackgroundStructStructData(
  Map<String, dynamic> firestoreData,
  BackgroundStructStruct? backgroundStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (backgroundStruct == null) {
    return;
  }
  if (backgroundStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && backgroundStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final backgroundStructData =
      getBackgroundStructFirestoreData(backgroundStruct, forFieldValue);
  final nestedData =
      backgroundStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = backgroundStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getBackgroundStructFirestoreData(
  BackgroundStructStruct? backgroundStruct, [
  bool forFieldValue = false,
]) {
  if (backgroundStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(backgroundStruct.toMap());

  // Add any Firestore field values
  backgroundStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getBackgroundStructListFirestoreData(
  List<BackgroundStructStruct>? backgroundStructs,
) =>
    backgroundStructs
        ?.map((e) => getBackgroundStructFirestoreData(e, true))
        .toList() ??
    [];
