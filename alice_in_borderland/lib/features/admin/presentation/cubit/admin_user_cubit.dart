// lib/features/admin/presentation/cubit/admin_user_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/repositories/user_repository.dart';

part 'admin_user_state.dart';

class AdminUserCubit extends Cubit<AdminUserState> {
  final UserRepository _repo;
  StreamSubscription<List<UserEntity>>? _sub;

  AdminUserCubit(this._repo) : super(AdminUserLoading()) {
    // Inicial: suscripción a todos los usuarios
    _sub = _repo.watchAllUsers().listen(
          (list) => emit(AdminUserLoadSuccess(list)),
          onError: (e) => emit(AdminUserFailure(e.toString())),
        );
  }

  Future<void> updateUser(UserEntity u) async {
    emit(AdminUserLoading());
    try {
      await _repo.updateUser(u);
      // re-emitimos la lista actualizada:
      final all = await _repo.watchAllUsers().first;
      emit(AdminUserLoadSuccess(all));
    } catch (e) {
      emit(AdminUserFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
