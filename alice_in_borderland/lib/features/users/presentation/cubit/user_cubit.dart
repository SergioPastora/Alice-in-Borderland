// lib/features/users/presentation/cubit/user_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

part 'user_state.dart';

/// Ahora no empezamos nada en el constructor
class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;
  StreamSubscription<UserEntity>? _userSub;

  UserCubit(this._userRepository) : super(UserLoading());

  /// Llama a este método para arrancar la suscripción
  Future<void> init() async {
    // Emite Loading (si quieres)
    emit(UserLoading());

    try {
      // Primero obtenemos un valor único (await first)
      final user = await _userRepository.watchCurrentUser().first;
      emit(UserLoadSuccess(user));
      print('UserCubit: User loaded first: ${user.uid}');

      // Luego, si quieres seguir escuchando cambios:
      _userSub = _userRepository
          .watchCurrentUser()
          .skip(1) // saltamos el que ya usamos
          .listen(
        (u) {
          emit(UserLoadSuccess(u));
          print('UserCubit: User updated: ${u.uid}');
        },
        onError: (e) => emit(UserLoadFailure(e.toString())),
      );
    } catch (e) {
      emit(UserLoadFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
