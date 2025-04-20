// lib/features/groups/presentation/cubit/group_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';

part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupRepository _repo;
  final String _groupId;
  StreamSubscription<GroupEntity>? _sub;

  GroupCubit(this._repo, this._groupId) : super(GroupLoading());

  /// Inicializa el cubit: crea los grupos "0" y "1" si no existen,
  /// luego asegura el grupo del usuario y se suscribe al stream.
  Future<void> init() async {
    emit(GroupLoading());
    try {
      // … asegurar existencia de grupos 0 y 1 …
      await _repo.ensureGroupExists('0');
      await _repo.ensureGroupExists('1');
      await _repo.ensureGroupExists(_groupId);

      // **Sincroniza las cartas** en el grupo _antes_ de escuchar
      await _repo.syncGroupCards(_groupId);

      // Ahora sí, suscríbete al stream que ya incluye cartasColectivas actualizadas
      _sub = _repo.watchGroup(_groupId).listen(
            (g) => emit(GroupLoadSuccess(g)),
            onError: (e) => emit(GroupLoadFailure(e.toString())),
          );
    } catch (e) {
      emit(GroupLoadFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
