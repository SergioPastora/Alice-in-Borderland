import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    final user = (ctx.read<AuthCubit>().state as Authenticated).user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventana Principal'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => ctx.read<AuthCubit>().logout(),
          )
        ],
      ),
      body: Center(
        child: Text('¡Bienvenido, ${user.nombre}!'),
      ),
    );
  }
}
