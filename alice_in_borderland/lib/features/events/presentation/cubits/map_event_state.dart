// lib/features/event/presentation/cubit/map_event_state.dart

part of 'map_event_cubit.dart';

abstract class MapEventState extends Equatable {
  const MapEventState();
  @override
  List<Object?> get props => [];
}

class MapEventLoading extends MapEventState {
  const MapEventLoading();
}

class MapEventFailure extends MapEventState {
  final String message;
  const MapEventFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class MapEventLoadSuccess extends MapEventState {
  final List<EventEntity> events;
  final LatLng currentPosition;

  const MapEventLoadSuccess({
    required this.events,
    required this.currentPosition,
  });

  @override
  List<Object?> get props => [events, currentPosition];
}
