import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StorychatsRecord extends FirestoreRecord {
  StorychatsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "story_ref" field.
  DocumentReference? _storyRef;
  DocumentReference? get storyRef => _storyRef;
  bool hasStoryRef() => _storyRef != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "last_message" field.
  String? _lastMessage;
  String get lastMessage => _lastMessage ?? '';
  bool hasLastMessage() => _lastMessage != null;

  // "last_timestamp" field.
  DateTime? _lastTimestamp;
  DateTime? get lastTimestamp => _lastTimestamp;
  bool hasLastTimestamp() => _lastTimestamp != null;

  // "lastSummaryMessageCount" field.
  int? _lastSummaryMessageCount;
  int get lastSummaryMessageCount => _lastSummaryMessageCount ?? 0;
  bool hasLastSummaryMessageCount() => _lastSummaryMessageCount != null;

  // "summary" field.
  String? _summary;
  String get summary => _summary ?? '';
  bool hasSummary() => _summary != null;

  // "userInChatName" field.
  String? _userInChatName;
  String get userInChatName => _userInChatName ?? '';
  bool hasUserInChatName() => _userInChatName != null;

  // "userNote" field.
  String? _userNote;
  String get userNote => _userNote ?? '';
  bool hasUserNote() => _userNote != null;

  // "selectedAiModel" field.
  String? _selectedAiModel;
  String get selectedAiModel => _selectedAiModel ?? '';
  bool hasSelectedAiModel() => _selectedAiModel != null;

  // "creator_ref" field.
  DocumentReference? _creatorRef;
  DocumentReference? get creatorRef => _creatorRef;
  bool hasCreatorRef() => _creatorRef != null;

  // "isNovelMode" field.
  bool? _isNovelMode;
  bool get isNovelMode => _isNovelMode ?? false;
  bool hasIsNovelMode() => _isNovelMode != null;

  // "messageCount" field.
  int? _messageCount;
  int get messageCount => _messageCount ?? 0;
  bool hasMessageCount() => _messageCount != null;

  // "turnCount" field.
  int? _turnCount;
  int get turnCount => _turnCount ?? 0;
  bool hasTurnCount() => _turnCount != null;

  // "chapterIndex" field.
  int? _chapterIndex;
  int get chapterIndex => _chapterIndex ?? 0;
  bool hasChapterIndex() => _chapterIndex != null;

  // "storyBible" field.
  String? _storyBible;
  String get storyBible => _storyBible ?? '';
  bool hasStoryBible() => _storyBible != null;

  // "chapterState" field.
  String? _chapterState;
  String get chapterState => _chapterState ?? '';
  bool hasChapterState() => _chapterState != null;

  // "outlineText" field.
  String? _outlineText;
  String get outlineText => _outlineText ?? '';
  bool hasOutlineText() => _outlineText != null;

  void _initializeFields() {
    _storyRef = snapshotData['story_ref'] as DocumentReference?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _lastMessage = snapshotData['last_message'] as String?;
    _lastTimestamp = snapshotData['last_timestamp'] as DateTime?;
    _lastSummaryMessageCount =
        castToType<int>(snapshotData['lastSummaryMessageCount']);
    _summary = snapshotData['summary'] as String?;
    _userInChatName = snapshotData['userInChatName'] as String?;
    _userNote = snapshotData['userNote'] as String?;
    _selectedAiModel = snapshotData['selectedAiModel'] as String?;
    _creatorRef = snapshotData['creator_ref'] as DocumentReference?;
    _isNovelMode = snapshotData['isNovelMode'] as bool?;
    _messageCount = castToType<int>(snapshotData['messageCount']);
    _turnCount = castToType<int>(snapshotData['turnCount']);
    _chapterIndex = castToType<int>(snapshotData['chapterIndex']);
    _storyBible = snapshotData['storyBible'] as String?;
    _chapterState = snapshotData['chapterState'] as String?;
    _outlineText = snapshotData['outlineText'] as String?;
  }

  static CollectionReference get collection => FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: '(default)')
      .collection('storychats');

  static Stream<StorychatsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StorychatsRecord.fromSnapshot(s));

  static Future<StorychatsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StorychatsRecord.fromSnapshot(s));

  static StorychatsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StorychatsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StorychatsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StorychatsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StorychatsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StorychatsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStorychatsRecordData({
  DocumentReference? storyRef,
  DocumentReference? userRef,
  String? lastMessage,
  DateTime? lastTimestamp,
  int? lastSummaryMessageCount,
  String? summary,
  String? userInChatName,
  String? userNote,
  String? selectedAiModel,
  DocumentReference? creatorRef,
  bool? isNovelMode,
  int? messageCount,
  int? turnCount,
  int? chapterIndex,
  String? storyBible,
  String? chapterState,
  String? outlineText,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'story_ref': storyRef,
      'user_ref': userRef,
      'last_message': lastMessage,
      'last_timestamp': lastTimestamp,
      'lastSummaryMessageCount': lastSummaryMessageCount,
      'summary': summary,
      'userInChatName': userInChatName,
      'userNote': userNote,
      'selectedAiModel': selectedAiModel,
      'creator_ref': creatorRef,
      'isNovelMode': isNovelMode,
      'messageCount': messageCount,
      'turnCount': turnCount,
      'chapterIndex': chapterIndex,
      'storyBible': storyBible,
      'chapterState': chapterState,
      'outlineText': outlineText,
    }.withoutNulls,
  );

  return firestoreData;
}

class StorychatsRecordDocumentEquality implements Equality<StorychatsRecord> {
  const StorychatsRecordDocumentEquality();

  @override
  bool equals(StorychatsRecord? e1, StorychatsRecord? e2) {
    return e1?.storyRef == e2?.storyRef &&
        e1?.userRef == e2?.userRef &&
        e1?.lastMessage == e2?.lastMessage &&
        e1?.lastTimestamp == e2?.lastTimestamp &&
        e1?.lastSummaryMessageCount == e2?.lastSummaryMessageCount &&
        e1?.summary == e2?.summary &&
        e1?.userInChatName == e2?.userInChatName &&
        e1?.userNote == e2?.userNote &&
        e1?.selectedAiModel == e2?.selectedAiModel &&
        e1?.creatorRef == e2?.creatorRef &&
        e1?.isNovelMode == e2?.isNovelMode &&
        e1?.messageCount == e2?.messageCount &&
        e1?.turnCount == e2?.turnCount &&
        e1?.chapterIndex == e2?.chapterIndex &&
        e1?.storyBible == e2?.storyBible &&
        e1?.chapterState == e2?.chapterState &&
        e1?.outlineText == e2?.outlineText;
  }

  @override
  int hash(StorychatsRecord? e) => const ListEquality().hash([
        e?.storyRef,
        e?.userRef,
        e?.lastMessage,
        e?.lastTimestamp,
        e?.lastSummaryMessageCount,
        e?.summary,
        e?.userInChatName,
        e?.userNote,
        e?.selectedAiModel,
        e?.creatorRef,
        e?.isNovelMode,
        e?.messageCount,
        e?.turnCount,
        e?.chapterIndex,
        e?.storyBible,
        e?.chapterState,
        e?.outlineText
      ]);

  @override
  bool isValidKey(Object? o) => o is StorychatsRecord;
}
