import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "points" field.
  int? _points;
  int get points => _points ?? 0;
  bool hasPoints() => _points != null;

  // "authorTier" field.
  String? _authorTier;
  String get authorTier => _authorTier ?? '';
  bool hasAuthorTier() => _authorTier != null;

  // "lastCheckInDate" field.
  DateTime? _lastCheckInDate;
  DateTime? get lastCheckInDate => _lastCheckInDate;
  bool hasLastCheckInDate() => _lastCheckInDate != null;

  // "hearted_post_paths" field.
  List<String>? _heartedPostPaths;
  List<String> get heartedPostPaths => _heartedPostPaths ?? const [];
  bool hasHeartedPostPaths() => _heartedPostPaths != null;

  // "isCreator" field.
  bool? _isCreator;
  bool get isCreator => _isCreator ?? false;
  bool hasIsCreator() => _isCreator != null;

  // "earnings" field.
  int? _earnings;
  int get earnings => _earnings ?? 0;
  bool hasEarnings() => _earnings != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _points = castToType<int>(snapshotData['points']);
    _authorTier = snapshotData['authorTier'] as String?;
    _lastCheckInDate = snapshotData['lastCheckInDate'] as DateTime?;
    _heartedPostPaths = getDataList(snapshotData['hearted_post_paths']);
    _isCreator = snapshotData['isCreator'] as bool?;
    _earnings = castToType<int>(snapshotData['earnings']);
  }

  static CollectionReference get collection => FirebaseFirestore.instanceFor(
          app: Firebase.app(), databaseId: '(default)')
      .collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  String? phoneNumber,
  DateTime? createdTime,
  int? points,
  String? authorTier,
  DateTime? lastCheckInDate,
  bool? isCreator,
  int? earnings,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'phone_number': phoneNumber,
      'created_time': createdTime,
      'points': points,
      'authorTier': authorTier,
      'lastCheckInDate': lastCheckInDate,
      'isCreator': isCreator,
      'earnings': earnings,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.createdTime == e2?.createdTime &&
        e1?.points == e2?.points &&
        e1?.authorTier == e2?.authorTier &&
        e1?.lastCheckInDate == e2?.lastCheckInDate &&
        listEquality.equals(e1?.heartedPostPaths, e2?.heartedPostPaths) &&
        e1?.isCreator == e2?.isCreator &&
        e1?.earnings == e2?.earnings;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.phoneNumber,
        e?.createdTime,
        e?.points,
        e?.authorTier,
        e?.lastCheckInDate,
        e?.heartedPostPaths,
        e?.isCreator,
        e?.earnings
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
