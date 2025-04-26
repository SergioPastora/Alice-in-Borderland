// lib/features/users/domain/usecases/add_card_to_user_usecase.dart
import '../repositories/user_repository.dart';

class AddCardToUserUseCase {
  final UserRepository _repo;
  AddCardToUserUseCase(this._repo);

  Future<void> call(String userId, String code) {
    return _repo.addCardToUser(userId, code);
  }
}
