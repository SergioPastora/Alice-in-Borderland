part of 'admin_user_cubit.dart';

abstract class AdminUserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminUserLoading extends AdminUserState {}

class AdminUserLoadSuccess extends AdminUserState {
  final List<UserEntity> users;
  AdminUserLoadSuccess(this.users);
  @override
  List<Object?> get props => [users];
}

class AdminUserFailure extends AdminUserState {
  final String message;
  AdminUserFailure(this.message);
  @override
  List<Object?> get props => [message];
}
