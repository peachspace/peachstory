import 'dart:async';

import '/backend/algolia/serialization_util.dart';
import '/backend/algolia/algolia_manager.dart';
import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StoriesRecord extends FirestoreRecord {
  StoriesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "worldview" field.
  String? _worldview;
  String get worldview => _worldview ?? '';
  bool hasWorldview() => _worldview != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "characters" field.
  List<CharacterStructStruct>? _characters;
  List<CharacterStructStruct> get characters => _characters ?? const [];
  bool hasCharacters() => _characters != null;

  // "creator_ref" field.
  DocumentReference? _creatorRef;
  DocumentReference? get creatorRef => _creatorRef;
  bool hasCreatorRef() => _creatorRef != null;

  // "user_role" field.
  String? _userRole;
  String get userRole => _userRole ?? '';
  bool hasUserRole() => _userRole != null;

  // "main_image" field.
  String? _mainImage;
  String get mainImage => _mainImage ?? '';
  bool hasMainImage() => _mainImage != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "author_notes" field.
  String? _authorNotes;
  String get authorNotes => _authorNotes ?? '';
  bool hasAuthorNotes() => _authorNotes != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "hashtags" field.
  List<String>? _hashtags;
  List<String> get hashtags => _hashtags ?? const [];
  bool hasHashtags() => _hashtags != null;

  // "aiModel" field.
  String? _aiModel;
  String get aiModel => _aiModel ?? '';
  bool hasAiModel() => _aiModel != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "view_count" field.
  int? _viewCount;
  int get viewCount => _viewCount ?? 0;
  bool hasViewCount() => _viewCount != null;

  // "heart_count" field.
  int? _heartCount;
  int get heartCount => _heartCount ?? 0;
  bool hasHeartCount() => _heartCount != null;

  // "creator_nickname" field.
  String? _creatorNickname;
  String get creatorNickname => _creatorNickname ?? '';
  bool hasCreatorNickname() => _creatorNickname != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "authorIsCreator" field.
  bool? _authorIsCreator;
  bool get authorIsCreator => _authorIsCreator ?? false;
  bool hasAuthorIsCreator() => _authorIsCreator != null;

  // "created_timestamp" field.
  DateTime? _createdTimestamp;
  DateTime? get createdTimestamp => _createdTimestamp;
  bool hasCreatedTimestamp() => _createdTimestamp != null;

  // "detailmode" field.
  String? _detailmode;
  String get detailmode => _detailmode ?? '';
  bool hasDetailmode() => _detailmode != null;

  // "backgrounds" field.
  List<BackgroundStructStruct>? _backgrounds;
  List<BackgroundStructStruct> get backgrounds => _backgrounds ?? const [];
  bool hasBackgrounds() => _backgrounds != null;

  // "prologuetext" field.
  String? _prologuetext;
  String get prologuetext => _prologuetext ?? '';
  bool hasProloguetext() => _prologuetext != null;

  // "place" field.
  String? _place;
  String get place => _place ?? '';
  bool hasPlace() => _place != null;

  // "event" field.
  String? _event;
  String get event => _event ?? '';
  bool hasEvent() => _event != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _worldview = snapshotData['worldview'] as String?;
    _category = snapshotData['category'] as String?;
    _characters = getStructList(
      snapshotData['characters'],
      CharacterStructStruct.fromMap,
    );
    _creatorRef = snapshotData['creator_ref'] as DocumentReference?;
    _userRole = snapshotData['user_role'] as String?;
    _mainImage = snapshotData['main_image'] as String?;
    _description = snapshotData['description'] as String?;
    _authorNotes = snapshotData['author_notes'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _hashtags = getDataList(snapshotData['hashtags']);
    _aiModel = snapshotData['aiModel'] as String?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _viewCount = castToType<int>(snapshotData['view_count']);
    _heartCount = castToType<int>(snapshotData['heart_count']);
    _creatorNickname = snapshotData['creator_nickname'] as String?;
    _type = snapshotData['type'] as String?;
    _authorIsCreator = snapshotData['authorIsCreator'] as bool?;
    _createdTimestamp = snapshotData['created_timestamp'] as DateTime?;
    _detailmode = snapshotData['detailmode'] as String?;
    _backgrounds = getStructList(
      snapshotData['backgrounds'],
      BackgroundStructStruct.fromMap,
    );
    _prologuetext = snapshotData['prologuetext'] as String?;
    _place = snapshotData['place'] as String?;
    _event = snapshotData['event'] as String?;
  }

  static CollectionReference get collection => FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: '(default)')
      .collection('stories');

  static Stream<StoriesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StoriesRecord.fromSnapshot(s));

  static Future<StoriesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StoriesRecord.fromSnapshot(s));

  static StoriesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StoriesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StoriesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StoriesRecord._(reference, mapFromFirestore(data));

  static StoriesRecord fromAlgolia(AlgoliaObjectSnapshot snapshot) =>
      StoriesRecord.getDocumentFromData(
        {
          'title': snapshot.data['title'],
          'worldview': snapshot.data['worldview'],
          'category': snapshot.data['category'],
          'characters': safeGet(
            () => (snapshot.data['characters'] as Iterable)
                .map((d) => CharacterStructStruct.fromAlgoliaData(d).toMap())
                .toList(),
          ),
          'creator_ref': convertAlgoliaParam(
            snapshot.data['creator_ref'],
            ParamType.DocumentReference,
            false,
          ),
          'user_role': snapshot.data['user_role'],
          'main_image': snapshot.data['main_image'],
          'description': snapshot.data['description'],
          'author_notes': snapshot.data['author_notes'],
          'created_at': convertAlgoliaParam(
            snapshot.data['created_at'],
            ParamType.DateTime,
            false,
          ),
          'hashtags': safeGet(
            () => snapshot.data['hashtags'].toList(),
          ),
          'aiModel': snapshot.data['aiModel'],
          'user_ref': convertAlgoliaParam(
            snapshot.data['user_ref'],
            ParamType.DocumentReference,
            false,
          ),
          'view_count': convertAlgoliaParam(
            snapshot.data['view_count'],
            ParamType.int,
            false,
          ),
          'heart_count': convertAlgoliaParam(
            snapshot.data['heart_count'],
            ParamType.int,
            false,
          ),
          'creator_nickname': snapshot.data['creator_nickname'],
          'type': snapshot.data['type'],
          'authorIsCreator': snapshot.data['authorIsCreator'],
          'created_timestamp': convertAlgoliaParam(
            snapshot.data['created_timestamp'],
            ParamType.DateTime,
            false,
          ),
          'detailmode': snapshot.data['detailmode'],
          'backgrounds': safeGet(
            () => (snapshot.data['backgrounds'] as Iterable)
                .map((d) => BackgroundStructStruct.fromAlgoliaData(d).toMap())
                .toList(),
          ),
          'prologuetext': snapshot.data['prologuetext'],
          'place': snapshot.data['place'],
          'event': snapshot.data['event'],
        },
        StoriesRecord.collection.doc(snapshot.objectID),
      );

  static Future<List<StoriesRecord>> search({
    String? term,
    FutureOr<LatLng>? location,
    int? maxResults,
    double? searchRadiusMeters,
    bool useCache = false,
  }) =>
      FFAlgoliaManager.instance
          .algoliaQuery(
            index: 'stories',
            term: term,
            maxResults: maxResults,
            location: location,
            searchRadiusMeters: searchRadiusMeters,
            useCache: useCache,
          )
          .then((r) => r.map(fromAlgolia).toList());

  @override
  String toString() =>
      'StoriesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StoriesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStoriesRecordData({
  String? title,
  String? worldview,
  String? category,
  DocumentReference? creatorRef,
  String? userRole,
  String? mainImage,
  String? description,
  String? authorNotes,
  DateTime? createdAt,
  String? aiModel,
  DocumentReference? userRef,
  int? viewCount,
  int? heartCount,
  String? creatorNickname,
  String? type,
  bool? authorIsCreator,
  DateTime? createdTimestamp,
  String? detailmode,
  String? prologuetext,
  String? place,
  String? event,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'worldview': worldview,
      'category': category,
      'creator_ref': creatorRef,
      'user_role': userRole,
      'main_image': mainImage,
      'description': description,
      'author_notes': authorNotes,
      'created_at': createdAt,
      'aiModel': aiModel,
      'user_ref': userRef,
      'view_count': viewCount,
      'heart_count': heartCount,
      'creator_nickname': creatorNickname,
      'type': type,
      'authorIsCreator': authorIsCreator,
      'created_timestamp': createdTimestamp,
      'detailmode': detailmode,
      'prologuetext': prologuetext,
      'place': place,
      'event': event,
    }.withoutNulls,
  );

  return firestoreData;
}

class StoriesRecordDocumentEquality implements Equality<StoriesRecord> {
  const StoriesRecordDocumentEquality();

  @override
  bool equals(StoriesRecord? e1, StoriesRecord? e2) {
    const listEquality = ListEquality();
    return e1?.title == e2?.title &&
        e1?.worldview == e2?.worldview &&
        e1?.category == e2?.category &&
        listEquality.equals(e1?.characters, e2?.characters) &&
        e1?.creatorRef == e2?.creatorRef &&
        e1?.userRole == e2?.userRole &&
        e1?.mainImage == e2?.mainImage &&
        e1?.description == e2?.description &&
        e1?.authorNotes == e2?.authorNotes &&
        e1?.createdAt == e2?.createdAt &&
        listEquality.equals(e1?.hashtags, e2?.hashtags) &&
        e1?.aiModel == e2?.aiModel &&
        e1?.userRef == e2?.userRef &&
        e1?.viewCount == e2?.viewCount &&
        e1?.heartCount == e2?.heartCount &&
        e1?.creatorNickname == e2?.creatorNickname &&
        e1?.type == e2?.type &&
        e1?.authorIsCreator == e2?.authorIsCreator &&
        e1?.createdTimestamp == e2?.createdTimestamp &&
        e1?.detailmode == e2?.detailmode &&
        listEquality.equals(e1?.backgrounds, e2?.backgrounds) &&
        e1?.prologuetext == e2?.prologuetext &&
        e1?.place == e2?.place &&
        e1?.event == e2?.event;
  }

  @override
  int hash(StoriesRecord? e) => const ListEquality().hash([
        e?.title,
        e?.worldview,
        e?.category,
        e?.characters,
        e?.creatorRef,
        e?.userRole,
        e?.mainImage,
        e?.description,
        e?.authorNotes,
        e?.createdAt,
        e?.hashtags,
        e?.aiModel,
        e?.userRef,
        e?.viewCount,
        e?.heartCount,
        e?.creatorNickname,
        e?.type,
        e?.authorIsCreator,
        e?.createdTimestamp,
        e?.detailmode,
        e?.backgrounds,
        e?.prologuetext,
        e?.place,
        e?.event
      ]);

  @override
  bool isValidKey(Object? o) => o is StoriesRecord;
}
