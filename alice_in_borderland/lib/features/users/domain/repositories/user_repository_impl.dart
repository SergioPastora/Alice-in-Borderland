import 'package:alice_in_borderland/features/users/data/models/user_model.dart';
import 'package:alice_in_borderland/features/users/domain/entities/user_entity.dart';
import 'package:alice_in_borderland/features/users/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final String _uid;
  UserRepositoryImpl(this._firestore, this._uid);

  @override
  Stream<UserEntity> watchCurrentUser() {
    return _firestore
        .collection('usuarios')
        .doc(_uid)
        .snapshots()
        .map((snap) => UserModel.fromSnapshot(snap).toEntity());
  }

  @override
  Future<void> addCardToUser(String userId, String code) async {
    final userRef = _firestore.collection('usuarios').doc(userId);

    await userRef.update({
      'cartasGanadas': FieldValue.arrayUnion([code]),
    });
  }

  @override
  Stream<List<UserEntity>> watchAllUsers() {
    return _firestore.collection('usuarios').snapshots().map((snap) => snap.docs
        .map((doc) => UserModel.fromSnapshot(doc).toEntity())
        .toList());
  }

  @override
  Future<void> updateUser(UserEntity user) {
    final model = user is UserModel ? user : UserModel.fromEntity(user);
    return _firestore
        .collection('usuarios')
        .doc(user.uid)
        .set(model.toJson(), SetOptions(merge: true));
  }
}
