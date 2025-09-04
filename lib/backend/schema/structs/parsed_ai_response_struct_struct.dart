// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ParsedAiResponseStructStruct extends FFFirebaseStruct {
  ParsedAiResponseStructStruct({
    ChatMessageStructStruct? message,
    String? nextActionType,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _message = message,
        _nextActionType = nextActionType,
        super(firestoreUtilData);

  // "message" field.
  ChatMessageStructStruct? _message;
  ChatMessageStructStruct get message => _message ?? ChatMessageStructStruct();
  set message(ChatMessageStructStruct? val) => _message = val;

  void updateMessage(Function(ChatMessageStructStruct) updateFn) {
    updateFn(_message ??= ChatMessageStructStruct());
  }

  bool hasMessage() => _message != null;

  // "nextActionType" field.
  String? _nextActionType;
  String get nextActionType => _nextActionType ?? '';
  set nextActionType(String? val) => _nextActionType = val;

  bool hasNextActionType() => _nextActionType != null;

  static ParsedAiResponseStructStruct fromMap(Map<String, dynamic> data) =>
      ParsedAiResponseStructStruct(
        message: data['message'] is ChatMessageStructStruct
            ? data['message']
            : ChatMessageStructStruct.maybeFromMap(data['message']),
        nextActionType: data['nextActionType'] as String?,
      );

  static ParsedAiResponseStructStruct? maybeFromMap(dynamic data) => data is Map
      ? ParsedAiResponseStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'message': _message?.toMap(),
        'nextActionType': _nextActionType,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'message': serializeParam(
          _message,
          ParamType.DataStruct,
        ),
        'nextActionType': serializeParam(
          _nextActionType,
          ParamType.String,
        ),
      }.withoutNulls;

  static ParsedAiResponseStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ParsedAiResponseStructStruct(
        message: deserializeStructParam(
          data['message'],
          ParamType.DataStruct,
          false,
          structBuilder: ChatMessageStructStruct.fromSerializableMap,
        ),
        nextActionType: deserializeParam(
          data['nextActionType'],
          ParamType.String,
          false,
        ),
      );

  static ParsedAiResponseStructStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      ParsedAiResponseStructStruct(
        message: convertAlgoliaParam(
          data['message'],
          ParamType.DataStruct,
          false,
          structBuilder: ChatMessageStructStruct.fromAlgoliaData,
        ),
        nextActionType: convertAlgoliaParam(
          data['nextActionType'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'ParsedAiResponseStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ParsedAiResponseStructStruct &&
        message == other.message &&
        nextActionType == other.nextActionType;
  }

  @override
  int get hashCode => const ListEquality().hash([message, nextActionType]);
}

ParsedAiResponseStructStruct createParsedAiResponseStructStruct({
  ChatMessageStructStruct? message,
  String? nextActionType,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ParsedAiResponseStructStruct(
      message: message ?? (clearUnsetFields ? ChatMessageStructStruct() : null),
      nextActionType: nextActionType,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ParsedAiResponseStructStruct? updateParsedAiResponseStructStruct(
  ParsedAiResponseStructStruct? parsedAiResponseStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    parsedAiResponseStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addParsedAiResponseStructStructData(
  Map<String, dynamic> firestoreData,
  ParsedAiResponseStructStruct? parsedAiResponseStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (parsedAiResponseStruct == null) {
    return;
  }
  if (parsedAiResponseStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      parsedAiResponseStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final parsedAiResponseStructData = getParsedAiResponseStructFirestoreData(
      parsedAiResponseStruct, forFieldValue);
  final nestedData =
      parsedAiResponseStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      parsedAiResponseStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getParsedAiResponseStructFirestoreData(
  ParsedAiResponseStructStruct? parsedAiResponseStruct, [
  bool forFieldValue = false,
]) {
  if (parsedAiResponseStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(parsedAiResponseStruct.toMap());

  // Handle nested data for "message" field.
  addChatMessageStructStructData(
    firestoreData,
    parsedAiResponseStruct.hasMessage() ? parsedAiResponseStruct.message : null,
    'message',
    forFieldValue,
  );

  // Add any Firestore field values
  parsedAiResponseStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getParsedAiResponseStructListFirestoreData(
  List<ParsedAiResponseStructStruct>? parsedAiResponseStructs,
) =>
    parsedAiResponseStructs
        ?.map((e) => getParsedAiResponseStructFirestoreData(e, true))
        .toList() ??
    [];
