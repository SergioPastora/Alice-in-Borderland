import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String uid,
    required String nombre,
    required String email,
    required String rol,
    required int vidas,
    required List<String> cartasGanadas,
    required DateTime visadoHasta,
    String? grupoId,
  }) : super(
          uid: uid,
          nombre: nombre,
          email: email,
          rol: rol,
          vidas: vidas,
          cartasGanadas: cartasGanadas,
          grupoId: grupoId,
          visadoHasta: visadoHasta,
        );

  /// Crea un UserModel a partir de un Map de Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      vidas: json['vidas'] as int,
      cartasGanadas: List<String>.from(json['cartasGanadas'] ?? []),
      grupoId: json['grupoId'] as String?,
      visadoHasta: (json['visadoHasta'] as Timestamp).toDate(),
    );
  }

  /// Crea un UserModel a partir de un DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;
    return UserModel.fromJson(data);
  }

  /// Convierte el UserModel a Map para guardar en Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'vidas': vidas,
      'cartasGanadas': cartasGanadas,
      'grupoId': grupoId,
      'visadoHasta': Timestamp.fromDate(visadoHasta),
    };
  }

  /// Para convertir a la entidad pura
  UserEntity toEntity() => this;
}
