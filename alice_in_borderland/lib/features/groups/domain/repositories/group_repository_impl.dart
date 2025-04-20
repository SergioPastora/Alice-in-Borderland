// lib/features/groups/data/repositories/group_repository_impl.dart

import 'package:alice_in_borderland/features/groups/data/models/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final FirebaseFirestore _firestore;
  GroupRepositoryImpl(this._firestore);

  @override
  Stream<GroupEntity> watchGroup(String groupId) {
    return _firestore.collection('grupos').doc(groupId).snapshots().map((snap) {
      if (!snap.exists) {
        return GroupEntity(
          id: groupId,
          nombre: 'Grupo $groupId',
          cartasColectivas: [],
          miembros: [],
        );
      }
      return GroupModel.fromSnapshot(snap).toEntity();
    });
  }

  @override
  Future<void> ensureGroupExists(String groupId) async {
    final doc = _firestore.collection('grupos').doc(groupId);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'nombre': 'Grupo $groupId',
        'miembros': <String>[],
        'cartasColectivas': <String>[],
      });
    }
  }

  @override
  Future<void> moveUserToGroup(String userId, String targetGroupId) async {
    // 1) Buscamos todos los grupos donde esté el usuario
    final gruposConUser = await _firestore
        .collection('grupos')
        .where('miembros', arrayContains: userId)
        .get();

    final batch = _firestore.batch();

    // 2) Quitarlo de cada uno
    for (final doc in gruposConUser.docs) {
      batch.update(doc.reference, {
        'miembros': FieldValue.arrayRemove([userId]),
      });
    }

    // 3) Aseguramos que el grupo destino exista
    final targetRef = _firestore.collection('grupos').doc(targetGroupId);
    batch.set(
      targetRef,
      {
        'nombre': 'Grupo $targetGroupId',
        'miembros': <String>[],
        'cartasColectivas': <String>[],
      },
      SetOptions(merge: true),
    );

    // 4) Lo añadimos al grupo destino
    batch.update(targetRef, {
      'miembros': FieldValue.arrayUnion([userId]),
    });

    // 5) Ejecutamos todo en transacción
    await batch.commit();
  }

  @override
  Future<void> syncGroupCards(String groupId) async {
    final groupRef = _firestore.collection('grupos').doc(groupId);
    final groupSnap = await groupRef.get();
    final data = groupSnap.data();
    final miembros =
        (data?['miembros'] as List<dynamic>?)?.cast<String>() ?? [];

    // 2) Recogemos todas las cartas de cada miembro
    final cartasList = await Future.wait(miembros.map((uid) async {
      final userDoc = await _firestore.collection('usuarios').doc(uid).get();
      final userData = userDoc.data();
      return (userData?['cartasGanadas'] as List<dynamic>?)?.cast<String>() ??
          <String>[];
    }));

    // 3) Unimos y sin duplicados
    final union = <String>{};
    for (final cartas in cartasList) union.addAll(cartas);

    // 4) Persistimos en el documento del grupo
    await groupRef.set({
      'cartasColectivas': union.toList(),
    }, SetOptions(merge: true));
  }
}
