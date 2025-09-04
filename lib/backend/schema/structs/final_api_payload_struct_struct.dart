// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FinalApiPayloadStructStruct extends FFFirebaseStruct {
  FinalApiPayloadStructStruct({
    List<ApiMessageStructStruct>? messages,
    String? systemPrompt,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _messages = messages,
        _systemPrompt = systemPrompt,
        super(firestoreUtilData);

  // "messages" field.
  List<ApiMessageStructStruct>? _messages;
  List<ApiMessageStructStruct> get messages => _messages ?? const [];
  set messages(List<ApiMessageStructStruct>? val) => _messages = val;

  void updateMessages(Function(List<ApiMessageStructStruct>) updateFn) {
    updateFn(_messages ??= []);
  }

  bool hasMessages() => _messages != null;

  // "systemPrompt" field.
  String? _systemPrompt;
  String get systemPrompt => _systemPrompt ?? '';
  set systemPrompt(String? val) => _systemPrompt = val;

  bool hasSystemPrompt() => _systemPrompt != null;

  static FinalApiPayloadStructStruct fromMap(Map<String, dynamic> data) =>
      FinalApiPayloadStructStruct(
        messages: getStructList(
          data['messages'],
          ApiMessageStructStruct.fromMap,
        ),
        systemPrompt: data['systemPrompt'] as String?,
      );

  static FinalApiPayloadStructStruct? maybeFromMap(dynamic data) => data is Map
      ? FinalApiPayloadStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'messages': _messages?.map((e) => e.toMap()).toList(),
        'systemPrompt': _systemPrompt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'messages': serializeParam(
          _messages,
          ParamType.DataStruct,
          isList: true,
        ),
        'systemPrompt': serializeParam(
          _systemPrompt,
          ParamType.String,
        ),
      }.withoutNulls;

  static FinalApiPayloadStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      FinalApiPayloadStructStruct(
        messages: deserializeStructParam<ApiMessageStructStruct>(
          data['messages'],
          ParamType.DataStruct,
          true,
          structBuilder: ApiMessageStructStruct.fromSerializableMap,
        ),
        systemPrompt: deserializeParam(
          data['systemPrompt'],
          ParamType.String,
          false,
        ),
      );

  static FinalApiPayloadStructStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      FinalApiPayloadStructStruct(
        messages: convertAlgoliaParam<ApiMessageStructStruct>(
          data['messages'],
          ParamType.DataStruct,
          true,
          structBuilder: ApiMessageStructStruct.fromAlgoliaData,
        ),
        systemPrompt: convertAlgoliaParam(
          data['systemPrompt'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'FinalApiPayloadStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is FinalApiPayloadStructStruct &&
        listEquality.equals(messages, other.messages) &&
        systemPrompt == other.systemPrompt;
  }

  @override
  int get hashCode => const ListEquality().hash([messages, systemPrompt]);
}

FinalApiPayloadStructStruct createFinalApiPayloadStructStruct({
  String? systemPrompt,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    FinalApiPayloadStructStruct(
      systemPrompt: systemPrompt,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

FinalApiPayloadStructStruct? updateFinalApiPayloadStructStruct(
  FinalApiPayloadStructStruct? finalApiPayloadStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    finalApiPayloadStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addFinalApiPayloadStructStructData(
  Map<String, dynamic> firestoreData,
  FinalApiPayloadStructStruct? finalApiPayloadStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (finalApiPayloadStruct == null) {
    return;
  }
  if (finalApiPayloadStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      finalApiPayloadStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final finalApiPayloadStructData = getFinalApiPayloadStructFirestoreData(
      finalApiPayloadStruct, forFieldValue);
  final nestedData =
      finalApiPayloadStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      finalApiPayloadStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getFinalApiPayloadStructFirestoreData(
  FinalApiPayloadStructStruct? finalApiPayloadStruct, [
  bool forFieldValue = false,
]) {
  if (finalApiPayloadStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(finalApiPayloadStruct.toMap());

  // Add any Firestore field values
  finalApiPayloadStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getFinalApiPayloadStructListFirestoreData(
  List<FinalApiPayloadStructStruct>? finalApiPayloadStructs,
) =>
    finalApiPayloadStructs
        ?.map((e) => getFinalApiPayloadStructFirestoreData(e, true))
        .toList() ??
    [];
