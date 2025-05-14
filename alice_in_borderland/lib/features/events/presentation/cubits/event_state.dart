// lib/features/event/presentation/cubit/event_state.dart

part of 'event_cubit.dart';

abstract class EventState extends Equatable {
  const EventState();
  @override
  List<Object?> get props => [];
}

class EventLoading extends EventState {}

class EventLoadSuccess extends EventState {
  final List<EventEntity> events;
  const EventLoadSuccess(this.events);
  @override
  List<Object?> get props => [events];
}

class EventError extends EventState {
  final String message;
  const EventError(this.message);
  @override
  List<Object?> get props => [message];
}
