import 'package:alice_in_borderland/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithGoogle();

  Future<void> ensureUserInFirestore(UserEntity user);

  Future<void> signOut();

  UserEntity? getCurrentUser();
}
