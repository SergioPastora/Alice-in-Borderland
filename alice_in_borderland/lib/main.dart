// lib/main.dart

import 'package:alice_in_borderland/features/groups/domain/repositories/group_repository_impl.dart';
import 'package:alice_in_borderland/features/users/domain/repositories/user_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// Repositorios
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/groups/domain/repositories/group_repository.dart';
import 'features/users/domain/repositories/user_repository.dart';

// Cubits
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/users/presentation/cubit/user_cubit.dart';
import 'features/groups/presentation/cubit/group_cubit.dart';
import 'features/visado/presentation/cubit/visado_cubit.dart';

// UI
import 'features/auth/presentation/widgets/auth_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // 1) Repositorios globales
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            fb.FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),
        RepositoryProvider<GroupRepository>(
          create: (_) => GroupRepositoryImpl(FirebaseFirestore.instance),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        // 2) AuthCubit necesita AuthRepository y GroupRepository
        create: (ctx) => AuthCubit(
          ctx.read<AuthRepository>(),
          ctx.read<GroupRepository>(),
        ),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            // 3a) Si no hay sesión, voy a la pantalla de login/splash
            if (authState is! Authenticated) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: AuthFlow(),
              );
            }

            // 3b) Si estamos autenticados, extraemos uid y groupId
            final uid = authState.user.uid;
            final groupId = authState.user.grupoId ?? '0';

            return RepositoryProvider<UserRepository>(
              // 4) Inyectamos UserRepository con el uid actual
              create: (_) => UserRepositoryImpl(
                FirebaseFirestore.instance,
                uid,
              ),
              child: MultiBlocProvider(
                // 5) Cubits que necesitan UserRepository y/o GroupRepository
                providers: [
                  BlocProvider<UserCubit>(
                    create: (ctx) => UserCubit(ctx.read<UserRepository>()),
                  ),
                  BlocProvider<VisadoCubit>(
                    create: (ctx) => VisadoCubit(ctx.read<UserRepository>()),
                  ),
                  BlocProvider<GroupCubit>(
                    create: (ctx) =>
                        GroupCubit(ctx.read<GroupRepository>(), groupId),
                  ),
                ],
                child: const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: AuthFlow(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
