// lib/features/event/presentation/cubit/admin_event_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import 'package:equatable/equatable.dart';

part 'admin_event_state.dart';

class AdminEventCubit extends Cubit<AdminEventState> {
  final EventRepository _repo;
  AdminEventCubit(this._repo) : super(AdminEventInitial());

  Future<void> createEvent(EventEntity e) async {
    emit(AdminEventLoading());
    try {
      await _repo.createEvent(e);
      emit(AdminEventSuccess());
    } catch (err) {
      emit(AdminEventFailure(err.toString()));
    }
  }
}
