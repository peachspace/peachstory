// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class PlaceStructStruct extends FFFirebaseStruct {
  PlaceStructStruct({
    String? imageUrl,
    String? place,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _imageUrl = imageUrl,
        _place = place,
        super(firestoreUtilData);

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  // "place" field.
  String? _place;
  String get place => _place ?? '';
  set place(String? val) => _place = val;

  bool hasPlace() => _place != null;

  static PlaceStructStruct fromMap(Map<String, dynamic> data) =>
      PlaceStructStruct(
        imageUrl: data['imageUrl'] as String?,
        place: data['place'] as String?,
      );

  static PlaceStructStruct? maybeFromMap(dynamic data) => data is Map
      ? PlaceStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'imageUrl': _imageUrl,
        'place': _place,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
        'place': serializeParam(
          _place,
          ParamType.String,
        ),
      }.withoutNulls;

  static PlaceStructStruct fromSerializableMap(Map<String, dynamic> data) =>
      PlaceStructStruct(
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        place: deserializeParam(
          data['place'],
          ParamType.String,
          false,
        ),
      );

  static PlaceStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      PlaceStructStruct(
        imageUrl: convertAlgoliaParam(
          data['imageUrl'],
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
  String toString() => 'PlaceStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PlaceStructStruct &&
        imageUrl == other.imageUrl &&
        place == other.place;
  }

  @override
  int get hashCode => const ListEquality().hash([imageUrl, place]);
}

PlaceStructStruct createPlaceStructStruct({
  String? imageUrl,
  String? place,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    PlaceStructStruct(
      imageUrl: imageUrl,
      place: place,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

PlaceStructStruct? updatePlaceStructStruct(
  PlaceStructStruct? placeStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    placeStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPlaceStructStructData(
  Map<String, dynamic> firestoreData,
  PlaceStructStruct? placeStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (placeStruct == null) {
    return;
  }
  if (placeStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && placeStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final placeStructData =
      getPlaceStructFirestoreData(placeStruct, forFieldValue);
  final nestedData =
      placeStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = placeStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPlaceStructFirestoreData(
  PlaceStructStruct? placeStruct, [
  bool forFieldValue = false,
]) {
  if (placeStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(placeStruct.toMap());

  // Add any Firestore field values
  placeStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPlaceStructListFirestoreData(
  List<PlaceStructStruct>? placeStructs,
) =>
    placeStructs?.map((e) => getPlaceStructFirestoreData(e, true)).toList() ??
    [];
