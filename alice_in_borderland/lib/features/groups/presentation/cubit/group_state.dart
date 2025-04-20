// lib/features/groups/presentation/cubit/group_state.dart

part of 'group_cubit.dart';

abstract class GroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupLoading extends GroupState {}

class GroupLoadSuccess extends GroupState {
  final GroupEntity group;
  GroupLoadSuccess(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupLoadFailure extends GroupState {
  final String message;
  GroupLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
