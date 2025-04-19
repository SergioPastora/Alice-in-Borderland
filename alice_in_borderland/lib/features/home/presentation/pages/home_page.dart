// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1) Fondo de pantalla
          Positioned.fill(
            child: Image.asset(
              'assets/Fondo chatgpt.png', // <-- Asset: imagen de fondo
              fit: BoxFit.cover,
            ),
          ),

          // 2) Contenido principal dentro de SafeArea
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // 2.1) Botones superiores (Cartas / Visado)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón "Cartas" con su texto
                      GestureDetector(
                        onTap: () {/* navegar a Cartas */},
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/Logo_botones/Cartas_rbg.png', // <-- asset icono Cartas
                              width: 96,
                              height: 96,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Cartas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Botón "Visado" con su texto
                      GestureDetector(
                        onTap: () {/* navegar a Visado */},
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/Logo_botones/Visado_rbg.png', // <-- asset icono Visado
                              width: 96,
                              height: 96,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Visado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(), // empuja la barra inferior al fondo

                // 2.2) Barra de navegación inferior
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: navegar a Galería personal
                        },
                        child: Image.asset(
                          'assets/Logo_botones/Galeria_rbg.png', // <-- Asset: icono Galería
                          width: 72,
                          height: 72,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: navegar a Perfil/Ajustes
                        },
                        child: Image.asset(
                          'assets/Logo_botones/Perfil_rbg.png', // <-- Asset: icono Perfil
                          width: 72,
                          height: 72,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: navegar a Ranking
                        },
                        child: Image.asset(
                          'assets/Logo_botones/Ranking_rbg.png', // <-- Asset: icono Ranking
                          width: 72,
                          height: 72,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: navegar a Eventos cercanos
                        },
                        child: Image.asset(
                          'assets/Logo_botones/Ubicaciones_rbg.png', // <-- Asset: icono Ubicaciones
                          width: 72,
                          height: 72,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
