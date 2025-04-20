const Map<String, String> cardCodeToName = {
  // Corazones
  'C_A': 'A Corazon',
  'C_2': '2 Corazon',
  'C_3': '3 Corazon',
  'C_4': '4 Corazon',
  'C_5': '5 Corazon',
  'C_6': '6 Corazon',
  'C_7': '7 Corazon',
  'C_8': '8 Corazon',
  'C_9': '9 Corazon',
  'C_10': '10 Corazon',
/*   'C_J': 'J Corazon',
  'C_Q': 'Q Corazon',
  'C_K': 'K Corazon', */

  // Diamantes
  'D_A': 'A Diamante',
  'D_2': '2 Diamante',
  'D_3': '3 Diamante',
  'D_4': '4 Diamante',
  'D_5': '5 Diamante',
  'D_6': '6 Diamante',
  'D_7': '7 Diamante',
  'D_8': '8 Diamante',
  'D_9': '9 Diamante',
  'D_10': '10 Diamante',
/*   'D_J': 'J Diamante',
  'D_Q': 'Q Diamante',
  'D_K': 'K Diamante', */

  // Tréboles
  'T_A': 'A Trebol',
  'T_2': '2 Trebol',
  'T_3': '3 Trebol',
  'T_4': '4 Trebol',
  'T_5': '5 Trebol',
  'T_6': '6 Trebol',
  'T_7': '7 Trebol',
  'T_8': '8 Trebol',
  'T_9': '9 Trebol',
  'T_10': '10 Trebol',
/*   'T_J': 'J Trebol',
  'T_Q': 'Q Trebol',
  'T_K': 'K Trebol', */

  // Picas
  'P_A': 'A Picas',
  'P_2': '2 Picas',
  'P_3': '3 Picas',
  'P_4': '4 Picas',
  'P_5': '5 Picas',
  'P_6': '6 Picas',
  'P_7': '7 Picas',
  'P_8': '8 Picas',
  'P_9': '9 Picas',
  'P_10': '10 Picas',
/*   'P_J': 'J Picas',
  'P_Q': 'Q Picas',
  'P_K': 'K Picas', */
};

/// Devuelve la ruta del asset de una carta, indicando si está desbloqueada
String cardAssetPath(String code, {required bool unlocked}) {
  final name = cardCodeToName[code]!;
  final folder = unlocked ? 'Cartas_unlocked' : 'Cartas_locked';
  return 'assets/$folder/$name.png';
}
