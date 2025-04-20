import 'package:alice_in_borderland/features/users/domain/entities/user_entity.dart';

abstract class UserRepository {
  Stream<UserEntity> watchCurrentUser();
  Future<void> addCardToUser(String code);
}
