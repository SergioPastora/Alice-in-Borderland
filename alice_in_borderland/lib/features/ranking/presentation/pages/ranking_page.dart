// lib/features/ranking/presentation/pages/ranking_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ranking_cubit.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});
  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  bool _byVisado = true;
  bool _asc = true;

  @override
  void initState() {
    super.initState();
    context.read<RankingCubit>().sortByVisado(true);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color.fromARGB(255, 16, 36, 56);
    const cardColor = Color.fromARGB(255, 4, 21, 43);
    const accent = Color(0xFF00C4FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        title: const Text('Ranking'),
        backgroundColor: cardColor,
      ),
      body: Column(
        children: [
          Container(
            color: cardColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                DropdownButton<bool>(
                  dropdownColor: cardColor,
                  value: _byVisado,
                  underline: const SizedBox(),
                  iconEnabledColor: accent,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Visado')),
                    DropdownMenuItem(value: false, child: Text('Cartas')),
                  ],
                  onChanged: (v) {
                    setState(() => _byVisado = v!);
                    if (_byVisado) {
                      context.read<RankingCubit>().sortByVisado(_asc);
                    } else {
                      context.read<RankingCubit>().sortByCartas(_asc);
                    }
                  },
                ),
                const Spacer(),
                DropdownButton<bool>(
                  dropdownColor: cardColor,
                  value: _asc,
                  underline: const SizedBox(),
                  iconEnabledColor: accent,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Asc')),
                    DropdownMenuItem(value: false, child: Text('Desc')),
                  ],
                  onChanged: (v) {
                    setState(() => _asc = v!);
                    if (_byVisado) {
                      context.read<RankingCubit>().sortByVisado(_asc);
                    } else {
                      context.read<RankingCubit>().sortByCartas(_asc);
                    }
                  },
                ),
              ],
            ),
          ),

          // — Lista de usuarios dentro de Cards con sombra suave —
          Expanded(
            child: BlocBuilder<RankingCubit, RankingState>(
              builder: (ctx, state) {
                if (state is RankingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RankingError) {
                  return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.white)));
                }
                final users = (state as RankingData).users;
                if (users.isEmpty) {
                  return const Center(
                    child: Text('No hay usuarios',
                        style: TextStyle(color: Colors.white70)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: users.length,
                  itemBuilder: (ctx, i) {
                    final u = users[i];
                    final rem = u.visadoHasta.difference(DateTime.now());
                    final days = rem.inDays;
                    final hrs = rem.inHours % 24;
                    final mins = rem.inMinutes % 60;
                    return Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        title: Text(u.nombre,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                        subtitle: Text(
                          'Grupo: ${u.grupoId ?? "-"}   '
                          'Visado: ${days}d ${hrs}h ${mins}m   '
                          'Cartas: ${u.cartasGanadas.length}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Icon(Icons.chevron_right, color: accent),
                        onTap: () {
                          // TODO: Detalle en popup o nueva página...
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
