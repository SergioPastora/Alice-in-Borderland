// lib/main.dart
import 'package:alice_in_borderland/features/events/domain/repositories/event_repository.dart';
import 'package:alice_in_borderland/features/events/domain/repositories/event_repository_impl.dart';
import 'package:alice_in_borderland/features/events/presentation/cubits/admin_event_cubit.dart';
import 'package:alice_in_borderland/features/events/presentation/cubits/event_cubit.dart';
import 'package:alice_in_borderland/features/events/presentation/cubits/map_event_cubit.dart';
import 'package:alice_in_borderland/features/ranking/presentation/cubit/ranking_cubit.dart';
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
import 'package:alice_in_borderland/features/groups/domain/repositories/group_repository_impl.dart';
import 'package:alice_in_borderland/features/users/domain/repositories/user_repository_impl.dart';

// UseCases
import 'features/users/domain/usecases/add_card_to_user_usecase.dart';
import 'package:alice_in_borderland/features/groups/presentation/usecases/move_user_to_group_usecase.dart';
import 'package:alice_in_borderland/features/groups/presentation/usecases/sync_group_cards_usecase.dart';

// Cubits
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/users/presentation/cubit/user_cubit.dart';
import 'features/groups/presentation/cubit/group_cubit.dart';
import 'features/visado/presentation/cubit/visado_cubit.dart';
import 'package:alice_in_borderland/features/admin/presentation/cubit/admin_group_cubit.dart';
import 'package:alice_in_borderland/features/admin/presentation/cubit/admin_user_cubit.dart';

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
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            fb.FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),
        RepositoryProvider<GroupRepository>(
          create: (_) => GroupRepositoryImpl(FirebaseFirestore.instance),
        ),
        RepositoryProvider<EventRepository>(
          create: (_) => EventRepositoryImpl(FirebaseFirestore.instance),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (ctx) => AuthCubit(
          ctx.read<AuthRepository>(),
          ctx.read<GroupRepository>(),
        ),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (ctx, authState) {
            if (authState is! Authenticated) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: AuthFlow(),
              );
            }

            final uid = authState.user.uid;
            final groupId = authState.user.grupoId ?? '0';

            // Repos y UseCases que dependen de uid y groupId
            final userRepo =
                UserRepositoryImpl(FirebaseFirestore.instance, uid);
            final addCardUC = AddCardToUserUseCase(userRepo);

            final groupRepo = ctx.read<GroupRepository>();
            final moveUserUC = MoveUserToGroupUseCase(groupRepo);
            final syncGroupCardsUC = SyncGroupCardsUseCase(groupRepo);

            return RepositoryProvider.value(
              value: userRepo,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<UserCubit>(
                    create: (_) => UserCubit(userRepo, addCardUC),
                  ),
                  BlocProvider<VisadoCubit>(
                    create: (_) => VisadoCubit(userRepo),
                  ),
                  BlocProvider<GroupCubit>(
                    create: (_) => GroupCubit(
                        groupRepo, moveUserUC, syncGroupCardsUC, groupId),
                  ),
                  BlocProvider<AdminUserCubit>(
                    create: (ctx) => AdminUserCubit(
                        ctx.read<UserRepositoryImpl>(), syncGroupCardsUC),
                  ),
                  BlocProvider<AdminGroupCubit>(
                    create: (ctx) =>
                        AdminGroupCubit(ctx.read<GroupRepository>()),
                  ),
                  BlocProvider<RankingCubit>(
                    create: (ctx) => RankingCubit(userRepo),
                  ),
                  BlocProvider<AdminEventCubit>(
                    create: (ctx) =>
                        AdminEventCubit(ctx.read<EventRepository>()),
                  ),
                  BlocProvider<EventCubit>(
                    create: (ctx) => EventCubit(ctx.read<EventRepository>()),
                  ),
                  BlocProvider<MapEventCubit>(
                    create: (ctx) => MapEventCubit(ctx.read<EventRepository>()),
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
