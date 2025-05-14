// lib/features/users/presentation/cubit/user_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/add_card_to_user_usecase.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repo;
  final AddCardToUserUseCase _addCard;

  StreamSubscription<UserEntity>? _sub;

  UserCubit(this._repo, this._addCard) : super(UserLoading());

  Future<void> init() async {
    emit(UserLoading());
    try {
      final user = await _repo.watchCurrentUser().first;
      emit(UserLoadSuccess(user));
      _sub = _repo.watchCurrentUser().skip(1).listen(
            (u) => emit(UserLoadSuccess(u)),
            onError: (e) => emit(UserLoadFailure(e.toString())),
          );
    } catch (e) {
      emit(UserLoadFailure(e.toString()));
    }
  }

  Future<void> addCard(String code) async {
    final current = state;
    if (current is! UserLoadSuccess) return;
    emit(UserLoading());
    try {
      await _addCard(current.user.uid, code);
      // el stream de _repo.watchCurrentUser() emitirá la nueva lista
    } catch (e) {
      emit(UserLoadFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
