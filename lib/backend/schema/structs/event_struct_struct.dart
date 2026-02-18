// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class EventStructStruct extends FFFirebaseStruct {
  EventStructStruct({
    String? event,
    String? imageurl,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _event = event,
        _imageurl = imageurl,
        super(firestoreUtilData);

  // "event" field.
  String? _event;
  String get event => _event ?? '';
  set event(String? val) => _event = val;

  bool hasEvent() => _event != null;

  // "imageurl" field.
  String? _imageurl;
  String get imageurl => _imageurl ?? '';
  set imageurl(String? val) => _imageurl = val;

  bool hasImageurl() => _imageurl != null;

  static EventStructStruct fromMap(Map<String, dynamic> data) =>
      EventStructStruct(
        event: data['event'] as String?,
        imageurl: data['imageurl'] as String?,
      );

  static EventStructStruct? maybeFromMap(dynamic data) => data is Map
      ? EventStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'event': _event,
        'imageurl': _imageurl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'event': serializeParam(
          _event,
          ParamType.String,
        ),
        'imageurl': serializeParam(
          _imageurl,
          ParamType.String,
        ),
      }.withoutNulls;

  static EventStructStruct fromSerializableMap(Map<String, dynamic> data) =>
      EventStructStruct(
        event: deserializeParam(
          data['event'],
          ParamType.String,
          false,
        ),
        imageurl: deserializeParam(
          data['imageurl'],
          ParamType.String,
          false,
        ),
      );

  static EventStructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      EventStructStruct(
        event: convertAlgoliaParam(
          data['event'],
          ParamType.String,
          false,
        ),
        imageurl: convertAlgoliaParam(
          data['imageurl'],
          ParamType.String,
          false,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'EventStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is EventStructStruct &&
        event == other.event &&
        imageurl == other.imageurl;
  }

  @override
  int get hashCode => const ListEquality().hash([event, imageurl]);
}

EventStructStruct createEventStructStruct({
  String? event,
  String? imageurl,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    EventStructStruct(
      event: event,
      imageurl: imageurl,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

EventStructStruct? updateEventStructStruct(
  EventStructStruct? eventStruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    eventStruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addEventStructStructData(
  Map<String, dynamic> firestoreData,
  EventStructStruct? eventStruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (eventStruct == null) {
    return;
  }
  if (eventStruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && eventStruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final eventStructData =
      getEventStructFirestoreData(eventStruct, forFieldValue);
  final nestedData =
      eventStructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = eventStruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getEventStructFirestoreData(
  EventStructStruct? eventStruct, [
  bool forFieldValue = false,
]) {
  if (eventStruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(eventStruct.toMap());

  // Add any Firestore field values
  eventStruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getEventStructListFirestoreData(
  List<EventStructStruct>? eventStructs,
) =>
    eventStructs?.map((e) => getEventStructFirestoreData(e, true)).toList() ??
    [];
