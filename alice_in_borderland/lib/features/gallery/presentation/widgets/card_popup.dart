// lib/features/gallery/presentation/widgets/card_popup.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/card_constants.dart';

class CardPopup {
  static Future<void> show(BuildContext context, String code,
      {bool unlocked = false}) {
    final assetPath = cardAssetPath(code, unlocked: unlocked);
    return showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final screenHeight = MediaQuery.of(ctx).size.height;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('cardChallenges')
              .doc(code)
              .get(),
          builder: (ctx, snap) {
            Widget body;
            if (snap.connectionState != ConnectionState.done) {
              body = const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snap.hasError || !snap.hasData || !snap.data!.exists) {
              body = const SizedBox(
                height: 200,
                child: Center(child: Text('No se encontró el reto')),
              );
            } else {
              final data = snap.data!.data() as Map<String, dynamic>;
              final title = data['title'] as String? ?? code;
              final desc = data['description'] as String? ?? '';
              body = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    assetPath,
                    width: screenWidth * 1.2,
                    height: screenWidth * 1.2,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return AlertDialog(
              backgroundColor: Colors.black,
              insetPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.05,
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: screenWidth * 0.9,
                  child: body,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cerrar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
