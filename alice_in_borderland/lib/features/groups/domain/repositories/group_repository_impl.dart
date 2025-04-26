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
        // grupo vacío si no existe
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
    if (!(await doc.get()).exists) {
      await doc.set({
        'nombre': 'Grupo $groupId',
        'miembros': <String>[],
        'cartasColectivas': <String>[],
      });
    }
  }

  @override
  Future<void> moveUserToGroup(String userId, String targetGroupId) async {
    // 1) Aseguramos que exista el grupo destino
    await ensureGroupExists(targetGroupId);

    // 2) Buscamos todos los grupos donde esté el usuario
    final origenSnap = await _firestore
        .collection('grupos')
        .where('miembros', arrayContains: userId)
        .get();

    // 3) Preparamos un batch para quitárselo a todos y añadirlo al destino
    final batch = _firestore.batch();

    for (final doc in origenSnap.docs) {
      batch.update(doc.reference, {
        'miembros': FieldValue.arrayRemove([userId]),
      });
    }

    final targetRef = _firestore.collection('grupos').doc(targetGroupId);
    batch.update(targetRef, {
      'miembros': FieldValue.arrayUnion([userId]),
    });

    // 4) Ejecutamos el batch
    await batch.commit();

    // 5) Sincronizamos cartas en todos los grupos afectados
    for (final doc in origenSnap.docs) {
      await syncGroupCards(doc.id);
    }
    await syncGroupCards(targetGroupId);
  }

  @override
  Future<void> syncGroupCards(String groupId) async {
    final groupRef = _firestore.collection('grupos').doc(groupId);
    final snap = await groupRef.get();
    final data = snap.data() ?? {};

    // 1) Lista de miembros actual
    final miembros =
        (data['miembros'] as List<dynamic>?)?.cast<String>() ?? <String>[];

    // 2) Recogemos las cartas de cada miembro
    final listas = await Future.wait(miembros.map((uid) async {
      final uSnap = await _firestore.collection('usuarios').doc(uid).get();
      final uData = uSnap.data() ?? {};
      return (uData['cartasGanadas'] as List<dynamic>?)?.cast<String>() ??
          <String>[];
    }));

    // 3) Unión sin duplicados
    final union = <String>{};
    for (final lst in listas) union.addAll(lst);

    // 4) Persistimos sólo el campo cartasColectivas
    await groupRef.set({
      'cartasColectivas': union.toList(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<GroupEntity>> watchAllGroups() {
    return _firestore.collection('grupos').snapshots().map((snap) => snap.docs
        .map((doc) => GroupModel.fromSnapshot(doc).toEntity())
        .toList());
  }

  @override
  Future<void> updateGroup(GroupEntity group) {
    final model = group is GroupModel
        ? group
        : GroupModel(
            id: group.id,
            nombre: group.nombre,
            cartasColectivas: group.cartasColectivas,
            miembros: group.miembros,
          );
    return _firestore
        .collection('grupos')
        .doc(model.id)
        .set(model.toJson(), SetOptions(merge: true));
  }
}
