import 'package:alice_in_borderland/features/users/data/models/user_model.dart';
import 'package:alice_in_borderland/features/users/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithGoogle();

  Future<void> ensureUserInFirestore(UserEntity user);

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}
