// lib/features/auth/presentation/widgets/auth_flow.dart

import 'dart:async';
import 'package:alice_in_borderland/core/card_constants.dart';
import 'package:alice_in_borderland/features/auth/presentation/pages/login_page.dart';
import 'package:alice_in_borderland/features/groups/presentation/cubit/group_cubit.dart';
import 'package:alice_in_borderland/features/home/presentation/pages/home_page.dart';
import 'package:alice_in_borderland/features/splash/presentation/pages/splash_page.dart';
import 'package:alice_in_borderland/features/users/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (ctx, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is Unauthenticated) {
          return LoginPage();
        }
        // Authenticated
        return const _AuthenticatedSplash();
      },
    );
  }
}

class _AuthenticatedSplash extends StatefulWidget {
  const _AuthenticatedSplash();
  @override
  State<_AuthenticatedSplash> createState() => _AuthenticatedSplashState();
}

class _AuthenticatedSplashState extends State<_AuthenticatedSplash> {
  bool _showSplash = true, _didPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrecache) {
      _didPrecache = true;
      // Pre‑carga de assets de cartas
      for (final name in cardCodeToName.values) {
        precacheImage(AssetImage('assets/Cartas_locked/$name.png'), context);
        precacheImage(AssetImage('assets/Cartas_unlocked/$name.png'), context);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // 1) Arrancamos UserCubit y GroupCubit
    final userCubit = context.read<UserCubit>();
    final groupCubit = context.read<GroupCubit>();

    // Llamamos init() y recogemos los futures
    final userInit = userCubit.init();
    final groupInit = groupCubit.init();

    // 2) Esperamos 2 s + ambos inits
    Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      userInit,
      groupInit,
      // el VisadoCubit, si emite al instante en constructor, ya está listo
    ]).then((_) {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashPage();
    }
    return const HomePage();
  }
}
