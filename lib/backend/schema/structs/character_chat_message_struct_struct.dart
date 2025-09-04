// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CharacterChatMessageStructStruct extends FFFirebaseStruct {
  CharacterChatMessageStructStruct({
    String? text,
    String? type,
    bool? isStreaming,
    String? storyImageUrl,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _text = text,
        _type = type,
        _isStreaming = isStreaming,
        _storyImageUrl = storyImageUrl,
        super(firestoreUtilData);

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  // "isStreaming" field.
  bool? _isStreaming;
  bool get isStreaming => _isStreaming ?? false;
  set isStreaming(bool? val) => _isStreaming = val;

  bool hasIsStreaming() => _isStreaming != null;

  // "storyImageUrl" field.
  String? _storyImageUrl;
  String get storyImageUrl => _storyImageUrl ?? '';
  set storyImageUrl(String? val) => _storyImageUrl = val;

  bool hasStoryImageUrl() => _storyImageUrl != null;

  static CharacterChatMessageStructStruct fromMap(Map<String, dynamic> data) =>
      CharacterChatMessageStructStruct(
        text: data['text'] as String?,
        type: data['type'] as String?,
        isStreaming: data['isStreaming'] as bool?,
        storyImageUrl: data['storyImageUrl'] as String?,
      );

  static CharacterChatMessageStructStruct? maybeFromMap(dynamic data) => data
          is Map
      ? CharacterChatMessageStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'text': _text,
        'type': _type,
        'isStreaming': _isStreaming,
        'storyImageUrl': _storyImageUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
        'isStreaming': serializeParam(
          _isStreaming,
          ParamType.bool,
        ),
        'storyImageUrl': serializeParam(
          _storyImageUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static CharacterChatMessageStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      CharacterChatMessageStructStruct(
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
        isStreaming: deserializeParam(
          data['isStreaming'],
          ParamType.bool,
          false,
        ),
        storyImageUrl: deserializeParam(
          data['storyImageUrl'],
          ParamType.String,
          false,
        ),
      );

  static CharacterChatMessageStructStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      CharacterChatMessageStructStruct(
        text: convertAlgoliaParam(
          data['text'],
          ParamType.String,
          false,
        ),
        type: convertAlgoliaParam(
          data['type'],
          ParamType.String,
          false,
        ),
        isStreaming: convertAlgoliaParam(
          data['isStreaming'],
          ParamType.bool,
          false,
        ),
        storyImageUrl: convertAlgoliaParam(
          data['storyImageUrl'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'CharacterChatMessageStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CharacterChatMessageStructStruct &&
        text == other.text &&
        type == other.type &&
        isStreaming == other.isStreaming &&
        storyImageUrl == other.storyImageUrl;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([text, type, isStreaming, storyImageUrl]);
}

CharacterChatMessageStructStruct createCharacterChatMessageStructStruct({
  String? text,
  String? type,
  bool? isStreaming,
  String? storyImageUrl,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CharacterChatMessageStructStruct(
      text: text,
      type: type,
      isStreaming: isStreaming,
      storyImageUrl: storyImageUrl,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CharacterChatMessageStructStruct? updateCharacterChatMessageStructStruct(
  CharacterChatMessageStructStruct? characterChatMessageStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    characterChatMessageStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCharacterChatMessageStructStructData(
  Map<String, dynamic> firestoreData,
  CharacterChatMessageStructStruct? characterChatMessageStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (characterChatMessageStruct == null) {
    return;
  }
  if (characterChatMessageStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      characterChatMessageStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final characterChatMessageStructData =
      getCharacterChatMessageStructFirestoreData(
          characterChatMessageStruct, forFieldValue);
  final nestedData = characterChatMessageStructData
      .map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      characterChatMessageStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCharacterChatMessageStructFirestoreData(
  CharacterChatMessageStructStruct? characterChatMessageStruct, [
  bool forFieldValue = false,
]) {
  if (characterChatMessageStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(characterChatMessageStruct.toMap());

  // Add any Firestore field values
  characterChatMessageStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCharacterChatMessageStructListFirestoreData(
  List<CharacterChatMessageStructStruct>? characterChatMessageStructs,
) =>
    characterChatMessageStructs
        ?.map((e) => getCharacterChatMessageStructFirestoreData(e, true))
        .toList() ??
    [];
