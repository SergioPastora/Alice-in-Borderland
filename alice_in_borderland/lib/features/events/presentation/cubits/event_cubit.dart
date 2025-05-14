// lib/features/event/presentation/cubit/event_cubit.dart

import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:location/location.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository _repo;
  StreamSubscription<List<EventEntity>>? _sub;
  LatLng? _currentPos;

  EventCubit(this._repo) : super(EventLoading()) {
    _init();
  }

  Future<void> _init() async {
    emit(EventLoading());
    // 1) Obtiene ubicación
    final loc = Location();
    final data = await loc.getLocation();
    _currentPos = LatLng(data.latitude!, data.longitude!);

    // 2) Escucha eventos
    _sub = _repo.watchUpcomingEvents().listen((events) {
      // 3) Filtra manualmente por distancia
      final nearby = events.where((e) {
        final ePos = LatLng(e.location.latitude, e.location.longitude);
        final dist = _distanceMeters(_currentPos!, ePos);
        return dist <= e.radius;
      }).toList();
      emit(EventLoadSuccess(nearby));
    }, onError: (e) {
      emit(EventError(e.toString()));
    });
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final hav = (sin(dLat / 2) * sin(dLat / 2)) +
        (sin(dLng / 2) * sin(dLng / 2)) * cos(lat1) * cos(lat2);
    return 2 * R * asin(sqrt(hav));
  }

  double _rad(double deg) => deg * pi / 180;

  Future<void> subscribe(String eventId, String userId) {
    return _repo.subscribeToEvent(eventId, userId);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
