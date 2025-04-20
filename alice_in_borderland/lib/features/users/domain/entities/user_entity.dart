class UserEntity {
  final String uid;
  final String nombre;
  final String email;
  final String rol;
  final int vidas;
  final List<String> cartasGanadas;
  final String? grupoId;
  final DateTime visadoHasta;

  const UserEntity({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.vidas,
    required this.cartasGanadas,
    required this.visadoHasta,
    this.grupoId,
  });
}
