import 'package:alice_in_borderland/features/admin/presentation/pages/admin_page.dart';
import 'package:alice_in_borderland/features/gallery/presentation/gallery_page.dart';
import 'package:alice_in_borderland/features/groups/presentation/cubit/group_cubit.dart';
import 'package:alice_in_borderland/features/users/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:alice_in_borderland/features/visado/presentation/pages/visado_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

          // 2) Contenido principal
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                final topIconSize = w * 0.22; // iconos arriba: ~22% ancho
                final topSpacing = w * 0.04; // espacio entre iconos
                final leftPadding = w * 0.05; // padding izquierda
                final textFontSize = topIconSize * 0.2; // fuente bajo iconos

                final bottomIconSize = w * 0.16; // iconos abajo: ~16% ancho
                final bottomPadding = h * 0.04; // padding inferior

                final userState = context.watch<UserCubit>().state;
                final isAdmin = userState is UserLoadSuccess &&
                    userState.user.rol == 'admin';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: h * 0.03),

                    // 2.1) Botones superiores (Cartas / Visado)
                    Padding(
                      padding: EdgeInsets.only(left: leftPadding),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // -- Cartas --
                          GestureDetector(
                            onTap: () {
                              final gs = context.read<GroupCubit>().state;
                              if (userState is UserLoadSuccess &&
                                  gs is GroupLoadSuccess) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GalleryPage(
                                      personalCards:
                                          userState.user.cartasGanadas,
                                      groupCards: gs.group.cartasColectivas,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/Logo_botones/Cartas_rbg.png',
                                  width: topIconSize,
                                  height: topIconSize,
                                ),
                                SizedBox(height: h * 0.01),
                                Text(
                                  'Cartas',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: textFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: topSpacing),

                          // -- Visado --
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const VisadoPage(),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/Logo_botones/Visado_rbg.png',
                                  width: topIconSize,
                                  height: topIconSize,
                                ),
                                SizedBox(height: h * 0.01),
                                Text(
                                  'Visado',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: textFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // -- Admin (solo si es admin) --
                          if (isAdmin) ...[
                            SizedBox(width: topSpacing),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AdminPage(),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: topIconSize,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: h * 0.01),
                                  Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: textFontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Spacer(),

                    // 2.2) Barra de navegación inferior
                    Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {/* navegar a Galería personal */},
                            child: Image.asset(
                              'assets/Logo_botones/Galeria_rbg.png',
                              width: bottomIconSize,
                              height: bottomIconSize,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {/* navegar a Perfil/Ajustes */},
                            child: Image.asset(
                              'assets/Logo_botones/Perfil_rbg.png',
                              width: bottomIconSize,
                              height: bottomIconSize,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {/* navegar a Ranking */},
                            child: Image.asset(
                              'assets/Logo_botones/Ranking_rbg.png',
                              width: bottomIconSize,
                              height: bottomIconSize,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {/* navegar a Eventos cercanos */},
                            child: Image.asset(
                              'assets/Logo_botones/Ubicaciones_rbg.png',
                              width: bottomIconSize,
                              height: bottomIconSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
