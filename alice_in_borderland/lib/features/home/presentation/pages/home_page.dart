import 'package:alice_in_borderland/features/admin/presentation/pages/admin_page.dart';
import 'package:alice_in_borderland/features/events/presentation/pages/map_page.dart';
import 'package:alice_in_borderland/features/gallery/presentation/gallery_page.dart';
import 'package:alice_in_borderland/features/groups/presentation/cubit/group_cubit.dart';
import 'package:alice_in_borderland/features/profile/presentation/pages/porfile_page.dart';
import 'package:alice_in_borderland/features/ranking/presentation/pages/ranking_page.dart';
import 'package:alice_in_borderland/features/users/presentation/cubit/user_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alice_in_borderland/features/visado/presentation/pages/visado_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openDriveLink() async {
    final snap = await FirebaseFirestore.instance
        .collection('config')
        .doc('linkDrive')
        .get();
    final urlString = snap.data()?['url'] as String?;
    if (urlString == null) return;

    final uri = Uri.parse(urlString);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint('No se pudo abrir $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1) Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/Fondo chatgpt.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2) Contenido
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final topIconSize = w * 0.22;
                final topSpacing = w * 0.04;
                final leftPadding = w * 0.05;
                final textFontSize = topIconSize * 0.2;
                final bottomIconSize = w * 0.16;
                final bottomPadding = h * 0.04;

                final userState = context.watch<UserCubit>().state;
                final groupState = context.watch<GroupCubit>().state;
                final isAdmin = userState is UserLoadSuccess &&
                    userState.user.rol == 'admin';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: h * 0.03),

                    // Row Cartas / Visado / (Admin)
                    Padding(
                      padding: EdgeInsets.only(left: leftPadding),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cartas
                          GestureDetector(
                            onTap: () {
                              if (userState is UserLoadSuccess &&
                                  groupState is GroupLoadSuccess) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GalleryPage(
                                      personalCards:
                                          userState.user.cartasGanadas,
                                      groupCards:
                                          groupState.group.cartasColectivas,
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

                          // Visado
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

                          // Admin (solo si es admin)
                          if (isAdmin) ...[
                            SizedBox(width: topSpacing),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AdminPage(),
                                ),
                              ),
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

                    // Barra de navegación inferior
                    Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 1) Drive link
                          GestureDetector(
                            onTap: _openDriveLink,
                            child: Image.asset(
                              'assets/Logo_botones/Galeria_rbg.png',
                              width: bottomIconSize,
                              height: bottomIconSize,
                            ),
                          ),

                          // 2) Perfil
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            ),
                            child: Image.asset(
                              'assets/Logo_botones/Perfil_rbg.png',
                              width: bottomIconSize,
                              height: bottomIconSize,
                            ),
                          ),

                          // 3) Ranking
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RankingPage(),
                              ),
                            ),
                            child: Image.asset(
                              'assets/Logo_botones/Ranking_rbg.png',
                              width: bottomIconSize,
                              height: bottomIconSize,
                            ),
                          ),

                          // 4) Mapa
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MapPage(),
                              ),
                            ),
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
