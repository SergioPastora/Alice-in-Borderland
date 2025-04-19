import 'dart:async';
import 'package:alice_in_borderland/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../pages/login_page.dart';
import '../../../home/presentation/pages/home_page.dart';

class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is Unauthenticated) {
          return LoginPage();
        }
        if (state is Authenticated) {
          return const AuthenticatedSplash();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class AuthenticatedSplash extends StatefulWidget {
  const AuthenticatedSplash({super.key});

  @override
  State<AuthenticatedSplash> createState() => _AuthenticatedSplashState();
}

class _AuthenticatedSplashState extends State<AuthenticatedSplash> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashPage();
    }
    return HomePage();
  }
}
