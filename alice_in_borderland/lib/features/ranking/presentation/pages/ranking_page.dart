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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: Column(
        children: [
          // Controles de orden
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Campo
                DropdownButton<bool>(
                  value: _byVisado,
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
                const SizedBox(width: 16),
                // Orden
                DropdownButton<bool>(
                  value: _asc,
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

          // Lista
          Expanded(
            child: BlocBuilder<RankingCubit, RankingState>(
              builder: (ctx, state) {
                if (state is RankingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RankingError) {
                  return Center(child: Text(state.message));
                }
                final users = (state as RankingData).users;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (ctx, i) {
                    final u = users[i];
                    final rem = u.visadoHasta.difference(DateTime.now());
                    final days = rem.inDays;
                    final hrs = rem.inHours % 24;
                    final mins = rem.inMinutes % 60;
                    return ListTile(
                      title: Text(u.nombre),
                      subtitle: Text(
                        'Grupo: ${u.grupoId ?? "-"}  '
                        'Visado: ${days}d ${hrs}h ${mins}m  '
                        'Cartas: ${u.cartasGanadas.length}',
                      ),
                      onTap: () {
                        // detalle en popup o página
                      },
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
