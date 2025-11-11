import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CharacterchatsRecord extends FirestoreRecord {
  CharacterchatsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

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

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "character_ref" field.
  DocumentReference? _characterRef;
  DocumentReference? get characterRef => _characterRef;
  bool hasCharacterRef() => _characterRef != null;

  // "lastSummaryMessageCount" field.
  int? _lastSummaryMessageCount;
  int get lastSummaryMessageCount => _lastSummaryMessageCount ?? 0;
  bool hasLastSummaryMessageCount() => _lastSummaryMessageCount != null;

  // "summary" field.
  String? _summary;
  String get summary => _summary ?? '';
  bool hasSummary() => _summary != null;

  // "selectedAiModel" field.
  String? _selectedAiModel;
  String get selectedAiModel => _selectedAiModel ?? '';
  bool hasSelectedAiModel() => _selectedAiModel != null;

  // "userNote" field.
  String? _userNote;
  String get userNote => _userNote ?? '';
  bool hasUserNote() => _userNote != null;

  // "creator_ref" field.
  DocumentReference? _creatorRef;
  DocumentReference? get creatorRef => _creatorRef;
  bool hasCreatorRef() => _creatorRef != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _lastMessage = snapshotData['last_message'] as String?;
    _lastTimestamp = snapshotData['last_timestamp'] as DateTime?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _characterRef = snapshotData['character_ref'] as DocumentReference?;
    _lastSummaryMessageCount =
        castToType<int>(snapshotData['lastSummaryMessageCount']);
    _summary = snapshotData['summary'] as String?;
    _selectedAiModel = snapshotData['selectedAiModel'] as String?;
    _userNote = snapshotData['userNote'] as String?;
    _creatorRef = snapshotData['creator_ref'] as DocumentReference?;
  }

  static CollectionReference get collection => FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: '(default)')
      .collection('characterchats');

  static Stream<CharacterchatsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CharacterchatsRecord.fromSnapshot(s));

  static Future<CharacterchatsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CharacterchatsRecord.fromSnapshot(s));

  static CharacterchatsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CharacterchatsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CharacterchatsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CharacterchatsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CharacterchatsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CharacterchatsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCharacterchatsRecordData({
  DocumentReference? userRef,
  String? lastMessage,
  DateTime? lastTimestamp,
  DateTime? createdAt,
  DocumentReference? characterRef,
  int? lastSummaryMessageCount,
  String? summary,
  String? selectedAiModel,
  String? userNote,
  DocumentReference? creatorRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'last_message': lastMessage,
      'last_timestamp': lastTimestamp,
      'created_at': createdAt,
      'character_ref': characterRef,
      'lastSummaryMessageCount': lastSummaryMessageCount,
      'summary': summary,
      'selectedAiModel': selectedAiModel,
      'userNote': userNote,
      'creator_ref': creatorRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class CharacterchatsRecordDocumentEquality
    implements Equality<CharacterchatsRecord> {
  const CharacterchatsRecordDocumentEquality();

  @override
  bool equals(CharacterchatsRecord? e1, CharacterchatsRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.lastMessage == e2?.lastMessage &&
        e1?.lastTimestamp == e2?.lastTimestamp &&
        e1?.createdAt == e2?.createdAt &&
        e1?.characterRef == e2?.characterRef &&
        e1?.lastSummaryMessageCount == e2?.lastSummaryMessageCount &&
        e1?.summary == e2?.summary &&
        e1?.selectedAiModel == e2?.selectedAiModel &&
        e1?.userNote == e2?.userNote &&
        e1?.creatorRef == e2?.creatorRef;
  }

  @override
  int hash(CharacterchatsRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.lastMessage,
        e?.lastTimestamp,
        e?.createdAt,
        e?.characterRef,
        e?.lastSummaryMessageCount,
        e?.summary,
        e?.selectedAiModel,
        e?.userNote,
        e?.creatorRef
      ]);

  @override
  bool isValidKey(Object? o) => o is CharacterchatsRecord;
}
