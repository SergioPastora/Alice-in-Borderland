import 'package:alice_in_borderland/data/models/user_model.dart';
import 'package:alice_in_borderland/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(
    this._firebaseAuth,
    this._firestore, {
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('El usuario canceló la autenticación con Google');
    }
    final googleAuth = await googleUser.authentication;

    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _firebaseAuth.signInWithCredential(credential);
    final fb.User fbUser = result.user!;

    final userModel = UserModel(
      uid: fbUser.uid,
      nombre: fbUser.displayName ?? '',
      email: fbUser.email ?? '',
      rol: 'usuario',
      vidas: 3,
      cartasGanadas: [],
      grupoId: null,
    );

    await _firestore
        .collection('usuarios')
        .doc(userModel.uid)
        .set(userModel.toJson(), SetOptions(merge: true));

    return userModel;
  }

  @override
  Future<void> ensureUserInFirestore(UserEntity user) async {
    final docRef = _firestore.collection('usuarios').doc(user.uid);
    final snap = await docRef.get();
    if (!snap.exists) {
      final userModel = user is UserModel
          ? user
          : UserModel(
              uid: user.uid,
              nombre: user.nombre,
              email: user.email,
              rol: user.rol,
              vidas: user.vidas,
              cartasGanadas: user.cartasGanadas,
              grupoId: user.grupoId,
            );

      await docRef.set(userModel.toJson());
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  UserModel? getCurrentUser() {
    final fb.User? fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return UserModel(
      uid: fbUser.uid,
      nombre: fbUser.displayName ?? '',
      email: fbUser.email ?? '',
      rol: 'usuario',
      vidas: 3,
      cartasGanadas: [],
      grupoId: null,
    );
  }
}
