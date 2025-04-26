// lib/features/ranking/presentation/cubit/ranking_state.dart

part of 'ranking_cubit.dart';

abstract class RankingState extends Equatable {
  const RankingState();
  @override
  List<Object?> get props => [];
  factory RankingState.loading() = RankingLoading;
  const factory RankingState.data(List<UserEntity> users) = RankingData;
  const factory RankingState.error(String message) = RankingError;
}

class RankingLoading extends RankingState {}

class RankingData extends RankingState {
  final List<UserEntity> users;
  const RankingData(this.users);
  @override
  List<Object?> get props => [users];
}

class RankingError extends RankingState {
  final String message;
  const RankingError(this.message);
  @override
  List<Object?> get props => [message];
}
