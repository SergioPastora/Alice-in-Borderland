// lib/features/events/domain/entities/event_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EventEntity {
  final String id;
  final String nombre;
  final GeoPoint location;
  final double radius;
  final String creadorId;
  final DateTime startsAt;

  EventEntity({
    required this.id,
    required this.nombre,
    required this.location,
    required this.radius,
    required this.creadorId,
    required this.startsAt,
  });
}
