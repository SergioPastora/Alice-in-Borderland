// lib/features/visado/presentation/pages/visado_page.dart

// para FontFeature
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/visado_cubit.dart';

class VisadoPage extends StatelessWidget {
  const VisadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const timerStyle = TextStyle(
      fontFamily: 'monospace',
      color: Colors.black,
      letterSpacing: 2,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final titleSize = width * 0.06;
            final counterSize = width * 0.2;

            return Column(
              children: [
                SizedBox(height: height * 0.2),

                // 1) Etiqueta en japonés: "残りの寿命"
                Text(
                  '残りの寿命',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: height * 0.03),

                const Text(
                  '【VISADO】',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),

                // 2) Contador inverso
                Expanded(
                  child: Center(
                    child: BlocBuilder<VisadoCubit, VisadoState>(
                      builder: (context, state) {
                        if (state is VisadoInProgress) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              state.formatted,
                              style: timerStyle.copyWith(
                                fontSize: counterSize,
                                color: Colors.black,
                              ),
                            ),
                          );
                        } else if (state is VisadoFinished) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '00:00:00:00',
                              style: timerStyle.copyWith(
                                fontSize: counterSize,
                                color: Colors.redAccent,
                              ),
                            ),
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                ),

                SizedBox(height: height * 0.3),
              ],
            );
          },
        ),
      ),
    );
  }
}
