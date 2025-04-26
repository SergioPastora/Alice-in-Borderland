// lib/features/groups/domain/repositories/group_repository.dart

import '../entities/group_entity.dart';

abstract class GroupRepository {
  Stream<GroupEntity> watchGroup(String groupId);
  Stream<List<GroupEntity>> watchAllGroups();
  Future<void> ensureGroupExists(String groupId);
  Future<void> syncGroupCards(String groupId);
  Future<void> moveUserToGroup(String userId, String targetGroupId);
  Future<void> updateGroup(GroupEntity group);
}
