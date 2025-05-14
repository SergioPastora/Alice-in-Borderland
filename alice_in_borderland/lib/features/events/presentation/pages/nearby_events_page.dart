// lib/features/event/presentation/pages/nearby_events_page.dart

import 'package:alice_in_borderland/features/events/presentation/cubits/event_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alice_in_borderland/features/auth/presentation/cubit/auth_cubit.dart';

class NearbyEventsPage extends StatelessWidget {
  const NearbyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos Cercanos')),
      body: BlocBuilder<EventCubit, EventState>(
        builder: (ctx, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EventError) {
            return Center(child: Text(state.message));
          }
          final evs = (state as EventLoadSuccess).events;
          final userId =
              (context.read<AuthCubit>().state as Authenticated).user.uid;
          return ListView.builder(
            itemCount: evs.length,
            itemBuilder: (ctx, i) {
              final e = evs[i];
              return ListTile(
                title: Text(e.nombre),
                subtitle: Text('A ${e.radius.round()}m'),
                trailing: ElevatedButton(
                  child: const Text('Unirme'),
                  onPressed: () {
                    context.read<EventCubit>().subscribe(e.id, userId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
