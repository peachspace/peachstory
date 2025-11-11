import 'dart:async';

import '/backend/algolia/serialization_util.dart';
import '/backend/algolia/algolia_manager.dart';
import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CharacterRecord extends FirestoreRecord {
  CharacterRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "setting" field.
  String? _setting;
  String get setting => _setting ?? '';
  bool hasSetting() => _setting != null;

  // "voice" field.
  String? _voice;
  String get voice => _voice ?? '';
  bool hasVoice() => _voice != null;

  // "firstgreeting" field.
  String? _firstgreeting;
  String get firstgreeting => _firstgreeting ?? '';
  bool hasFirstgreeting() => _firstgreeting != null;

  // "mainimage" field.
  String? _mainimage;
  String get mainimage => _mainimage ?? '';
  bool hasMainimage() => _mainimage != null;

  // "characterimage" field.
  String? _characterimage;
  String get characterimage => _characterimage ?? '';
  bool hasCharacterimage() => _characterimage != null;

  // "introduce" field.
  String? _introduce;
  String get introduce => _introduce ?? '';
  bool hasIntroduce() => _introduce != null;

  // "author" field.
  String? _author;
  String get author => _author ?? '';
  bool hasAuthor() => _author != null;

  // "genre" field.
  String? _genre;
  String get genre => _genre ?? '';
  bool hasGenre() => _genre != null;

  // "dialogueExample" field.
  List<String>? _dialogueExample;
  List<String> get dialogueExample => _dialogueExample ?? const [];
  bool hasDialogueExample() => _dialogueExample != null;

  // "creator_ref" field.
  DocumentReference? _creatorRef;
  DocumentReference? get creatorRef => _creatorRef;
  bool hasCreatorRef() => _creatorRef != null;

  // "aiModel" field.
  String? _aiModel;
  String get aiModel => _aiModel ?? '';
  bool hasAiModel() => _aiModel != null;

  // "situational_images" field.
  List<SituationalImageStructStruct>? _situationalImages;
  List<SituationalImageStructStruct> get situationalImages =>
      _situationalImages ?? const [];
  bool hasSituationalImages() => _situationalImages != null;

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

  // "hashtags" field.
  List<String>? _hashtags;
  List<String> get hashtags => _hashtags ?? const [];
  bool hasHashtags() => _hashtags != null;

  // "created_timestamp" field.
  DateTime? _createdTimestamp;
  DateTime? get createdTimestamp => _createdTimestamp;
  bool hasCreatedTimestamp() => _createdTimestamp != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _setting = snapshotData['setting'] as String?;
    _voice = snapshotData['voice'] as String?;
    _firstgreeting = snapshotData['firstgreeting'] as String?;
    _mainimage = snapshotData['mainimage'] as String?;
    _characterimage = snapshotData['characterimage'] as String?;
    _introduce = snapshotData['introduce'] as String?;
    _author = snapshotData['author'] as String?;
    _genre = snapshotData['genre'] as String?;
    _dialogueExample = getDataList(snapshotData['dialogueExample']);
    _creatorRef = snapshotData['creator_ref'] as DocumentReference?;
    _aiModel = snapshotData['aiModel'] as String?;
    _situationalImages = getStructList(
      snapshotData['situational_images'],
      SituationalImageStructStruct.fromMap,
    );
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _viewCount = castToType<int>(snapshotData['view_count']);
    _heartCount = castToType<int>(snapshotData['heart_count']);
    _creatorNickname = snapshotData['creator_nickname'] as String?;
    _type = snapshotData['type'] as String?;
    _authorIsCreator = snapshotData['authorIsCreator'] as bool?;
    _hashtags = getDataList(snapshotData['hashtags']);
    _createdTimestamp = snapshotData['created_timestamp'] as DateTime?;
  }

  static CollectionReference get collection => FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: '(default)')
      .collection('character');

  static Stream<CharacterRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CharacterRecord.fromSnapshot(s));

  static Future<CharacterRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CharacterRecord.fromSnapshot(s));

  static CharacterRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CharacterRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CharacterRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CharacterRecord._(reference, mapFromFirestore(data));

  static CharacterRecord fromAlgolia(AlgoliaObjectSnapshot snapshot) =>
      CharacterRecord.getDocumentFromData(
        {
          'name': snapshot.data['name'],
          'setting': snapshot.data['setting'],
          'voice': snapshot.data['voice'],
          'firstgreeting': snapshot.data['firstgreeting'],
          'mainimage': snapshot.data['mainimage'],
          'characterimage': snapshot.data['characterimage'],
          'introduce': snapshot.data['introduce'],
          'author': snapshot.data['author'],
          'genre': snapshot.data['genre'],
          'dialogueExample': safeGet(
            () => snapshot.data['dialogueExample'].toList(),
          ),
          'creator_ref': convertAlgoliaParam(
            snapshot.data['creator_ref'],
            ParamType.DocumentReference,
            false,
          ),
          'aiModel': snapshot.data['aiModel'],
          'situational_images': safeGet(
            () => (snapshot.data['situational_images'] as Iterable)
                .map((d) =>
                    SituationalImageStructStruct.fromAlgoliaData(d).toMap())
                .toList(),
          ),
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
          'hashtags': safeGet(
            () => snapshot.data['hashtags'].toList(),
          ),
          'created_timestamp': convertAlgoliaParam(
            snapshot.data['created_timestamp'],
            ParamType.DateTime,
            false,
          ),
        },
        CharacterRecord.collection.doc(snapshot.objectID),
      );

  static Future<List<CharacterRecord>> search({
    String? term,
    FutureOr<LatLng>? location,
    int? maxResults,
    double? searchRadiusMeters,
    bool useCache = false,
  }) =>
      FFAlgoliaManager.instance
          .algoliaQuery(
            index: 'character',
            term: term,
            maxResults: maxResults,
            location: location,
            searchRadiusMeters: searchRadiusMeters,
            useCache: useCache,
          )
          .then((r) => r.map(fromAlgolia).toList());

  @override
  String toString() =>
      'CharacterRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CharacterRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCharacterRecordData({
  String? name,
  String? setting,
  String? voice,
  String? firstgreeting,
  String? mainimage,
  String? characterimage,
  String? introduce,
  String? author,
  String? genre,
  DocumentReference? creatorRef,
  String? aiModel,
  DocumentReference? userRef,
  int? viewCount,
  int? heartCount,
  String? creatorNickname,
  String? type,
  bool? authorIsCreator,
  DateTime? createdTimestamp,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'setting': setting,
      'voice': voice,
      'firstgreeting': firstgreeting,
      'mainimage': mainimage,
      'characterimage': characterimage,
      'introduce': introduce,
      'author': author,
      'genre': genre,
      'creator_ref': creatorRef,
      'aiModel': aiModel,
      'user_ref': userRef,
      'view_count': viewCount,
      'heart_count': heartCount,
      'creator_nickname': creatorNickname,
      'type': type,
      'authorIsCreator': authorIsCreator,
      'created_timestamp': createdTimestamp,
    }.withoutNulls,
  );

  return firestoreData;
}

class CharacterRecordDocumentEquality implements Equality<CharacterRecord> {
  const CharacterRecordDocumentEquality();

  @override
  bool equals(CharacterRecord? e1, CharacterRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.setting == e2?.setting &&
        e1?.voice == e2?.voice &&
        e1?.firstgreeting == e2?.firstgreeting &&
        e1?.mainimage == e2?.mainimage &&
        e1?.characterimage == e2?.characterimage &&
        e1?.introduce == e2?.introduce &&
        e1?.author == e2?.author &&
        e1?.genre == e2?.genre &&
        listEquality.equals(e1?.dialogueExample, e2?.dialogueExample) &&
        e1?.creatorRef == e2?.creatorRef &&
        e1?.aiModel == e2?.aiModel &&
        listEquality.equals(e1?.situationalImages, e2?.situationalImages) &&
        e1?.userRef == e2?.userRef &&
        e1?.viewCount == e2?.viewCount &&
        e1?.heartCount == e2?.heartCount &&
        e1?.creatorNickname == e2?.creatorNickname &&
        e1?.type == e2?.type &&
        e1?.authorIsCreator == e2?.authorIsCreator &&
        listEquality.equals(e1?.hashtags, e2?.hashtags) &&
        e1?.createdTimestamp == e2?.createdTimestamp;
  }

  @override
  int hash(CharacterRecord? e) => const ListEquality().hash([
        e?.name,
        e?.setting,
        e?.voice,
        e?.firstgreeting,
        e?.mainimage,
        e?.characterimage,
        e?.introduce,
        e?.author,
        e?.genre,
        e?.dialogueExample,
        e?.creatorRef,
        e?.aiModel,
        e?.situationalImages,
        e?.userRef,
        e?.viewCount,
        e?.heartCount,
        e?.creatorNickname,
        e?.type,
        e?.authorIsCreator,
        e?.hashtags,
        e?.createdTimestamp
      ]);

  @override
  bool isValidKey(Object? o) => o is CharacterRecord;
}
