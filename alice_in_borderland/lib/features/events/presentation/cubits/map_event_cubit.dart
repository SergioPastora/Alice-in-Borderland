// lib/features/event/presentation/cubit/map_event_cubit.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';

part 'map_event_state.dart';

class MapEventCubit extends Cubit<MapEventState> {
  final EventRepository _repo;
  StreamSubscription<List<EventEntity>>? _sub;

  MapEventCubit(this._repo) : super(const MapEventLoading()) {
    _init();
  }

  Future<void> _init() async {
    emit(const MapEventLoading());

    // 1) Obtiene ubicación actual
    final loc = Location();
    final hasPerm = await loc.requestPermission();
    if (hasPerm != PermissionStatus.granted) {
      emit(const MapEventFailure('Permiso de ubicación no concedido'));
      return;
    }
    final data = await loc.getLocation();
    final currentPos = LatLng(data.latitude!, data.longitude!);

    // 2) Escucha todos los eventos próximos
    _sub = _repo.watchUpcomingEvents().listen((events) {
      emit(MapEventLoadSuccess(events: events, currentPosition: currentPos));
    }, onError: (e) {
      emit(MapEventFailure(e.toString()));
    });
  }

  /// Únete a un evento (añade tu uid)
  Future<void> subscribe(String eventId, String userId) {
    return _repo.subscribeToEvent(eventId, userId);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
