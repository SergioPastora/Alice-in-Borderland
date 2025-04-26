part of 'admin_group_cubit.dart';

abstract class AdminGroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminGroupLoading extends AdminGroupState {}

class AdminGroupLoadSuccess extends AdminGroupState {
  final List<GroupEntity> groups;
  AdminGroupLoadSuccess(this.groups);
  @override
  List<Object?> get props => [groups];
}

class AdminGroupFailure extends AdminGroupState {
  final String message;
  AdminGroupFailure(this.message);
  @override
  List<Object?> get props => [message];
}
