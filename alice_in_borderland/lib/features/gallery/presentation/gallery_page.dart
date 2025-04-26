import 'package:flutter/material.dart';
import '../../../../core/card_constants.dart';

class GalleryPage extends StatelessWidget {
  /// Lista de códigos de carta que el usuario posee
  final List<String> personalCards;

  /// Lista de códigos de carta que el grupo posee
  final List<String> groupCards;

  const GalleryPage({
    super.key,
    required this.personalCards,
    required this.groupCards,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black, // fondo negro
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text('Galería de Cartas'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Personal'),
              Tab(text: 'Grupal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GalleryGrid(cardCodes: personalCards),
            _GalleryGrid(cardCodes: groupCards),
          ],
        ),
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  final List<String> cardCodes;
  const _GalleryGrid({required this.cardCodes});

  @override
  Widget build(BuildContext context) {
    final double spacing = MediaQuery.of(context).size.width / 100;
    final double childAspectRatio = MediaQuery.of(context).size.width / 700;

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      itemCount: cardCodeToName.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final code = cardCodeToName.keys.elementAt(index);
        final isOwned = cardCodes.contains(code);
        final asset = cardAssetPath(code, unlocked: isOwned);

        return Opacity(
          opacity: isOwned ? 1 : 0.3,
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final String code;
  final bool isOwned;
  const _GalleryItem({
    required this.code,
    required this.isOwned,
  });

  @override
  Widget build(BuildContext context) {
    final asset = cardAssetPath(code, unlocked: isOwned);

    return Opacity(
      opacity: isOwned ? 1.0 : 0.3,
      child: Image.asset(asset),
    );
  }
}
