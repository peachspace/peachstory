// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LocationBackgroundStructStruct extends FFFirebaseStruct {
  LocationBackgroundStructStruct({
    String? locationName,
    String? imageUrl,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _locationName = locationName,
        _imageUrl = imageUrl,
        super(firestoreUtilData);

  // "locationName" field.
  String? _locationName;
  String get locationName => _locationName ?? '';
  set locationName(String? val) => _locationName = val;

  bool hasLocationName() => _locationName != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  static LocationBackgroundStructStruct fromMap(Map<String, dynamic> data) =>
      LocationBackgroundStructStruct(
        locationName: data['locationName'] as String?,
        imageUrl: data['imageUrl'] as String?,
      );

  static LocationBackgroundStructStruct? maybeFromMap(dynamic data) =>
      data is Map
          ? LocationBackgroundStructStruct.fromMap(data.cast<String, dynamic>())
          : null;

  Map<String, dynamic> toMap() => {
        'locationName': _locationName,
        'imageUrl': _imageUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'locationName': serializeParam(
          _locationName,
          ParamType.String,
        ),
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static LocationBackgroundStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      LocationBackgroundStructStruct(
        locationName: deserializeParam(
          data['locationName'],
          ParamType.String,
          false,
        ),
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
      );

  static LocationBackgroundStructStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      LocationBackgroundStructStruct(
        locationName: convertAlgoliaParam(
          data['locationName'],
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
  String toString() => 'LocationBackgroundStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is LocationBackgroundStructStruct &&
        locationName == other.locationName &&
        imageUrl == other.imageUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([locationName, imageUrl]);
}

LocationBackgroundStructStruct createLocationBackgroundStructStruct({
  String? locationName,
  String? imageUrl,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    LocationBackgroundStructStruct(
      locationName: locationName,
      imageUrl: imageUrl,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

LocationBackgroundStructStruct? updateLocationBackgroundStructStruct(
  LocationBackgroundStructStruct? locationBackgroundStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    locationBackgroundStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addLocationBackgroundStructStructData(
  Map<String, dynamic> firestoreData,
  LocationBackgroundStructStruct? locationBackgroundStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (locationBackgroundStruct == null) {
    return;
  }
  if (locationBackgroundStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      locationBackgroundStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final locationBackgroundStructData = getLocationBackgroundStructFirestoreData(
      locationBackgroundStruct, forFieldValue);
  final nestedData =
      locationBackgroundStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      locationBackgroundStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getLocationBackgroundStructFirestoreData(
  LocationBackgroundStructStruct? locationBackgroundStruct, [
  bool forFieldValue = false,
]) {
  if (locationBackgroundStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(locationBackgroundStruct.toMap());

  // Add any Firestore field values
  locationBackgroundStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getLocationBackgroundStructListFirestoreData(
  List<LocationBackgroundStructStruct>? locationBackgroundStructs,
) =>
    locationBackgroundStructs
        ?.map((e) => getLocationBackgroundStructFirestoreData(e, true))
        .toList() ??
    [];
