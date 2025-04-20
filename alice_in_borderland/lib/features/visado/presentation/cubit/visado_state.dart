part of 'visado_cubit.dart';

abstract class VisadoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisadoInitial extends VisadoState {}

class VisadoInProgress extends VisadoState {
  final Duration remaining;
  VisadoInProgress(this.remaining);

  String get formatted {
    final days = remaining.inDays.toString().padLeft(2, '0');
    final hours = (remaining.inHours % 24).toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$days:$hours:$minutes:$seconds';
  }

  @override
  List<Object?> get props => [remaining];
}

class VisadoFinished extends VisadoState {
  @override
  List<Object?> get props => [];
}
