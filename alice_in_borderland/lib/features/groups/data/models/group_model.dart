// lib/features/groups/data/models/group_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_entity.dart';

/// Modelo que sabe serializar ⇄ Firestore
class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.nombre,
    required super.cartasColectivas,
    required super.miembros,
  });

  /// Crea un GroupModel a partir de un DocumentSnapshot de Firestore
  factory GroupModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;
    return GroupModel(
      id: snap.id,
      nombre: data['nombre'] as String,
      cartasColectivas: List<String>.from(data['cartasColectivas'] ?? []),
      miembros: List<String>.from(data['miembros'] ?? []),
    );
  }

  /// Convierte a Map para guardar en Firestore
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'cartasColectivas': cartasColectivas,
      'miembros': miembros,
    };
  }

  /// Convierte a la entidad pura de dominio
  GroupEntity toEntity() => this;
}
