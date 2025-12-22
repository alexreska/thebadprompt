import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';

class GalleryCard extends StatelessWidget {
  final int index;

  const GalleryCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Placeholder logic

    return Container(
      decoration: BoxDecoration(
        color: TbpPalette.white,
        border: Border.all(color: TbpPalette.black, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image Placeholder (Abstract Art)
          Image.network(
            'https://picsum.photos/seed/${index + 100}/500',
            fit: BoxFit.cover,
          ),
          
          // Overlay (Brutalist ID)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: TbpPalette.black,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                'EXP_#00${index + 1}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TbpPalette.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
