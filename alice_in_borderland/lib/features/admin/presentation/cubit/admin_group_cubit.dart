// lib/features/admin/presentation/cubit/admin_group_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/domain/repositories/group_repository.dart';

part 'admin_group_state.dart';

class AdminGroupCubit extends Cubit<AdminGroupState> {
  final GroupRepository _repo;
  StreamSubscription<List<GroupEntity>>? _sub;

  AdminGroupCubit(this._repo) : super(AdminGroupLoading()) {
    _sub = _repo.watchAllGroups().listen(
          (list) => emit(AdminGroupLoadSuccess(list)),
          onError: (e) => emit(AdminGroupFailure(e.toString())),
        );
  }

  Future<void> updateGroup(GroupEntity g) async {
    emit(AdminGroupLoading());
    try {
      await _repo.updateGroup(g);
      final all = await _repo.watchAllGroups().first;
      emit(AdminGroupLoadSuccess(all));
    } catch (e) {
      emit(AdminGroupFailure(e.toString()));
    }
  }

  Future<void> moveUser(String userId, String targetGroupId) async {
    emit(AdminGroupLoading());
    try {
      await _repo.moveUserToGroup(userId, targetGroupId);
      final all = await _repo.watchAllGroups().first;
      emit(AdminGroupLoadSuccess(all));
    } catch (e) {
      emit(AdminGroupFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
