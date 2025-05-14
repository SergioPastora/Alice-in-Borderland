// lib/features/event/presentation/pages/event_map_page.dart

import 'dart:async';
import 'dart:math';
import 'package:alice_in_borderland/features/events/presentation/cubits/map_event_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/event_entity.dart';
import 'create_event_page.dart';
import 'package:alice_in_borderland/features/auth/presentation/cubit/auth_cubit.dart';

class EventMapPage extends StatefulWidget {
  const EventMapPage({super.key});

  @override
  State<EventMapPage> createState() => _EventMapPageState();
}

class _EventMapPageState extends State<EventMapPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final isAdmin = authState is Authenticated && authState.user.rol == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Eventos en el Mapa')),
      body: BlocBuilder<MapEventCubit, MapEventState>(
        builder: (ctx, state) {
          if (state is MapEventLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MapEventFailure) {
            return Center(child: Text(state.message));
          }
          final s = state as MapEventLoadSuccess;
          final markers = <Marker>{};
          final circles = <Circle>{};

          for (final e in s.events) {
            final pos = LatLng(e.location.latitude, e.location.longitude);
            markers.add(
              Marker(
                markerId: MarkerId(e.id),
                position: pos,
                infoWindow: InfoWindow(
                  title: e.nombre,
                  snippet:
                      '${e.radius.round()} m · Inicia: ${e.startsAt.toLocal().toString().split(" ")[0]}',
                  onTap: () => _onMarkerTap(e, s.currentPosition),
                ),
              ),
            );
            circles.add(
              Circle(
                circleId: CircleId(e.id),
                center: pos,
                radius: e.radius,
                fillColor: Colors.blue.withOpacity(0.1),
                strokeColor: Colors.blue,
                strokeWidth: 1,
              ),
            );
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: s.currentPosition,
              zoom: 14,
            ),
            markers: markers,
            circles: circles,
            myLocationEnabled: true,
            onMapCreated: (c) => _mapController.complete(c),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              child: const Icon(Icons.add_location_alt),
              tooltip: 'Crear evento',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateEventPage()),
                );
              },
            )
          : null,
    );
  }

  /// Al pulsar en la ventana de info de un marcador
  void _onMarkerTap(EventEntity e, LatLng me) {
    final dist = _distanceMeters(
      me,
      LatLng(e.location.latitude, e.location.longitude),
    );
    final dentro = dist <= e.radius;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(e.nombre, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Distancia: ${dist.round()} m'
                '  Radio: ${e.radius.round()} m'),
            const SizedBox(height: 8),
            Text('Inicia: ${e.startsAt.toLocal()}'.split(' ')[0]),
            const SizedBox(height: 16),
            if (dentro)
              ElevatedButton(
                child: const Text('Unirme'),
                onPressed: () {
                  final userId =
                      (context.read<AuthCubit>().state as Authenticated)
                          .user
                          .uid;
                  context.read<MapEventCubit>().subscribe(e.id, userId);
                  Navigator.pop(context);
                },
              )
            else
              const Text(
                'Estás fuera del radio de este evento',
                style: TextStyle(color: Colors.red),
              ),
          ]),
        );
      },
    );
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final hav = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLng / 2) * sin(dLng / 2) * cos(lat1) * cos(lat2);
    return 2 * R * asin(sqrt(hav));
  }

  double _rad(double deg) => deg * pi / 180;
}
