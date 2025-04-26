import 'package:alice_in_borderland/features/users/domain/entities/user_entity.dart';

abstract class UserRepository {
  Stream<UserEntity> watchCurrentUser();
  Stream<List<UserEntity>> watchAllUsers();
  Future<void> addCardToUser(String userId, String code);
  Future<void> updateUser(UserEntity user);
}
