// lib/features/auth/presentation/cubit/auth_cubit.dart

import 'package:alice_in_borderland/features/groups/domain/repositories/group_repository.dart';
import 'package:alice_in_borderland/features/users/domain/entities/user_entity.dart';
import 'package:bloc/bloc.dart';

import '../../domain/repositories/auth_repository.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  final GroupRepository _groupRepo;

  AuthCubit(this._repo, this._groupRepo) : super(AuthInitial()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    emit(AuthLoading());
    try {
      final UserEntity? user = await _repo.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final UserEntity user = await _repo.signInWithGoogle();
      await _repo.ensureUserInFirestore(user);

      await _groupRepo.moveUserToGroup(user.uid, '0');
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    emit(Unauthenticated());
  }
}
