import 'package:alice_in_borderland/features/auth/presentation/widgets/auth_flow.dart';
import 'package:alice_in_borderland/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // 2) Hacer la barra de estado transparente y sus iconos ligeros:
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepositoryImpl(
        fb.FirebaseAuth.instance,
        FirebaseFirestore.instance,
      ),
      child: BlocProvider<AuthCubit>(
        create: (ctx) => AuthCubit(ctx.read<AuthRepository>()),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AuthFlow(),
        ),
      ),
    );
  }
}
