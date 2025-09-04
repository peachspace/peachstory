// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CombinedListItemStructStruct extends FFFirebaseStruct {
  CombinedListItemStructStruct({
    String? type,
    String? title,
    String? imageUrl,
    DateTime? timestamp,
    DocumentReference? characterRef,
    DocumentReference? storyRef,
    String? category,
    String? userRole,
    String? introduction,
    int? viewCount,
    int? heartCount,
    String? creatorNickname,
    List<String>? hashtags,
    DocumentReference? creatorRef,
    bool? authorIsCreator,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _type = type,
        _title = title,
        _imageUrl = imageUrl,
        _timestamp = timestamp,
        _characterRef = characterRef,
        _storyRef = storyRef,
        _category = category,
        _userRole = userRole,
        _introduction = introduction,
        _viewCount = viewCount,
        _heartCount = heartCount,
        _creatorNickname = creatorNickname,
        _hashtags = hashtags,
        _creatorRef = creatorRef,
        _authorIsCreator = authorIsCreator,
        super(firestoreUtilData);

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  set timestamp(DateTime? val) => _timestamp = val;

  bool hasTimestamp() => _timestamp != null;

  // "characterRef" field.
  DocumentReference? _characterRef;
  DocumentReference? get characterRef => _characterRef;
  set characterRef(DocumentReference? val) => _characterRef = val;

  bool hasCharacterRef() => _characterRef != null;

  // "storyRef" field.
  DocumentReference? _storyRef;
  DocumentReference? get storyRef => _storyRef;
  set storyRef(DocumentReference? val) => _storyRef = val;

  bool hasStoryRef() => _storyRef != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  set category(String? val) => _category = val;

  bool hasCategory() => _category != null;

  // "userRole" field.
  String? _userRole;
  String get userRole => _userRole ?? '';
  set userRole(String? val) => _userRole = val;

  bool hasUserRole() => _userRole != null;

  // "introduction" field.
  String? _introduction;
  String get introduction => _introduction ?? '';
  set introduction(String? val) => _introduction = val;

  bool hasIntroduction() => _introduction != null;

  // "viewCount" field.
  int? _viewCount;
  int get viewCount => _viewCount ?? 0;
  set viewCount(int? val) => _viewCount = val;

  void incrementViewCount(int amount) => viewCount = viewCount + amount;

  bool hasViewCount() => _viewCount != null;

  // "heartCount" field.
  int? _heartCount;
  int get heartCount => _heartCount ?? 0;
  set heartCount(int? val) => _heartCount = val;

  void incrementHeartCount(int amount) => heartCount = heartCount + amount;

  bool hasHeartCount() => _heartCount != null;

  // "creatorNickname" field.
  String? _creatorNickname;
  String get creatorNickname => _creatorNickname ?? '';
  set creatorNickname(String? val) => _creatorNickname = val;

  bool hasCreatorNickname() => _creatorNickname != null;

  // "hashtags" field.
  List<String>? _hashtags;
  List<String> get hashtags => _hashtags ?? const [];
  set hashtags(List<String>? val) => _hashtags = val;

  void updateHashtags(Function(List<String>) updateFn) {
    updateFn(_hashtags ??= []);
  }

  bool hasHashtags() => _hashtags != null;

  // "creatorRef" field.
  DocumentReference? _creatorRef;
  DocumentReference? get creatorRef => _creatorRef;
  set creatorRef(DocumentReference? val) => _creatorRef = val;

  bool hasCreatorRef() => _creatorRef != null;

  // "authorIsCreator" field.
  bool? _authorIsCreator;
  bool get authorIsCreator => _authorIsCreator ?? false;
  set authorIsCreator(bool? val) => _authorIsCreator = val;

  bool hasAuthorIsCreator() => _authorIsCreator != null;

  static CombinedListItemStructStruct fromMap(Map<String, dynamic> data) =>
      CombinedListItemStructStruct(
        type: data['type'] as String?,
        title: data['title'] as String?,
        imageUrl: data['imageUrl'] as String?,
        timestamp: data['timestamp'] as DateTime?,
        characterRef: data['characterRef'] as DocumentReference?,
        storyRef: data['storyRef'] as DocumentReference?,
        category: data['category'] as String?,
        userRole: data['userRole'] as String?,
        introduction: data['introduction'] as String?,
        viewCount: castToType<int>(data['viewCount']),
        heartCount: castToType<int>(data['heartCount']),
        creatorNickname: data['creatorNickname'] as String?,
        hashtags: getDataList(data['hashtags']),
        creatorRef: data['creatorRef'] as DocumentReference?,
        authorIsCreator: data['authorIsCreator'] as bool?,
      );

  static CombinedListItemStructStruct? maybeFromMap(dynamic data) => data is Map
      ? CombinedListItemStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'type': _type,
        'title': _title,
        'imageUrl': _imageUrl,
        'timestamp': _timestamp,
        'characterRef': _characterRef,
        'storyRef': _storyRef,
        'category': _category,
        'userRole': _userRole,
        'introduction': _introduction,
        'viewCount': _viewCount,
        'heartCount': _heartCount,
        'creatorNickname': _creatorNickname,
        'hashtags': _hashtags,
        'creatorRef': _creatorRef,
        'authorIsCreator': _authorIsCreator,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
        'timestamp': serializeParam(
          _timestamp,
          ParamType.DateTime,
        ),
        'characterRef': serializeParam(
          _characterRef,
          ParamType.DocumentReference,
        ),
        'storyRef': serializeParam(
          _storyRef,
          ParamType.DocumentReference,
        ),
        'category': serializeParam(
          _category,
          ParamType.String,
        ),
        'userRole': serializeParam(
          _userRole,
          ParamType.String,
        ),
        'introduction': serializeParam(
          _introduction,
          ParamType.String,
        ),
        'viewCount': serializeParam(
          _viewCount,
          ParamType.int,
        ),
        'heartCount': serializeParam(
          _heartCount,
          ParamType.int,
        ),
        'creatorNickname': serializeParam(
          _creatorNickname,
          ParamType.String,
        ),
        'hashtags': serializeParam(
          _hashtags,
          ParamType.String,
          isList: true,
        ),
        'creatorRef': serializeParam(
          _creatorRef,
          ParamType.DocumentReference,
        ),
        'authorIsCreator': serializeParam(
          _authorIsCreator,
          ParamType.bool,
        ),
      }.withoutNulls;

  static CombinedListItemStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      CombinedListItemStructStruct(
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        timestamp: deserializeParam(
          data['timestamp'],
          ParamType.DateTime,
          false,
        ),
        characterRef: deserializeParam(
          data['characterRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['character'],
        ),
        storyRef: deserializeParam(
          data['storyRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['stories'],
        ),
        category: deserializeParam(
          data['category'],
          ParamType.String,
          false,
        ),
        userRole: deserializeParam(
          data['userRole'],
          ParamType.String,
          false,
        ),
        introduction: deserializeParam(
          data['introduction'],
          ParamType.String,
          false,
        ),
        viewCount: deserializeParam(
          data['viewCount'],
          ParamType.int,
          false,
        ),
        heartCount: deserializeParam(
          data['heartCount'],
          ParamType.int,
          false,
        ),
        creatorNickname: deserializeParam(
          data['creatorNickname'],
          ParamType.String,
          false,
        ),
        hashtags: deserializeParam<String>(
          data['hashtags'],
          ParamType.String,
          true,
        ),
        creatorRef: deserializeParam(
          data['creatorRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['users'],
        ),
        authorIsCreator: deserializeParam(
          data['authorIsCreator'],
          ParamType.bool,
          false,
        ),
      );

  static CombinedListItemStructStruct fromAlgoliaData(
          Map<String, dynamic> data) =>
      CombinedListItemStructStruct(
        type: convertAlgoliaParam(
          data['type'],
          ParamType.String,
          false,
        ),
        title: convertAlgoliaParam(
          data['title'],
          ParamType.String,
          false,
        ),
        imageUrl: convertAlgoliaParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        timestamp: convertAlgoliaParam(
          data['timestamp'],
          ParamType.DateTime,
          false,
        ),
        characterRef: convertAlgoliaParam(
          data['characterRef'],
          ParamType.DocumentReference,
          false,
        ),
        storyRef: convertAlgoliaParam(
          data['storyRef'],
          ParamType.DocumentReference,
          false,
        ),
        category: convertAlgoliaParam(
          data['category'],
          ParamType.String,
          false,
        ),
        userRole: convertAlgoliaParam(
          data['userRole'],
          ParamType.String,
          false,
        ),
        introduction: convertAlgoliaParam(
          data['introduction'],
          ParamType.String,
          false,
        ),
        viewCount: convertAlgoliaParam(
          data['viewCount'],
          ParamType.int,
          false,
        ),
        heartCount: convertAlgoliaParam(
          data['heartCount'],
          ParamType.int,
          false,
        ),
        creatorNickname: convertAlgoliaParam(
          data['creatorNickname'],
          ParamType.String,
          false,
        ),
        hashtags: convertAlgoliaParam<String>(
          data['hashtags'],
          ParamType.String,
          true,
        ),
        creatorRef: convertAlgoliaParam(
          data['creatorRef'],
          ParamType.DocumentReference,
          false,
        ),
        authorIsCreator: convertAlgoliaParam(
          data['authorIsCreator'],
          ParamType.bool,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'CombinedListItemStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is CombinedListItemStructStruct &&
        type == other.type &&
        title == other.title &&
        imageUrl == other.imageUrl &&
        timestamp == other.timestamp &&
        characterRef == other.characterRef &&
        storyRef == other.storyRef &&
        category == other.category &&
        userRole == other.userRole &&
        introduction == other.introduction &&
        viewCount == other.viewCount &&
        heartCount == other.heartCount &&
        creatorNickname == other.creatorNickname &&
        listEquality.equals(hashtags, other.hashtags) &&
        creatorRef == other.creatorRef &&
        authorIsCreator == other.authorIsCreator;
  }

  @override
  int get hashCode => const ListEquality().hash([
        type,
        title,
        imageUrl,
        timestamp,
        characterRef,
        storyRef,
        category,
        userRole,
        introduction,
        viewCount,
        heartCount,
        creatorNickname,
        hashtags,
        creatorRef,
        authorIsCreator
      ]);
}

CombinedListItemStructStruct createCombinedListItemStructStruct({
  String? type,
  String? title,
  String? imageUrl,
  DateTime? timestamp,
  DocumentReference? characterRef,
  DocumentReference? storyRef,
  String? category,
  String? userRole,
  String? introduction,
  int? viewCount,
  int? heartCount,
  String? creatorNickname,
  DocumentReference? creatorRef,
  bool? authorIsCreator,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CombinedListItemStructStruct(
      type: type,
      title: title,
      imageUrl: imageUrl,
      timestamp: timestamp,
      characterRef: characterRef,
      storyRef: storyRef,
      category: category,
      userRole: userRole,
      introduction: introduction,
      viewCount: viewCount,
      heartCount: heartCount,
      creatorNickname: creatorNickname,
      creatorRef: creatorRef,
      authorIsCreator: authorIsCreator,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CombinedListItemStructStruct? updateCombinedListItemStructStruct(
  CombinedListItemStructStruct? combinedListItemStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    combinedListItemStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCombinedListItemStructStructData(
  Map<String, dynamic> firestoreData,
  CombinedListItemStructStruct? combinedListItemStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (combinedListItemStruct == null) {
    return;
  }
  if (combinedListItemStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      combinedListItemStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final combinedListItemStructData = getCombinedListItemStructFirestoreData(
      combinedListItemStruct, forFieldValue);
  final nestedData =
      combinedListItemStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      combinedListItemStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCombinedListItemStructFirestoreData(
  CombinedListItemStructStruct? combinedListItemStruct, [
  bool forFieldValue = false,
]) {
  if (combinedListItemStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(combinedListItemStruct.toMap());

  // Add any Firestore field values
  combinedListItemStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCombinedListItemStructListFirestoreData(
  List<CombinedListItemStructStruct>? combinedListItemStructs,
) =>
    combinedListItemStructs
        ?.map((e) => getCombinedListItemStructFirestoreData(e, true))
        .toList() ??
    [];
