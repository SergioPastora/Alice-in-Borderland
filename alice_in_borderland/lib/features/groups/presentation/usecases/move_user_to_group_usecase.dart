// lib/features/groups/domain/usecases/move_user_to_group_usecase.dart
import 'package:alice_in_borderland/features/groups/domain/repositories/group_repository.dart';

class MoveUserToGroupUseCase {
  final GroupRepository _repo;
  MoveUserToGroupUseCase(this._repo);

  Future<void> call(String userId, String targetGroupId) {
    return _repo.moveUserToGroup(userId, targetGroupId);
  }
}
