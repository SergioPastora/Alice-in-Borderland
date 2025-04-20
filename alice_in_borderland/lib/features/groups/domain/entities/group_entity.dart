// lib/features/groups/domain/entities/group_entity.dart

class GroupEntity {
  final String id;
  final String nombre;
  final List<String> cartasColectivas;
  final List<String> miembros;

  const GroupEntity({
    required this.id,
    required this.nombre,
    required this.cartasColectivas,
    required this.miembros,
  });
}
