import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        borderRadius: BorderRadius.circular(10), // Radius 10px
        border: Border.all(color: TbpPalette.darkViolet, width: 2), // Dark Violet Border
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
                color: TbpPalette.darkViolet, // Dark Violet Overlay
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

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: TbpPalette.lilac)),
      errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image)),
      memCacheWidth: 600, // Optimize memory usage (don't load full res)
    );
  }
}
