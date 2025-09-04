// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OptionStructStruct extends FFFirebaseStruct {
  OptionStructStruct({
    String? id,
    String? text,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _text = text,
        super(firestoreUtilData);

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  static OptionStructStruct fromMap(Map<String, dynamic> data) =>
      OptionStructStruct(
        id: data['id'] as String?,
        text: data['text'] as String?,
      );

  static OptionStructStruct? maybeFromMap(dynamic data) => data is Map
      ? OptionStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'text': _text,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
      }.withoutNulls;

  static OptionStructStruct fromSerializableMap(Map<String, dynamic> data) =>
      OptionStructStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
      );

  static OptionStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      OptionStructStruct(
        id: convertAlgoliaParam(
          data['id'],
          ParamType.String,
          false,
        ),
        text: convertAlgoliaParam(
          data['text'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'OptionStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is OptionStructStruct && id == other.id && text == other.text;
  }

  @override
  int get hashCode => const ListEquality().hash([id, text]);
}

OptionStructStruct createOptionStructStruct({
  String? id,
  String? text,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    OptionStructStruct(
      id: id,
      text: text,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

OptionStructStruct? updateOptionStructStruct(
  OptionStructStruct? optionStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    optionStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addOptionStructStructData(
  Map<String, dynamic> firestoreData,
  OptionStructStruct? optionStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (optionStruct == null) {
    return;
  }
  if (optionStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && optionStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final optionStructData =
      getOptionStructFirestoreData(optionStruct, forFieldValue);
  final nestedData =
      optionStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = optionStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getOptionStructFirestoreData(
  OptionStructStruct? optionStruct, [
  bool forFieldValue = false,
]) {
  if (optionStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(optionStruct.toMap());

  // Add any Firestore field values
  optionStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getOptionStructListFirestoreData(
  List<OptionStructStruct>? optionStructs,
) =>
    optionStructs?.map((e) => getOptionStructFirestoreData(e, true)).toList() ??
    [];
