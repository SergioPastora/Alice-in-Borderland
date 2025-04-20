// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:alice_in_borderland/features/users/data/models/user_model.dart';
import 'package:alice_in_borderland/features/users/domain/entities/user_entity.dart';
import 'package:alice_in_borderland/features/users/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final UserRepository? _userRepository; // opcional

  AuthRepositoryImpl(
    this._firebaseAuth,
    this._firestore, {
    GoogleSignIn? googleSignIn,
    UserRepository? userRepository,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _userRepository = userRepository;

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

    // Creamos el modelo con grupo "0" por defecto
    final userModel = UserModel(
      uid: fbUser.uid,
      nombre: fbUser.displayName ?? '',
      email: fbUser.email ?? '',
      rol: 'usuario',
      vidas: 3,
      cartasGanadas: <String>[],
      grupoId: '0',
      visadoHasta: DateTime.now().add(const Duration(days: 7)),
    );

    // Guardamos en Firestore (merge: true para no sobrescribir otros campos)
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
      // Convertimos la entidad a modelo si hace falta
      final model = user is UserModel
          ? user
          : UserModel(
              uid: user.uid,
              nombre: user.nombre,
              email: user.email,
              rol: user.rol,
              vidas: user.vidas,
              cartasGanadas: user.cartasGanadas,
              grupoId: user.grupoId ?? '0', // default a '0'
              visadoHasta: user.visadoHasta,
            );
      await docRef.set(model.toJson());
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
  Future<UserModel?> getCurrentUser() async {
    final fb.User? fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;

    // Si tienes un UserRepository inyectado, podrías usarlo:
    if (_userRepository != null) {
      try {
        final entity = await _userRepository.watchCurrentUser().first;
        return entity is UserModel
            ? entity
            : UserModel(
                uid: entity.uid,
                nombre: entity.nombre,
                email: entity.email,
                rol: entity.rol,
                vidas: entity.vidas,
                cartasGanadas: entity.cartasGanadas,
                grupoId: entity.grupoId ?? '0',
                visadoHasta: entity.visadoHasta,
              );
      } catch (_) {
        // si falla el repo, caemos al fallback directo
      }
    }

    // Fallback: leemos Firestore a pelo
    final snap = await _firestore.collection('usuarios').doc(fbUser.uid).get();
    if (!snap.exists || snap.data() == null) return null;

    // Aquí suponemos que tienes factory fromSnapshot en UserModel
    return UserModel.fromSnapshot(snap);
  }
}
