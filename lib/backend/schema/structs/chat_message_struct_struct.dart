// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class ChatMessageStructStruct extends FFFirebaseStruct {
  ChatMessageStructStruct({
    String? name,
    DateTime? timestamp,
    String? senderImage,
    String? text,
    String? messageId,
    String? type,
    bool? isPredefinedCharacter,
    String? action,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _timestamp = timestamp,
        _senderImage = senderImage,
        _text = text,
        _messageId = messageId,
        _type = type,
        _isPredefinedCharacter = isPredefinedCharacter,
        _action = action,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime get timestamp =>
      _timestamp ?? DateTime.fromMicrosecondsSinceEpoch(1746716400000000);
  set timestamp(DateTime? val) => _timestamp = val;

  bool hasTimestamp() => _timestamp != null;

  // "sender_image" field.
  String? _senderImage;
  String get senderImage => _senderImage ?? '';
  set senderImage(String? val) => _senderImage = val;

  bool hasSenderImage() => _senderImage != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  set text(String? val) => _text = val;

  bool hasText() => _text != null;

  // "messageId" field.
  String? _messageId;
  String get messageId => _messageId ?? '';
  set messageId(String? val) => _messageId = val;

  bool hasMessageId() => _messageId != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  // "isPredefinedCharacter" field.
  bool? _isPredefinedCharacter;
  bool get isPredefinedCharacter => _isPredefinedCharacter ?? false;
  set isPredefinedCharacter(bool? val) => _isPredefinedCharacter = val;

  bool hasIsPredefinedCharacter() => _isPredefinedCharacter != null;

  // "action" field.
  String? _action;
  String get action => _action ?? '';
  set action(String? val) => _action = val;

  bool hasAction() => _action != null;

  static ChatMessageStructStruct fromMap(Map<String, dynamic> data) =>
      ChatMessageStructStruct(
        name: data['name'] as String?,
        timestamp: data['timestamp'] as DateTime?,
        senderImage: data['sender_image'] as String?,
        text: data['text'] as String?,
        messageId: data['messageId'] as String?,
        type: data['type'] as String?,
        isPredefinedCharacter: data['isPredefinedCharacter'] as bool?,
        action: data['action'] as String?,
      );

  static ChatMessageStructStruct? maybeFromMap(dynamic data) => data is Map
      ? ChatMessageStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'timestamp': _timestamp,
        'sender_image': _senderImage,
        'text': _text,
        'messageId': _messageId,
        'type': _type,
        'isPredefinedCharacter': _isPredefinedCharacter,
        'action': _action,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'timestamp': serializeParam(
          _timestamp,
          ParamType.DateTime,
        ),
        'sender_image': serializeParam(
          _senderImage,
          ParamType.String,
        ),
        'text': serializeParam(
          _text,
          ParamType.String,
        ),
        'messageId': serializeParam(
          _messageId,
          ParamType.String,
        ),
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
        'isPredefinedCharacter': serializeParam(
          _isPredefinedCharacter,
          ParamType.bool,
        ),
        'action': serializeParam(
          _action,
          ParamType.String,
        ),
      }.withoutNulls;

  static ChatMessageStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ChatMessageStructStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        timestamp: deserializeParam(
          data['timestamp'],
          ParamType.DateTime,
          false,
        ),
        senderImage: deserializeParam(
          data['sender_image'],
          ParamType.String,
          false,
        ),
        text: deserializeParam(
          data['text'],
          ParamType.String,
          false,
        ),
        messageId: deserializeParam(
          data['messageId'],
          ParamType.String,
          false,
        ),
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
        isPredefinedCharacter: deserializeParam(
          data['isPredefinedCharacter'],
          ParamType.bool,
          false,
        ),
        action: deserializeParam(
          data['action'],
          ParamType.String,
          false,
        ),
      );

  static ChatMessageStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      ChatMessageStructStruct(
        name: convertAlgoliaParam(
          data['name'],
          ParamType.String,
          false,
        ),
        timestamp: convertAlgoliaParam(
          data['timestamp'],
          ParamType.DateTime,
          false,
        ),
        senderImage: convertAlgoliaParam(
          data['sender_image'],
          ParamType.String,
          false,
        ),
        text: convertAlgoliaParam(
          data['text'],
          ParamType.String,
          false,
        ),
        messageId: convertAlgoliaParam(
          data['messageId'],
          ParamType.String,
          false,
        ),
        type: convertAlgoliaParam(
          data['type'],
          ParamType.String,
          false,
        ),
        isPredefinedCharacter: convertAlgoliaParam(
          data['isPredefinedCharacter'],
          ParamType.bool,
          false,
        ),
        action: convertAlgoliaParam(
          data['action'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'ChatMessageStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChatMessageStructStruct &&
        name == other.name &&
        timestamp == other.timestamp &&
        senderImage == other.senderImage &&
        text == other.text &&
        messageId == other.messageId &&
        type == other.type &&
        isPredefinedCharacter == other.isPredefinedCharacter &&
        action == other.action;
  }

  @override
  int get hashCode => const ListEquality().hash([
        name,
        timestamp,
        senderImage,
        text,
        messageId,
        type,
        isPredefinedCharacter,
        action
      ]);
}

ChatMessageStructStruct createChatMessageStructStruct({
  String? name,
  DateTime? timestamp,
  String? senderImage,
  String? text,
  String? messageId,
  String? type,
  bool? isPredefinedCharacter,
  String? action,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ChatMessageStructStruct(
      name: name,
      timestamp: timestamp,
      senderImage: senderImage,
      text: text,
      messageId: messageId,
      type: type,
      isPredefinedCharacter: isPredefinedCharacter,
      action: action,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ChatMessageStructStruct? updateChatMessageStructStruct(
  ChatMessageStructStruct? chatMessageStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    chatMessageStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addChatMessageStructStructData(
  Map<String, dynamic> firestoreData,
  ChatMessageStructStruct? chatMessageStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (chatMessageStruct == null) {
    return;
  }
  if (chatMessageStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && chatMessageStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final chatMessageStructData =
      getChatMessageStructFirestoreData(chatMessageStruct, forFieldValue);
  final nestedData =
      chatMessageStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = chatMessageStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getChatMessageStructFirestoreData(
  ChatMessageStructStruct? chatMessageStruct, [
  bool forFieldValue = false,
]) {
  if (chatMessageStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(chatMessageStruct.toMap());

  // Add any Firestore field values
  chatMessageStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getChatMessageStructListFirestoreData(
  List<ChatMessageStructStruct>? chatMessageStructs,
) =>
    chatMessageStructs
        ?.map((e) => getChatMessageStructFirestoreData(e, true))
        .toList() ??
    [];
