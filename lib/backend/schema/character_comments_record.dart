import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CharacterCommentsRecord extends FirestoreRecord {
  CharacterCommentsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "user_name" field.
  String? _userName;
  String get userName => _userName ?? '';
  bool hasUserName() => _userName != null;

  // "user_profile_image" field.
  String? _userProfileImage;
  String get userProfileImage => _userProfileImage ?? '';
  bool hasUserProfileImage() => _userProfileImage != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "like_count" field.
  int? _likeCount;
  int get likeCount => _likeCount ?? 0;
  bool hasLikeCount() => _likeCount != null;

  // "liked_by" field.
  List<DocumentReference>? _likedBy;
  List<DocumentReference> get likedBy => _likedBy ?? const [];
  bool hasLikedBy() => _likedBy != null;

  // "reply_count" field.
  int? _replyCount;
  int get replyCount => _replyCount ?? 0;
  bool hasReplyCount() => _replyCount != null;

  // "character_ref" field.
  DocumentReference? _characterRef;
  DocumentReference? get characterRef => _characterRef;
  bool hasCharacterRef() => _characterRef != null;

  // "parent_comment_ref" field.
  DocumentReference? _parentCommentRef;
  DocumentReference? get parentCommentRef => _parentCommentRef;
  bool hasParentCommentRef() => _parentCommentRef != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _userName = snapshotData['user_name'] as String?;
    _userProfileImage = snapshotData['user_profile_image'] as String?;
    _content = snapshotData['content'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _likeCount = castToType<int>(snapshotData['like_count']);
    _likedBy = getDataList(snapshotData['liked_by']);
    _replyCount = castToType<int>(snapshotData['reply_count']);
    _characterRef = snapshotData['character_ref'] as DocumentReference?;
    _parentCommentRef =
        snapshotData['parent_comment_ref'] as DocumentReference?;
  }

  static CollectionReference get collection => FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: '(default)')
      .collection('characterComments');

  static Stream<CharacterCommentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CharacterCommentsRecord.fromSnapshot(s));

  static Future<CharacterCommentsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => CharacterCommentsRecord.fromSnapshot(s));

  static CharacterCommentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CharacterCommentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CharacterCommentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CharacterCommentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CharacterCommentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CharacterCommentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCharacterCommentsRecordData({
  DocumentReference? userRef,
  String? userName,
  String? userProfileImage,
  String? content,
  DateTime? timestamp,
  int? likeCount,
  int? replyCount,
  DocumentReference? characterRef,
  DocumentReference? parentCommentRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'user_name': userName,
      'user_profile_image': userProfileImage,
      'content': content,
      'timestamp': timestamp,
      'like_count': likeCount,
      'reply_count': replyCount,
      'character_ref': characterRef,
      'parent_comment_ref': parentCommentRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class CharacterCommentsRecordDocumentEquality
    implements Equality<CharacterCommentsRecord> {
  const CharacterCommentsRecordDocumentEquality();

  @override
  bool equals(CharacterCommentsRecord? e1, CharacterCommentsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userRef == e2?.userRef &&
        e1?.userName == e2?.userName &&
        e1?.userProfileImage == e2?.userProfileImage &&
        e1?.content == e2?.content &&
        e1?.timestamp == e2?.timestamp &&
        e1?.likeCount == e2?.likeCount &&
        listEquality.equals(e1?.likedBy, e2?.likedBy) &&
        e1?.replyCount == e2?.replyCount &&
        e1?.characterRef == e2?.characterRef &&
        e1?.parentCommentRef == e2?.parentCommentRef;
  }

  @override
  int hash(CharacterCommentsRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.userName,
        e?.userProfileImage,
        e?.content,
        e?.timestamp,
        e?.likeCount,
        e?.likedBy,
        e?.replyCount,
        e?.characterRef,
        e?.parentCommentRef
      ]);

  @override
  bool isValidKey(Object? o) => o is CharacterCommentsRecord;
}
