import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PointTransactionsRecord extends FirestoreRecord {
  PointTransactionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "storyId" field.
  DocumentReference? _storyId;
  DocumentReference? get storyId => _storyId;
  bool hasStoryId() => _storyId != null;

  // "authorId" field.
  DocumentReference? _authorId;
  DocumentReference? get authorId => _authorId;
  bool hasAuthorId() => _authorId != null;

  // "changeAmount" field.
  int? _changeAmount;
  int get changeAmount => _changeAmount ?? 0;
  bool hasChangeAmount() => _changeAmount != null;

  // "newBalance" field.
  int? _newBalance;
  int get newBalance => _newBalance ?? 0;
  bool hasNewBalance() => _newBalance != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "modelUsed" field.
  String? _modelUsed;
  String get modelUsed => _modelUsed ?? '';
  bool hasModelUsed() => _modelUsed != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  void _initializeFields() {
    _userId = snapshotData['userId'] as DocumentReference?;
    _storyId = snapshotData['storyId'] as DocumentReference?;
    _authorId = snapshotData['authorId'] as DocumentReference?;
    _changeAmount = castToType<int>(snapshotData['changeAmount']);
    _newBalance = castToType<int>(snapshotData['newBalance']);
    _type = snapshotData['type'] as String?;
    _modelUsed = snapshotData['modelUsed'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
  }

  static CollectionReference get collection => FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: '(default)')
      .collection('pointTransactions');

  static Stream<PointTransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PointTransactionsRecord.fromSnapshot(s));

  static Future<PointTransactionsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => PointTransactionsRecord.fromSnapshot(s));

  static PointTransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PointTransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PointTransactionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PointTransactionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PointTransactionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PointTransactionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPointTransactionsRecordData({
  DocumentReference? userId,
  DocumentReference? storyId,
  DocumentReference? authorId,
  int? changeAmount,
  int? newBalance,
  String? type,
  String? modelUsed,
  DateTime? timestamp,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'storyId': storyId,
      'authorId': authorId,
      'changeAmount': changeAmount,
      'newBalance': newBalance,
      'type': type,
      'modelUsed': modelUsed,
      'timestamp': timestamp,
    }.withoutNulls,
  );

  return firestoreData;
}

class PointTransactionsRecordDocumentEquality
    implements Equality<PointTransactionsRecord> {
  const PointTransactionsRecordDocumentEquality();

  @override
  bool equals(PointTransactionsRecord? e1, PointTransactionsRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.storyId == e2?.storyId &&
        e1?.authorId == e2?.authorId &&
        e1?.changeAmount == e2?.changeAmount &&
        e1?.newBalance == e2?.newBalance &&
        e1?.type == e2?.type &&
        e1?.modelUsed == e2?.modelUsed &&
        e1?.timestamp == e2?.timestamp;
  }

  @override
  int hash(PointTransactionsRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.storyId,
        e?.authorId,
        e?.changeAmount,
        e?.newBalance,
        e?.type,
        e?.modelUsed,
        e?.timestamp
      ]);

  @override
  bool isValidKey(Object? o) => o is PointTransactionsRecord;
}
