import 'dart:async';
import 'package:alice_in_borderland/features/users/domain/entities/user_entity.dart';
import 'package:bloc/bloc.dart';
import '../../../users/domain/repositories/user_repository.dart';
import 'package:equatable/equatable.dart';

part 'visado_state.dart';

class VisadoCubit extends Cubit<VisadoState> {
  final UserRepository _userRepo;
  StreamSubscription<UserEntity>? _userSub;
  Timer? _ticker;
  DateTime? _visadoHasta;

  VisadoCubit(this._userRepo) : super(VisadoInitial()) {
    // 1) Capturamos inmediatamente la fecha del user
    _userSub = _userRepo.watchCurrentUser().listen((user) {
      _visadoHasta = user.visadoHasta;
      _startTicker();
    });
  }

  void _startTicker() {
    // Cancelamos cualquier ticker previo
    _ticker?.cancel();
    // 2) Emitimos al instante el primer estado
    final now = DateTime.now();
    final initialDiff = _visadoHasta!.difference(now);
    emit(initialDiff.isNegative
        ? VisadoFinished()
        : VisadoInProgress(initialDiff));

    // 3) Y arranca el Timer.periodic
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = _visadoHasta!.difference(DateTime.now());
      if (diff.isNegative) {
        emit(VisadoFinished());
        _ticker?.cancel();
      } else {
        emit(VisadoInProgress(diff));
      }
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _userSub?.cancel();
    return super.close();
  }
}
