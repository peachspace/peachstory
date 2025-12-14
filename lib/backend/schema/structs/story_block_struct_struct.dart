// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class StoryBlockStructStruct extends FFFirebaseStruct {
  StoryBlockStructStruct({
    String? type,
    String? content,
    String? imagePath,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _type = type,
        _content = content,
        _imagePath = imagePath,
        super(firestoreUtilData);

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  set content(String? val) => _content = val;

  bool hasContent() => _content != null;

  // "imagePath" field.
  String? _imagePath;
  String get imagePath => _imagePath ?? '';
  set imagePath(String? val) => _imagePath = val;

  bool hasImagePath() => _imagePath != null;

  static StoryBlockStructStruct fromMap(Map<String, dynamic> data) =>
      StoryBlockStructStruct(
        type: data['type'] as String?,
        content: data['content'] as String?,
        imagePath: data['imagePath'] as String?,
      );

  static StoryBlockStructStruct? maybeFromMap(dynamic data) => data is Map
      ? StoryBlockStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'type': _type,
        'content': _content,
        'imagePath': _imagePath,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
        'content': serializeParam(
          _content,
          ParamType.String,
        ),
        'imagePath': serializeParam(
          _imagePath,
          ParamType.String,
        ),
      }.withoutNulls;

  static StoryBlockStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      StoryBlockStructStruct(
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
        content: deserializeParam(
          data['content'],
          ParamType.String,
          false,
        ),
        imagePath: deserializeParam(
          data['imagePath'],
          ParamType.String,
          false,
        ),
      );

  static StoryBlockStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      StoryBlockStructStruct(
        type: convertAlgoliaParam(
          data['type'],
          ParamType.String,
          false,
        ),
        content: convertAlgoliaParam(
          data['content'],
          ParamType.String,
          false,
        ),
        imagePath: convertAlgoliaParam(
          data['imagePath'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'StoryBlockStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is StoryBlockStructStruct &&
        type == other.type &&
        content == other.content &&
        imagePath == other.imagePath;
  }

  @override
  int get hashCode => const ListEquality().hash([type, content, imagePath]);
}

StoryBlockStructStruct createStoryBlockStructStruct({
  String? type,
  String? content,
  String? imagePath,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    StoryBlockStructStruct(
      type: type,
      content: content,
      imagePath: imagePath,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

StoryBlockStructStruct? updateStoryBlockStructStruct(
  StoryBlockStructStruct? storyBlockStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    storyBlockStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addStoryBlockStructStructData(
  Map<String, dynamic> firestoreData,
  StoryBlockStructStruct? storyBlockStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (storyBlockStruct == null) {
    return;
  }
  if (storyBlockStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && storyBlockStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final storyBlockStructData =
      getStoryBlockStructFirestoreData(storyBlockStruct, forFieldValue);
  final nestedData =
      storyBlockStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = storyBlockStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getStoryBlockStructFirestoreData(
  StoryBlockStructStruct? storyBlockStruct, [
  bool forFieldValue = false,
]) {
  if (storyBlockStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(storyBlockStruct.toMap());

  // Add any Firestore field values
  storyBlockStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getStoryBlockStructListFirestoreData(
  List<StoryBlockStructStruct>? storyBlockStructs,
) =>
    storyBlockStructs
        ?.map((e) => getStoryBlockStructFirestoreData(e, true))
        .toList() ??
    [];
