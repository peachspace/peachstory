// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PromptBlockStruct extends FFFirebaseStruct {
  PromptBlockStruct({
    String? type,
    String? text,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _type = type,
        _text = text,
        super(firestoreUtilData);

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  static PromptBlockStruct fromMap(Map<String, dynamic> data) =>
      PromptBlockStruct(
        type: data['type'] as String?,
        text: data['text'] as String?,
      );

  static PromptBlockStruct? maybeFromMap(dynamic data) => data is Map
      ? PromptBlockStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'type': _type,
        'text': _text,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
      }.withoutNulls;

  static PromptBlockStruct fromSerializableMap(Map<String, dynamic> data) =>
      PromptBlockStruct(
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
      );

  static PromptBlockStruct fromAlgoliaData(Map<String, dynamic> data) =>
      PromptBlockStruct(
        type: convertAlgoliaParam(
          data['type'],
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
  String toString() => 'PromptBlockStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PromptBlockStruct &&
        type == other.type &&
        text == other.text;
  }

  @override
  int get hashCode => const ListEquality().hash([type, text]);
}

PromptBlockStruct createPromptBlockStruct({
  String? type,
  String? text,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    PromptBlockStruct(
      type: type,
      text: text,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

PromptBlockStruct? updatePromptBlockStruct(
  PromptBlockStruct? promptBlock, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    promptBlock
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPromptBlockStructData(
  Map<String, dynamic> firestoreData,
  PromptBlockStruct? promptBlock,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (promptBlock == null) {
    return;
  }
  if (promptBlock.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && promptBlock.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final promptBlockData =
      getPromptBlockFirestoreData(promptBlock, forFieldValue);
  final nestedData =
      promptBlockData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = promptBlock.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPromptBlockFirestoreData(
  PromptBlockStruct? promptBlock, [
  bool forFieldValue = false,
]) {
  if (promptBlock == null) {
    return {};
  }
  final firestoreData = mapToFirestore(promptBlock.toMap());

  // Add any Firestore field values
  promptBlock.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPromptBlockListFirestoreData(
  List<PromptBlockStruct>? promptBlocks,
) =>
    promptBlocks?.map((e) => getPromptBlockFirestoreData(e, true)).toList() ??
    [];
