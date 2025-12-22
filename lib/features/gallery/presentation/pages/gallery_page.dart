import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';
import '../widgets/gallery_card.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Brutalist header: Just big text.
    return Scaffold(
      backgroundColor: TbpPalette.lilac, // Or use the gradient? Sticking to Lilac for difference
      appBar: AppBar(
        title: Text(
          'ARCHIVE',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Desktop friendly. On mobile might need 1 or 2.
            // responsiveness handled later or we use LayoutBuilder
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.0, // Square images
          ),
          itemCount: 9, // Mock count
          itemBuilder: (context, index) {
            return GalleryCard(index: index);
          },
        ),
      ),
    );
  }
}
