// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StoryChatMessageStructStruct extends FFFirebaseStruct {
  StoryChatMessageStructStruct({
    String? text,
    String? type,
    bool? isStreaming,
    String? speakerName,
    String? speakerImage,
    String? actionText,
    String? storyImageUrl,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _text = text,
        _type = type,
        _isStreaming = isStreaming,
        _speakerName = speakerName,
        _speakerImage = speakerImage,
        _actionText = actionText,
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

  // "speakerName" field.
  String? _speakerName;
  String get speakerName => _speakerName ?? '';
  set speakerName(String? val) => _speakerName = val;

  bool hasSpeakerName() => _speakerName != null;

  // "speakerImage" field.
  String? _speakerImage;
  String get speakerImage => _speakerImage ?? '';
  set speakerImage(String? val) => _speakerImage = val;

  bool hasSpeakerImage() => _speakerImage != null;

  // "actionText" field.
  String? _actionText;
  String get actionText => _actionText ?? '';
  set actionText(String? val) => _actionText = val;

  bool hasActionText() => _actionText != null;

  // "storyImageUrl" field.
  String? _storyImageUrl;
  String get storyImageUrl => _storyImageUrl ?? '';
  set storyImageUrl(String? val) => _storyImageUrl = val;

  bool hasStoryImageUrl() => _storyImageUrl != null;

  static StoryChatMessageStructStruct fromMap(Map<String, dynamic> data) =>
      StoryChatMessageStructStruct(
        text: data['text'] as String?,
        type: data['type'] as String?,
        isStreaming: data['isStreaming'] as bool?,
        speakerName: data['speakerName'] as String?,
        speakerImage: data['speakerImage'] as String?,
        actionText: data['actionText'] as String?,
        storyImageUrl: data['storyImageUrl'] as String?,
      );

  static StoryChatMessageStructStruct? maybeFromMap(dynamic data) => data is Map
      ? StoryChatMessageStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'text': _text,
        'type': _type,
        'isStreaming': _isStreaming,
        'speakerName': _speakerName,
        'speakerImage': _speakerImage,
        'actionText': _actionText,
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
        'speakerName': serializeParam(
          _speakerName,
          ParamType.String,
        ),
        'speakerImage': serializeParam(
          _speakerImage,
          ParamType.String,
        ),
        'actionText': serializeParam(
          _actionText,
          ParamType.String,
        ),
        'storyImageUrl': serializeParam(
          _storyImageUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static StoryChatMessageStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      StoryChatMessageStructStruct(
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
        speakerName: deserializeParam(
          data['speakerName'],
          ParamType.String,
          false,
        ),
        speakerImage: deserializeParam(
          data['speakerImage'],
          ParamType.String,
          false,
        ),
        actionText: deserializeParam(
          data['actionText'],
          ParamType.String,
          false,
        ),
        storyImageUrl: deserializeParam(
          data['storyImageUrl'],
          ParamType.String,
          false,
        ),
      );

  static StoryChatMessageStructStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      StoryChatMessageStructStruct(
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
        speakerName: convertAlgoliaParam(
          data['speakerName'],
          ParamType.String,
          false,
        ),
        speakerImage: convertAlgoliaParam(
          data['speakerImage'],
          ParamType.String,
          false,
        ),
        actionText: convertAlgoliaParam(
          data['actionText'],
          ParamType.String,
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
  String toString() => 'StoryChatMessageStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is StoryChatMessageStructStruct &&
        text == other.text &&
        type == other.type &&
        isStreaming == other.isStreaming &&
        speakerName == other.speakerName &&
        speakerImage == other.speakerImage &&
        actionText == other.actionText &&
        storyImageUrl == other.storyImageUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([
        text,
        type,
        isStreaming,
        speakerName,
        speakerImage,
        actionText,
        storyImageUrl
      ]);
}

StoryChatMessageStructStruct createStoryChatMessageStructStruct({
  String? text,
  String? type,
  bool? isStreaming,
  String? speakerName,
  String? speakerImage,
  String? actionText,
  String? storyImageUrl,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    StoryChatMessageStructStruct(
      text: text,
      type: type,
      isStreaming: isStreaming,
      speakerName: speakerName,
      speakerImage: speakerImage,
      actionText: actionText,
      storyImageUrl: storyImageUrl,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

StoryChatMessageStructStruct? updateStoryChatMessageStructStruct(
  StoryChatMessageStructStruct? storyChatMessageStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    storyChatMessageStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addStoryChatMessageStructStructData(
  Map<String, dynamic> firestoreData,
  StoryChatMessageStructStruct? storyChatMessageStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (storyChatMessageStruct == null) {
    return;
  }
  if (storyChatMessageStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      storyChatMessageStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final storyChatMessageStructData = getStoryChatMessageStructFirestoreData(
      storyChatMessageStruct, forFieldValue);
  final nestedData =
      storyChatMessageStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      storyChatMessageStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getStoryChatMessageStructFirestoreData(
  StoryChatMessageStructStruct? storyChatMessageStruct, [
  bool forFieldValue = false,
]) {
  if (storyChatMessageStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(storyChatMessageStruct.toMap());

  // Add any Firestore field values
  storyChatMessageStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getStoryChatMessageStructListFirestoreData(
  List<StoryChatMessageStructStruct>? storyChatMessageStructs,
) =>
    storyChatMessageStructs
        ?.map((e) => getStoryChatMessageStructFirestoreData(e, true))
        .toList() ??
    [];
