// lib/features/event/presentation/cubit/admin_event_state.dart

part of 'admin_event_cubit.dart';

abstract class AdminEventState extends Equatable {
  const AdminEventState();
  @override
  List<Object?> get props => [];
}

class AdminEventInitial extends AdminEventState {}

class AdminEventLoading extends AdminEventState {}

class AdminEventSuccess extends AdminEventState {}

class AdminEventFailure extends AdminEventState {
  final String message;
  const AdminEventFailure(this.message);
  @override
  List<Object?> get props => [message];
}
