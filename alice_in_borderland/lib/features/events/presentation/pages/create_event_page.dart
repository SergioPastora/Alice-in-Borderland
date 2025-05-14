// lib/features/event/presentation/pages/create_event_page.dart

import 'dart:async';
import 'package:alice_in_borderland/features/events/domain/entities/event_entity.dart';
import 'package:alice_in_borderland/features/events/presentation/cubits/admin_event_cubit.dart';
import 'package:alice_in_borderland/features/users/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  LatLng? _marker;
  double _radius = 100;
  DateTime _startsAt = DateTime.now().add(const Duration(hours: 1));
  final _nameCtl = TextEditingController();
  final _mapCtrl = Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Evento')),
      body: Column(children: [
        TextField(
          controller: _nameCtl,
          decoration: const InputDecoration(labelText: 'Nombre del evento'),
        ),
        SizedBox(
          height: 300,
          child: GoogleMap(
            onMapCreated: (c) => _mapCtrl.complete(c),
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
            onTap: (pos) => setState(() => _marker = pos),
            markers: _marker == null
                ? {}
                : {Marker(markerId: const MarkerId('ev'), position: _marker!)},
            circles: _marker == null
                ? {}
                : {
                    Circle(
                      circleId: const CircleId('r'),
                      center: _marker!,
                      radius: _radius,
                      fillColor: Colors.blue.withOpacity(0.2),
                      strokeColor: Colors.blue,
                    )
                  },
          ),
        ),
        Row(
          children: [
            const Text('Radio (m):'),
            Expanded(
              child: Slider(
                min: 0,
                max: 100000,
                divisions: 20,
                label: _radius.round().toString(),
                value: _radius,
                onChanged: (v) => setState(() => _radius = v),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Inicio:'),
            TextButton(
              child: Text('${_startsAt.toLocal()}'.split(' ')[0]),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _startsAt,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _startsAt = d);
              },
            ),
          ],
        ),
        BlocConsumer<AdminEventCubit, AdminEventState>(
          listener: (ctx, state) {
            if (state is AdminEventSuccess) {
              Navigator.pop(context);
            }
            if (state is AdminEventFailure) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (ctx, st) {
            if (st is AdminEventLoading) {
              return const CircularProgressIndicator();
            }
            return ElevatedButton(
              onPressed: _marker == null
                  ? null
                  : () {
                      final userState = context.read<UserCubit>().state;
                      final userId = userState is UserLoadSuccess
                          ? userState.user.uid
                          : '';
                      final evt = EventEntity(
                        id: '',
                        nombre: _nameCtl.text,
                        location: GeoPoint(
                          _marker!.latitude,
                          _marker!.longitude,
                        ),
                        radius: _radius,
                        creadorId: userId,
                        startsAt: _startsAt,
                      );
                      context.read<AdminEventCubit>().createEvent(evt);
                    },
              child: const Text('Guardar Evento'),
            );
          },
        ),
      ]),
    );
  }
}
