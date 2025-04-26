// lib/features/groups/domain/usecases/sync_group_cards_usecase.dart

import 'package:alice_in_borderland/features/groups/domain/repositories/group_repository.dart';

class SyncGroupCardsUseCase {
  final GroupRepository _repo;
  SyncGroupCardsUseCase(this._repo);

  /// Recalcula la unión de todas las cartas de los miembros de [groupId]
  /// y las persiste en Firestore sin tocar el array de miembros.
  Future<void> call(String groupId) {
    return _repo.syncGroupCards(groupId);
  }
}
