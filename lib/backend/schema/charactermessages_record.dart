import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CharactermessagesRecord extends FirestoreRecord {
  CharactermessagesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "sender_image" field.
  String? _senderImage;
  String get senderImage => _senderImage ?? '';
  bool hasSenderImage() => _senderImage != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "messageId" field.
  String? _messageId;
  String get messageId => _messageId ?? '';
  bool hasMessageId() => _messageId != null;

  // "options" field.
  List<OptionStructStruct>? _options;
  List<OptionStructStruct> get options => _options ?? const [];
  bool hasOptions() => _options != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "chat_ref" field.
  DocumentReference? _chatRef;
  DocumentReference? get chatRef => _chatRef;
  bool hasChatRef() => _chatRef != null;

  // "storyImageUrl" field.
  String? _storyImageUrl;
  String get storyImageUrl => _storyImageUrl ?? '';
  bool hasStoryImageUrl() => _storyImageUrl != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _senderImage = snapshotData['sender_image'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _messageId = snapshotData['messageId'] as String?;
    _options = getStructList(
      snapshotData['options'],
      OptionStructStruct.fromMap,
    );
    _name = snapshotData['name'] as String?;
    _text = snapshotData['text'] as String?;
    _type = snapshotData['type'] as String?;
    _chatRef = snapshotData['chat_ref'] as DocumentReference?;
    _storyImageUrl = snapshotData['storyImageUrl'] as String?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('charactermessages')
          : FirebaseFirestore.instanceFor(
                  app: Firebase.app(), databaseId: '(default)')
              .collectionGroup('charactermessages');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('charactermessages').doc(id);

  static Stream<CharactermessagesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CharactermessagesRecord.fromSnapshot(s));

  static Future<CharactermessagesRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => CharactermessagesRecord.fromSnapshot(s));

  static CharactermessagesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CharactermessagesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CharactermessagesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CharactermessagesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CharactermessagesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CharactermessagesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCharactermessagesRecordData({
  String? senderImage,
  DateTime? timestamp,
  String? messageId,
  String? name,
  String? text,
  String? type,
  DocumentReference? chatRef,
  String? storyImageUrl,
  DocumentReference? userRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'sender_image': senderImage,
      'timestamp': timestamp,
      'messageId': messageId,
      'name': name,
      'text': text,
      'type': type,
      'chat_ref': chatRef,
      'storyImageUrl': storyImageUrl,
      'user_ref': userRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class CharactermessagesRecordDocumentEquality
    implements Equality<CharactermessagesRecord> {
  const CharactermessagesRecordDocumentEquality();

  @override
  bool equals(CharactermessagesRecord? e1, CharactermessagesRecord? e2) {
    const listEquality = ListEquality();
    return e1?.senderImage == e2?.senderImage &&
        e1?.timestamp == e2?.timestamp &&
        e1?.messageId == e2?.messageId &&
        listEquality.equals(e1?.options, e2?.options) &&
        e1?.name == e2?.name &&
        e1?.text == e2?.text &&
        e1?.type == e2?.type &&
        e1?.chatRef == e2?.chatRef &&
        e1?.storyImageUrl == e2?.storyImageUrl &&
        e1?.userRef == e2?.userRef;
  }

  @override
  int hash(CharactermessagesRecord? e) => const ListEquality().hash([
        e?.senderImage,
        e?.timestamp,
        e?.messageId,
        e?.options,
        e?.name,
        e?.text,
        e?.type,
        e?.chatRef,
        e?.storyImageUrl,
        e?.userRef
      ]);

  @override
  bool isValidKey(Object? o) => o is CharactermessagesRecord;
}
