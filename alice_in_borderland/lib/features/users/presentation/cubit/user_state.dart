part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserLoading extends UserState {}

class UserLoadSuccess extends UserState {
  final UserEntity user;
  UserLoadSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class UserLoadFailure extends UserState {
  final String message;
  UserLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
