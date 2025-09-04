// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ParsedMultiMessageOutputStruct extends FFFirebaseStruct {
  ParsedMultiMessageOutputStruct({
    List<ChatMessageStructStruct>? parsedMessages,
    String? finalNextAction,
    bool? errorOccurred,
    String? errorMessage,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _parsedMessages = parsedMessages,
        _finalNextAction = finalNextAction,
        _errorOccurred = errorOccurred,
        _errorMessage = errorMessage,
        super(firestoreUtilData);

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

  // "finalNextAction" field.
  String? _finalNextAction;
  String get finalNextAction => _finalNextAction ?? '';
  set finalNextAction(String? val) => _finalNextAction = val;

  bool hasFinalNextAction() => _finalNextAction != null;

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

  static ParsedMultiMessageOutputStruct fromMap(Map<String, dynamic> data) =>
      ParsedMultiMessageOutputStruct(
        parsedMessages: getStructList(
          data['parsedMessages'],
          ChatMessageStructStruct.fromMap,
        ),
        finalNextAction: data['finalNextAction'] as String?,
        errorOccurred: data['errorOccurred'] as bool?,
        errorMessage: data['errorMessage'] as String?,
      );

  static ParsedMultiMessageOutputStruct? maybeFromMap(dynamic data) =>
      data is Map
          ? ParsedMultiMessageOutputStruct.fromMap(data.cast<String, dynamic>())
          : null;

  Map<String, dynamic> toMap() => {
        'parsedMessages': _parsedMessages?.map((e) => e.toMap()).toList(),
        'finalNextAction': _finalNextAction,
        'errorOccurred': _errorOccurred,
        'errorMessage': _errorMessage,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'parsedMessages': serializeParam(
          _parsedMessages,
          ParamType.DataStruct,
          isList: true,
        ),
        'finalNextAction': serializeParam(
          _finalNextAction,
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
      }.withoutNulls;

  static ParsedMultiMessageOutputStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ParsedMultiMessageOutputStruct(
        parsedMessages: deserializeStructParam<ChatMessageStructStruct>(
          data['parsedMessages'],
          ParamType.DataStruct,
          true,
          structBuilder: ChatMessageStructStruct.fromSerializableMap,
        ),
        finalNextAction: deserializeParam(
          data['finalNextAction'],
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
      );

  static ParsedMultiMessageOutputStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      ParsedMultiMessageOutputStruct(
        parsedMessages: convertAlgoliaParam<ChatMessageStructStruct>(
          data['parsedMessages'],
          ParamType.DataStruct,
          true,
          structBuilder: ChatMessageStructStruct.fromAlgoliaData,
        ),
        finalNextAction: convertAlgoliaParam(
          data['finalNextAction'],
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
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'ParsedMultiMessageOutputStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ParsedMultiMessageOutputStruct &&
        listEquality.equals(parsedMessages, other.parsedMessages) &&
        finalNextAction == other.finalNextAction &&
        errorOccurred == other.errorOccurred &&
        errorMessage == other.errorMessage;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([parsedMessages, finalNextAction, errorOccurred, errorMessage]);
}

ParsedMultiMessageOutputStruct createParsedMultiMessageOutputStruct({
  String? finalNextAction,
  bool? errorOccurred,
  String? errorMessage,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ParsedMultiMessageOutputStruct(
      finalNextAction: finalNextAction,
      errorOccurred: errorOccurred,
      errorMessage: errorMessage,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ParsedMultiMessageOutputStruct? updateParsedMultiMessageOutputStruct(
  ParsedMultiMessageOutputStruct? parsedMultiMessageOutput, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    parsedMultiMessageOutput
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addParsedMultiMessageOutputStructData(
  Map<String, dynamic> firestoreData,
  ParsedMultiMessageOutputStruct? parsedMultiMessageOutput,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (parsedMultiMessageOutput == null) {
    return;
  }
  if (parsedMultiMessageOutput.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      parsedMultiMessageOutput.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final parsedMultiMessageOutputData = getParsedMultiMessageOutputFirestoreData(
      parsedMultiMessageOutput, forFieldValue);
  final nestedData =
      parsedMultiMessageOutputData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      parsedMultiMessageOutput.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getParsedMultiMessageOutputFirestoreData(
  ParsedMultiMessageOutputStruct? parsedMultiMessageOutput, [
  bool forFieldValue = false,
]) {
  if (parsedMultiMessageOutput == null) {
    return {};
  }
  final firestoreData = mapToFirestore(parsedMultiMessageOutput.toMap());

  // Add any Firestore field values
  parsedMultiMessageOutput.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getParsedMultiMessageOutputListFirestoreData(
  List<ParsedMultiMessageOutputStruct>? parsedMultiMessageOutputs,
) =>
    parsedMultiMessageOutputs
        ?.map((e) => getParsedMultiMessageOutputFirestoreData(e, true))
        .toList() ??
    [];
