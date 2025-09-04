// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ApiMessageStructStruct extends FFFirebaseStruct {
  ApiMessageStructStruct({
    String? role,
    String? content,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _role = role,
        _content = content,
        super(firestoreUtilData);

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  set role(String? val) => _role = val;

  bool hasRole() => _role != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  set content(String? val) => _content = val;

  bool hasContent() => _content != null;

  static ApiMessageStructStruct fromMap(Map<String, dynamic> data) =>
      ApiMessageStructStruct(
        role: data['role'] as String?,
        content: data['content'] as String?,
      );

  static ApiMessageStructStruct? maybeFromMap(dynamic data) => data is Map
      ? ApiMessageStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'role': _role,
        'content': _content,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'role': serializeParam(
          _role,
          ParamType.String,
        ),
        'content': serializeParam(
          _content,
          ParamType.String,
        ),
      }.withoutNulls;

  static ApiMessageStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ApiMessageStructStruct(
        role: deserializeParam(
          data['role'],
          ParamType.String,
          false,
        ),
        content: deserializeParam(
          data['content'],
          ParamType.String,
          false,
        ),
      );

  static ApiMessageStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      ApiMessageStructStruct(
        role: convertAlgoliaParam(
          data['role'],
          ParamType.String,
          false,
        ),
        content: convertAlgoliaParam(
          data['content'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'ApiMessageStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ApiMessageStructStruct &&
        role == other.role &&
        content == other.content;
  }

  @override
  int get hashCode => const ListEquality().hash([role, content]);
}

ApiMessageStructStruct createApiMessageStructStruct({
  String? role,
  String? content,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ApiMessageStructStruct(
      role: role,
      content: content,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ApiMessageStructStruct? updateApiMessageStructStruct(
  ApiMessageStructStruct? apiMessageStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    apiMessageStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addApiMessageStructStructData(
  Map<String, dynamic> firestoreData,
  ApiMessageStructStruct? apiMessageStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (apiMessageStruct == null) {
    return;
  }
  if (apiMessageStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && apiMessageStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final apiMessageStructData =
      getApiMessageStructFirestoreData(apiMessageStruct, forFieldValue);
  final nestedData =
      apiMessageStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = apiMessageStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getApiMessageStructFirestoreData(
  ApiMessageStructStruct? apiMessageStruct, [
  bool forFieldValue = false,
]) {
  if (apiMessageStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(apiMessageStruct.toMap());

  // Add any Firestore field values
  apiMessageStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getApiMessageStructListFirestoreData(
  List<ApiMessageStructStruct>? apiMessageStructs,
) =>
    apiMessageStructs
        ?.map((e) => getApiMessageStructFirestoreData(e, true))
        .toList() ??
    [];
