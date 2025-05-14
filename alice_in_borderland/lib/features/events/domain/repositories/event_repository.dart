import '../entities/event_entity.dart';
import '../entities/participant_entity.dart';

abstract class EventRepository {
  Future<void> createEvent(EventEntity event);
  Stream<List<EventEntity>> watchUpcomingEvents();
  Future<void> subscribeToEvent(String eventId, String userId);
  Stream<List<ParticipantEntity>> watchParticipants(String eventId);
}
