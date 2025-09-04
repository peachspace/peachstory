import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LikesRecord extends FirestoreRecord {
  LikesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "post_type" field.
  String? _postType;
  String get postType => _postType ?? '';
  bool hasPostType() => _postType != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _postType = snapshotData['post_type'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection => FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: '(default)')
      .collection('likes');

  static Stream<LikesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LikesRecord.fromSnapshot(s));

  static Future<LikesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LikesRecord.fromSnapshot(s));

  static LikesRecord fromSnapshot(DocumentSnapshot snapshot) => LikesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LikesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LikesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LikesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LikesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLikesRecordData({
  DocumentReference? userRef,
  String? postType,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'post_type': postType,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class LikesRecordDocumentEquality implements Equality<LikesRecord> {
  const LikesRecordDocumentEquality();

  @override
  bool equals(LikesRecord? e1, LikesRecord? e2) {
    return e1?.userRef == e2?.userRef &&
        e1?.postType == e2?.postType &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(LikesRecord? e) =>
      const ListEquality().hash([e?.userRef, e?.postType, e?.createdTime]);

  @override
  bool isValidKey(Object? o) => o is LikesRecord;
}
