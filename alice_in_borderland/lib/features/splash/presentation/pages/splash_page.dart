import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '顔認証をお待ちください', // “Reconocimiento facial espera un momento”
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
