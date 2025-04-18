import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashCompleted extends SplashState {}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void startSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    emit(SplashCompleted());
  }
}
