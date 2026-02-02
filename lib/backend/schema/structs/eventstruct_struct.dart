// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class EventstructStruct extends FFFirebaseStruct {
  EventstructStruct({
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

  static EventstructStruct fromMap(Map<String, dynamic> data) =>
      EventstructStruct(
        event: data['event'] as String?,
        imageurl: data['imageurl'] as String?,
      );

  static EventstructStruct? maybeFromMap(dynamic data) => data is Map
      ? EventstructStruct.fromMap(data.cast<String, dynamic>())
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

  static EventstructStruct fromSerializableMap(Map<String, dynamic> data) =>
      EventstructStruct(
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

  static EventstructStruct fromAlgoliaData(Map<String, dynamic> data) =>
      EventstructStruct(
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
  String toString() => 'EventstructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is EventstructStruct &&
        event == other.event &&
        imageurl == other.imageurl;
  }

  @override
  int get hashCode => const ListEquality().hash([event, imageurl]);
}

EventstructStruct createEventstructStruct({
  String? event,
  String? imageurl,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    EventstructStruct(
      event: event,
      imageurl: imageurl,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

EventstructStruct? updateEventstructStruct(
  EventstructStruct? eventstruct, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    eventstruct
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addEventstructStructData(
  Map<String, dynamic> firestoreData,
  EventstructStruct? eventstruct,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (eventstruct == null) {
    return;
  }
  if (eventstruct.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && eventstruct.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final eventstructData =
      getEventstructFirestoreData(eventstruct, forFieldValue);
  final nestedData =
      eventstructData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = eventstruct.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getEventstructFirestoreData(
  EventstructStruct? eventstruct, [
  bool forFieldValue = false,
]) {
  if (eventstruct == null) {
    return {};
  }
  final firestoreData = mapToFirestore(eventstruct.toMap());

  // Add any Firestore field values
  eventstruct.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getEventstructListFirestoreData(
  List<EventstructStruct>? eventstructs,
) =>
    eventstructs?.map((e) => getEventstructFirestoreData(e, true)).toList() ??
    [];
