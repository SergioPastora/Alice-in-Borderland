// lib/features/ranking/presentation/cubit/ranking_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/repositories/user_repository.dart';

part 'ranking_state.dart';

class RankingCubit extends Cubit<RankingState> {
  final UserRepository _repo;
  StreamSubscription<List<UserEntity>>? _sub;

  RankingCubit(this._repo) : super(RankingState.loading()) {
    _sub = _repo.watchAllUsers().listen(
          (users) => emit(RankingState.data(users)),
          onError: (e) => emit(RankingState.error(e.toString())),
        );
  }

  void sortByVisado(bool ascending) {
    if (state is RankingData) {
      final data = (state as RankingData).users;
      data.sort((a, b) {
        final da = a.visadoHasta.difference(DateTime.now()).inSeconds;
        final db = b.visadoHasta.difference(DateTime.now()).inSeconds;
        return ascending ? da.compareTo(db) : db.compareTo(da);
      });
      emit(RankingState.data(List.of(data)));
    }
  }

  void sortByCartas(bool ascending) {
    if (state is RankingData) {
      final data = (state as RankingData).users;
      data.sort((a, b) {
        return ascending
            ? a.cartasGanadas.length.compareTo(b.cartasGanadas.length)
            : b.cartasGanadas.length.compareTo(a.cartasGanadas.length);
      });
      emit(RankingState.data(List.of(data)));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
