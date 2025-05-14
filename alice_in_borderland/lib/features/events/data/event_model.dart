import 'package:alice_in_borderland/features/events/domain/entities/event_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel extends EventEntity {
  EventModel({
    required String id,
    required String nombre,
    required GeoPoint location,
    required double radius,
    required String creadorId,
    required DateTime startsAt,
  }) : super(
          id: id,
          nombre: nombre,
          location: location,
          radius: radius,
          creadorId: creadorId,
          startsAt: startsAt,
        );

  factory EventModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data()! as Map<String, dynamic>;
    return EventModel(
      id: snap.id,
      nombre: data['nombre'] as String,
      location: data['location'] as GeoPoint,
      radius: (data['radius'] as num).toDouble(),
      creadorId: data['creadorId'] as String,
      startsAt: (data['startsAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'location': location,
        'radius': radius,
        'creadorId': creadorId,
        'startsAt': Timestamp.fromDate(startsAt),
      };

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      nombre: nombre,
      location: location,
      radius: radius,
      creadorId: creadorId,
      startsAt: startsAt,
    );
  }
}
