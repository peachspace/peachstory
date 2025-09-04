// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ApiRetryOutputStructStruct extends FFFirebaseStruct {
  ApiRetryOutputStructStruct({
    bool? isSuccess,
    String? responseBody,
    int? statusCode,
    String? errorMessage,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _isSuccess = isSuccess,
        _responseBody = responseBody,
        _statusCode = statusCode,
        _errorMessage = errorMessage,
        super(firestoreUtilData);

  // "isSuccess" field.
  bool? _isSuccess;
  bool get isSuccess => _isSuccess ?? false;
  set isSuccess(bool? val) => _isSuccess = val;

  bool hasIsSuccess() => _isSuccess != null;

  // "responseBody" field.
  String? _responseBody;
  String get responseBody => _responseBody ?? '';
  set responseBody(String? val) => _responseBody = val;

  bool hasResponseBody() => _responseBody != null;

  // "statusCode" field.
  int? _statusCode;
  int get statusCode => _statusCode ?? 0;
  set statusCode(int? val) => _statusCode = val;

  void incrementStatusCode(int amount) => statusCode = statusCode + amount;

  bool hasStatusCode() => _statusCode != null;

  // "errorMessage" field.
  String? _errorMessage;
  String get errorMessage => _errorMessage ?? '';
  set errorMessage(String? val) => _errorMessage = val;

  bool hasErrorMessage() => _errorMessage != null;

  static ApiRetryOutputStructStruct fromMap(Map<String, dynamic> data) =>
      ApiRetryOutputStructStruct(
        isSuccess: data['isSuccess'] as bool?,
        responseBody: data['responseBody'] as String?,
        statusCode: castToType<int>(data['statusCode']),
        errorMessage: data['errorMessage'] as String?,
      );

  static ApiRetryOutputStructStruct? maybeFromMap(dynamic data) => data is Map
      ? ApiRetryOutputStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'isSuccess': _isSuccess,
        'responseBody': _responseBody,
        'statusCode': _statusCode,
        'errorMessage': _errorMessage,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'isSuccess': serializeParam(
          _isSuccess,
          ParamType.bool,
        ),
        'responseBody': serializeParam(
          _responseBody,
          ParamType.String,
        ),
        'statusCode': serializeParam(
          _statusCode,
          ParamType.int,
        ),
        'errorMessage': serializeParam(
          _errorMessage,
          ParamType.String,
        ),
      }.withoutNulls;

  static ApiRetryOutputStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ApiRetryOutputStructStruct(
        isSuccess: deserializeParam(
          data['isSuccess'],
          ParamType.bool,
          false,
        ),
        responseBody: deserializeParam(
          data['responseBody'],
          ParamType.String,
          false,
        ),
        statusCode: deserializeParam(
          data['statusCode'],
          ParamType.int,
          false,
        ),
        errorMessage: deserializeParam(
          data['errorMessage'],
          ParamType.String,
          false,
        ),
      );

  static ApiRetryOutputStructStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      ApiRetryOutputStructStruct(
        isSuccess: convertAlgoliaParam(
          data['isSuccess'],
          ParamType.bool,
          false,
        ),
        responseBody: convertAlgoliaParam(
          data['responseBody'],
          ParamType.String,
          false,
        ),
        statusCode: convertAlgoliaParam(
          data['statusCode'],
          ParamType.int,
          false,
        ),
        errorMessage: convertAlgoliaParam(
          data['errorMessage'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'ApiRetryOutputStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ApiRetryOutputStructStruct &&
        isSuccess == other.isSuccess &&
        responseBody == other.responseBody &&
        statusCode == other.statusCode &&
        errorMessage == other.errorMessage;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([isSuccess, responseBody, statusCode, errorMessage]);
}

ApiRetryOutputStructStruct createApiRetryOutputStructStruct({
  bool? isSuccess,
  String? responseBody,
  int? statusCode,
  String? errorMessage,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ApiRetryOutputStructStruct(
      isSuccess: isSuccess,
      responseBody: responseBody,
      statusCode: statusCode,
      errorMessage: errorMessage,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ApiRetryOutputStructStruct? updateApiRetryOutputStructStruct(
  ApiRetryOutputStructStruct? apiRetryOutputStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    apiRetryOutputStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addApiRetryOutputStructStructData(
  Map<String, dynamic> firestoreData,
  ApiRetryOutputStructStruct? apiRetryOutputStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (apiRetryOutputStruct == null) {
    return;
  }
  if (apiRetryOutputStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && apiRetryOutputStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final apiRetryOutputStructData =
      getApiRetryOutputStructFirestoreData(apiRetryOutputStruct, forFieldValue);
  final nestedData =
      apiRetryOutputStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      apiRetryOutputStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getApiRetryOutputStructFirestoreData(
  ApiRetryOutputStructStruct? apiRetryOutputStruct, [
  bool forFieldValue = false,
]) {
  if (apiRetryOutputStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(apiRetryOutputStruct.toMap());

  // Add any Firestore field values
  apiRetryOutputStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getApiRetryOutputStructListFirestoreData(
  List<ApiRetryOutputStructStruct>? apiRetryOutputStructs,
) =>
    apiRetryOutputStructs
        ?.map((e) => getApiRetryOutputStructFirestoreData(e, true))
        .toList() ??
    [];
