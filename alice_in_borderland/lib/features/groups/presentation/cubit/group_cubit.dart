// lib/features/groups/presentation/cubit/group_cubit.dart

import 'dart:async';
import 'package:alice_in_borderland/features/groups/presentation/usecases/move_user_to_group_usecase.dart';
import 'package:alice_in_borderland/features/groups/presentation/usecases/sync_group_cards_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';

part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupRepository _repo;
  final MoveUserToGroupUseCase _moveUser;
  final SyncGroupCardsUseCase _syncCards;
  final String _groupId;

  StreamSubscription<GroupEntity>? _sub;

  GroupCubit(
    this._repo,
    this._moveUser,
    this._syncCards,
    this._groupId,
  ) : super(GroupLoading()) {}

  Future<void> init() async {
    emit(GroupLoading());
    try {
      // Aseguro que los grupos '0', '1' y el del usuario existan
      await _repo.ensureGroupExists('0');
      await _repo.ensureGroupExists('1');
      await _repo.ensureGroupExists(_groupId);

      // Sincronizo las cartas antes de suscribirme
      await _syncCards(_groupId);

      // Ahora escucho el stream real del grupo
      _sub = _repo.watchGroup(_groupId).listen(
            (g) => emit(GroupLoadSuccess(g)),
            onError: (e) => emit(GroupLoadFailure(e.toString())),
          );
    } catch (e) {
      emit(GroupLoadFailure(e.toString()));
    }
  }

  /// Método para mover un usuario y volver a sincronizar cartas
  Future<void> moveUserAndSync(String userId, String targetGroupId) async {
    emit(GroupLoading());
    try {
      await _moveUser(userId, targetGroupId);
      await _syncCards(targetGroupId);
      emit(GroupLoadSuccess(await _repo.watchGroup(targetGroupId).first));
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
