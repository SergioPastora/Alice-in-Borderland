import 'package:alice_in_borderland/features/events/data/event_model.dart';
import 'package:alice_in_borderland/features/events/data/participant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event_entity.dart';
import '../../domain/entities/participant_entity.dart';
import '../../domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore;
  EventRepositoryImpl(this._firestore);

  @override
  Future<void> createEvent(EventEntity event) {
    return _firestore.collection('eventos').add(EventModel(
          id: '', // firestore generará el ID
          nombre: event.nombre,
          location: event.location,
          radius: event.radius,
          creadorId: event.creadorId,
          startsAt: event.startsAt,
        ).toJson());
  }

  @override
  Stream<List<EventEntity>> watchUpcomingEvents() {
    return _firestore
        .collection('eventos')
        .where('startsAt', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => EventModel.fromSnapshot(d).toEntity())
            .toList());
  }

  @override
  Future<void> subscribeToEvent(String eventId, String userId) {
    final ref = _firestore
        .collection('eventos')
        .doc(eventId)
        .collection('participantes')
        .doc(userId);
    return ref.set(ParticipantModel(
      uid: userId,
      joinedAt: DateTime.now(),
    ).toJson());
  }

  @override
  Stream<List<ParticipantEntity>> watchParticipants(String eventId) {
    return _firestore
        .collection('eventos')
        .doc(eventId)
        .collection('participantes')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ParticipantModel.fromSnapshot(d).toEntity())
            .toList());
  }
}
