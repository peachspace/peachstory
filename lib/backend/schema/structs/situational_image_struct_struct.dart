// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class SituationalImageStructStruct extends FFFirebaseStruct {
  SituationalImageStructStruct({
    String? condition,
    String? imageUrl,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _condition = condition,
        _imageUrl = imageUrl,
        super(firestoreUtilData);

  // "condition" field.
  String? _condition;
  String get condition => _condition ?? '';
  set condition(String? val) => _condition = val;

  bool hasCondition() => _condition != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  static SituationalImageStructStruct fromMap(Map<String, dynamic> data) =>
      SituationalImageStructStruct(
        condition: data['condition'] as String?,
        imageUrl: data['imageUrl'] as String?,
      );

  static SituationalImageStructStruct? maybeFromMap(dynamic data) => data is Map
      ? SituationalImageStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'condition': _condition,
        'imageUrl': _imageUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'condition': serializeParam(
          _condition,
          ParamType.String,
        ),
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static SituationalImageStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      SituationalImageStructStruct(
        condition: deserializeParam(
          data['condition'],
          ParamType.String,
          false,
        ),
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
      );

  static SituationalImageStructStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      SituationalImageStructStruct(
        condition: convertAlgoliaParam(
          data['condition'],
          ParamType.String,
          false,
        ),
        imageUrl: convertAlgoliaParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'SituationalImageStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SituationalImageStructStruct &&
        condition == other.condition &&
        imageUrl == other.imageUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([condition, imageUrl]);
}

SituationalImageStructStruct createSituationalImageStructStruct({
  String? condition,
  String? imageUrl,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SituationalImageStructStruct(
      condition: condition,
      imageUrl: imageUrl,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SituationalImageStructStruct? updateSituationalImageStructStruct(
  SituationalImageStructStruct? situationalImageStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    situationalImageStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSituationalImageStructStructData(
  Map<String, dynamic> firestoreData,
  SituationalImageStructStruct? situationalImageStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (situationalImageStruct == null) {
    return;
  }
  if (situationalImageStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      situationalImageStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final situationalImageStructData = getSituationalImageStructFirestoreData(
      situationalImageStruct, forFieldValue);
  final nestedData =
      situationalImageStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      situationalImageStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSituationalImageStructFirestoreData(
  SituationalImageStructStruct? situationalImageStruct, [
  bool forFieldValue = false,
]) {
  if (situationalImageStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(situationalImageStruct.toMap());

  // Add any Firestore field values
  situationalImageStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSituationalImageStructListFirestoreData(
  List<SituationalImageStructStruct>? situationalImageStructs,
) =>
    situationalImageStructs
        ?.map((e) => getSituationalImageStructFirestoreData(e, true))
        .toList() ??
    [];
