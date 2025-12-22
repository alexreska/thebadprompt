import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';
import '../pages/gallery_detail_page.dart';

class GalleryCard extends StatelessWidget {
  final String? imageUrl;
  final String sessionId;

  const GalleryCard({
    super.key, 
    required this.imageUrl,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GalleryDetailPage(
              sessionId: sessionId,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: TbpPalette.white,
        border: Border.all(color: TbpPalette.black, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          _buildImage(),
          
          // Overlay (ID)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: TbpPalette.black,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                'SESSION #$sessionId',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TbpPalette.white,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
    }

    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64String = imageUrl!.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (c, o, s) => const Center(child: Icon(Icons.error)),
        );
      } catch (e) {
        return const Center(child: Icon(Icons.error, color: Colors.red));
      }
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (c, o, s) => const Center(child: Icon(Icons.broken_image)),
    );
  }
}
