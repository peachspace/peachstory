import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StorymessagesRecord extends FirestoreRecord {
  StorymessagesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "chat_ref" field.
  DocumentReference? _chatRef;
  DocumentReference? get chatRef => _chatRef;
  bool hasChatRef() => _chatRef != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "speakerName" field.
  String? _speakerName;
  String get speakerName => _speakerName ?? '';
  bool hasSpeakerName() => _speakerName != null;

  // "actionText" field.
  String? _actionText;
  String get actionText => _actionText ?? '';
  bool hasActionText() => _actionText != null;

  // "storyImageUrl" field.
  String? _storyImageUrl;
  String get storyImageUrl => _storyImageUrl ?? '';
  bool hasStoryImageUrl() => _storyImageUrl != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _chatRef = snapshotData['chat_ref'] as DocumentReference?;
    _text = snapshotData['text'] as String?;
    _type = snapshotData['type'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _speakerName = snapshotData['speakerName'] as String?;
    _actionText = snapshotData['actionText'] as String?;
    _storyImageUrl = snapshotData['storyImageUrl'] as String?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _role = snapshotData['role'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('storymessages')
          : FirebaseFirestore.instanceFor(
                  app: Firebase.app(), databaseId: '(default)')
              .collectionGroup('storymessages');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('storymessages').doc(id);

  static Stream<StorymessagesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StorymessagesRecord.fromSnapshot(s));

  static Future<StorymessagesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StorymessagesRecord.fromSnapshot(s));

  static StorymessagesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StorymessagesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StorymessagesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StorymessagesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StorymessagesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StorymessagesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStorymessagesRecordData({
  DocumentReference? chatRef,
  String? text,
  String? type,
  DateTime? timestamp,
  String? speakerName,
  String? actionText,
  String? storyImageUrl,
  DocumentReference? userRef,
  String? role,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'chat_ref': chatRef,
      'text': text,
      'type': type,
      'timestamp': timestamp,
      'speakerName': speakerName,
      'actionText': actionText,
      'storyImageUrl': storyImageUrl,
      'user_ref': userRef,
      'role': role,
    }.withoutNulls,
  );

  return firestoreData;
}

class StorymessagesRecordDocumentEquality
    implements Equality<StorymessagesRecord> {
  const StorymessagesRecordDocumentEquality();

  @override
  bool equals(StorymessagesRecord? e1, StorymessagesRecord? e2) {
    return e1?.chatRef == e2?.chatRef &&
        e1?.text == e2?.text &&
        e1?.type == e2?.type &&
        e1?.timestamp == e2?.timestamp &&
        e1?.speakerName == e2?.speakerName &&
        e1?.actionText == e2?.actionText &&
        e1?.storyImageUrl == e2?.storyImageUrl &&
        e1?.userRef == e2?.userRef &&
        e1?.role == e2?.role;
  }

  @override
  int hash(StorymessagesRecord? e) => const ListEquality().hash([
        e?.chatRef,
        e?.text,
        e?.type,
        e?.timestamp,
        e?.speakerName,
        e?.actionText,
        e?.storyImageUrl,
        e?.userRef,
        e?.role
      ]);

  @override
  bool isValidKey(Object? o) => o is StorymessagesRecord;
}
