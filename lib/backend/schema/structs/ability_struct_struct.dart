// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class AbilityStructStruct extends FFFirebaseStruct {
  AbilityStructStruct({
    String? ability,
    String? imageUrl,
    String? place,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _ability = ability,
        _imageUrl = imageUrl,
        _place = place,
        super(firestoreUtilData);

  // "ability" field.
  String? _ability;
  String get ability => _ability ?? '';
  set ability(String? val) => _ability = val;

  bool hasAbility() => _ability != null;

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

  static AbilityStructStruct fromMap(Map<String, dynamic> data) =>
      AbilityStructStruct(
        ability: data['ability'] as String?,
        imageUrl: data['imageUrl'] as String?,
        place: data['place'] as String?,
      );

  static AbilityStructStruct? maybeFromMap(dynamic data) => data is Map
      ? AbilityStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'ability': _ability,
        'imageUrl': _imageUrl,
        'place': _place,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'ability': serializeParam(
          _ability,
          ParamType.String,
        ),
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
        'place': serializeParam(
          _place,
          ParamType.String,
        ),
      }.withoutNulls;

  static AbilityStructStruct fromSerializableMap(Map<String, dynamic> data) =>
      AbilityStructStruct(
        ability: deserializeParam(
          data['ability'],
          ParamType.String,
          false,
        ),
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

  static AbilityStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      AbilityStructStruct(
        ability: convertAlgoliaParam(
          data['ability'],
          ParamType.String,
          false,
        ),
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
  String toString() => 'AbilityStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AbilityStructStruct &&
        ability == other.ability &&
        imageUrl == other.imageUrl &&
        place == other.place;
  }

  @override
  int get hashCode => const ListEquality().hash([ability, imageUrl, place]);
}

AbilityStructStruct createAbilityStructStruct({
  String? ability,
  String? imageUrl,
  String? place,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    AbilityStructStruct(
      ability: ability,
      imageUrl: imageUrl,
      place: place,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

AbilityStructStruct? updateAbilityStructStruct(
  AbilityStructStruct? abilityStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    abilityStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addAbilityStructStructData(
  Map<String, dynamic> firestoreData,
  AbilityStructStruct? abilityStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (abilityStruct == null) {
    return;
  }
  if (abilityStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && abilityStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final abilityStructData =
      getAbilityStructFirestoreData(abilityStruct, forFieldValue);
  final nestedData =
      abilityStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = abilityStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getAbilityStructFirestoreData(
  AbilityStructStruct? abilityStruct, [
  bool forFieldValue = false,
]) {
  if (abilityStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(abilityStruct.toMap());

  // Add any Firestore field values
  abilityStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getAbilityStructListFirestoreData(
  List<AbilityStructStruct>? abilityStructs,
) =>
    abilityStructs
        ?.map((e) => getAbilityStructFirestoreData(e, true))
        .toList() ??
    [];
