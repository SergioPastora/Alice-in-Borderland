import 'package:alice_in_borderland/features/splash/presentation/pages/splash_page.dart';
import 'package:alice_in_borderland/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepositoryImpl(
        FirebaseAuth.instance,
        FirebaseFirestore.instance,
      ),
      child: BlocProvider<AuthCubit>(
        create: (ctx) => AuthCubit(ctx.read<AuthRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthInitial) {
                return SplashPage();
              }
              if (state is Unauthenticated) {
                return LoginPage();
              }
              if (state is Authenticated) {
                return HomePage();
              }
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }
}
