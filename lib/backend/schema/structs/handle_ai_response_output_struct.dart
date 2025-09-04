// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HandleAiResponseOutputStruct extends FFFirebaseStruct {
  HandleAiResponseOutputStruct({
    String? nextAction,
    bool? errorOccurred,
    String? errorMessage,
    List<ChatMessageStructStruct>? parsedMessages,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _nextAction = nextAction,
        _errorOccurred = errorOccurred,
        _errorMessage = errorMessage,
        _parsedMessages = parsedMessages,
        super(firestoreUtilData);

  // "nextAction" field.
  String? _nextAction;
  String get nextAction => _nextAction ?? '';
  set nextAction(String? val) => _nextAction = val;

  bool hasNextAction() => _nextAction != null;

  // "errorOccurred" field.
  bool? _errorOccurred;
  bool get errorOccurred => _errorOccurred ?? false;
  set errorOccurred(bool? val) => _errorOccurred = val;

  bool hasErrorOccurred() => _errorOccurred != null;

  // "errorMessage" field.
  String? _errorMessage;
  String get errorMessage => _errorMessage ?? '';
  set errorMessage(String? val) => _errorMessage = val;

  bool hasErrorMessage() => _errorMessage != null;

  // "parsedMessages" field.
  List<ChatMessageStructStruct>? _parsedMessages;
  List<ChatMessageStructStruct> get parsedMessages =>
      _parsedMessages ?? const [];
  set parsedMessages(List<ChatMessageStructStruct>? val) =>
      _parsedMessages = val;

  void updateParsedMessages(Function(List<ChatMessageStructStruct>) updateFn) {
    updateFn(_parsedMessages ??= []);
  }

  bool hasParsedMessages() => _parsedMessages != null;

  static HandleAiResponseOutputStruct fromMap(Map<String, dynamic> data) =>
      HandleAiResponseOutputStruct(
        nextAction: data['nextAction'] as String?,
        errorOccurred: data['errorOccurred'] as bool?,
        errorMessage: data['errorMessage'] as String?,
        parsedMessages: getStructList(
          data['parsedMessages'],
          ChatMessageStructStruct.fromMap,
        ),
      );

  static HandleAiResponseOutputStruct? maybeFromMap(dynamic data) => data is Map
      ? HandleAiResponseOutputStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'nextAction': _nextAction,
        'errorOccurred': _errorOccurred,
        'errorMessage': _errorMessage,
        'parsedMessages': _parsedMessages?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'nextAction': serializeParam(
          _nextAction,
          ParamType.String,
        ),
        'errorOccurred': serializeParam(
          _errorOccurred,
          ParamType.bool,
        ),
        'errorMessage': serializeParam(
          _errorMessage,
          ParamType.String,
        ),
        'parsedMessages': serializeParam(
          _parsedMessages,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static HandleAiResponseOutputStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      HandleAiResponseOutputStruct(
        nextAction: deserializeParam(
          data['nextAction'],
          ParamType.String,
          false,
        ),
        errorOccurred: deserializeParam(
          data['errorOccurred'],
          ParamType.bool,
          false,
        ),
        errorMessage: deserializeParam(
          data['errorMessage'],
          ParamType.String,
          false,
        ),
        parsedMessages: deserializeStructParam<ChatMessageStructStruct>(
          data['parsedMessages'],
          ParamType.DataStruct,
          true,
          structBuilder: ChatMessageStructStruct.fromSerializableMap,
        ),
      );

  static HandleAiResponseOutputStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      HandleAiResponseOutputStruct(
        nextAction: convertAlgoliaParam(
          data['nextAction'],
          ParamType.String,
          false,
        ),
        errorOccurred: convertAlgoliaParam(
          data['errorOccurred'],
          ParamType.bool,
          false,
        ),
        errorMessage: convertAlgoliaParam(
          data['errorMessage'],
          ParamType.String,
          false,
        ),
        parsedMessages: convertAlgoliaParam<ChatMessageStructStruct>(
          data['parsedMessages'],
          ParamType.DataStruct,
          true,
          structBuilder: ChatMessageStructStruct.fromAlgoliaData,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'HandleAiResponseOutputStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is HandleAiResponseOutputStruct &&
        nextAction == other.nextAction &&
        errorOccurred == other.errorOccurred &&
        errorMessage == other.errorMessage &&
        listEquality.equals(parsedMessages, other.parsedMessages);
  }

  @override
  int get hashCode => const ListEquality()
      .hash([nextAction, errorOccurred, errorMessage, parsedMessages]);
}

HandleAiResponseOutputStruct createHandleAiResponseOutputStruct({
  String? nextAction,
  bool? errorOccurred,
  String? errorMessage,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    HandleAiResponseOutputStruct(
      nextAction: nextAction,
      errorOccurred: errorOccurred,
      errorMessage: errorMessage,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

HandleAiResponseOutputStruct? updateHandleAiResponseOutputStruct(
  HandleAiResponseOutputStruct? handleAiResponseOutput, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    handleAiResponseOutput
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addHandleAiResponseOutputStructData(
  Map<String, dynamic> firestoreData,
  HandleAiResponseOutputStruct? handleAiResponseOutput,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (handleAiResponseOutput == null) {
    return;
  }
  if (handleAiResponseOutput.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      handleAiResponseOutput.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final handleAiResponseOutputData = getHandleAiResponseOutputFirestoreData(
      handleAiResponseOutput, forFieldValue);
  final nestedData =
      handleAiResponseOutputData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      handleAiResponseOutput.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getHandleAiResponseOutputFirestoreData(
  HandleAiResponseOutputStruct? handleAiResponseOutput, [
  bool forFieldValue = false,
]) {
  if (handleAiResponseOutput == null) {
    return {};
  }
  final firestoreData = mapToFirestore(handleAiResponseOutput.toMap());

  // Add any Firestore field values
  handleAiResponseOutput.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getHandleAiResponseOutputListFirestoreData(
  List<HandleAiResponseOutputStruct>? handleAiResponseOutputs,
) =>
    handleAiResponseOutputs
        ?.map((e) => getHandleAiResponseOutputFirestoreData(e, true))
        .toList() ??
    [];
