import 'package:alice_in_borderland/domain/entities/user_entity.dart';
import 'package:bloc/bloc.dart';
import '../../domain/repositories/auth_repository.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  AuthCubit(this._repo) : super(AuthInitial()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final current = _repo.getCurrentUser(); // devuelve UserEntity?
    if (current != null) {
      emit(Authenticated(current));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final UserEntity user = await _repo.signInWithGoogle();
      await _repo.ensureUserInFirestore(user);
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
