import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../design_system/palette.dart';
import '../widgets/gallery_card.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: TbpPalette.lightBackground, // Light Violet
      appBar: AppBar(
        title: Text(
          'ARCHIVE',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: TbpPalette.darkViolet,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0), // Less top pad
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: supabase
              .from('sessions')
              .select()
              .eq('status', 'finished')
              .order('start_time', ascending: false) // Newest first
              .limit(50)
              .withConverter<List<Map<String, dynamic>>>((data) => List<Map<String, dynamic>>.from(data)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: TbpPalette.darkViolet));
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: TbpPalette.error)));
            }

            final sessions = snapshot.data ?? [];
            if (sessions.isEmpty) {
              return const Center(child: Text('No archives yet.', style: TextStyle(color: TbpPalette.darkViolet)));
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.0,
              ),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return GalleryCard(
                  imageUrl: session['image_url'],
                  sessionId: session['id'].toString(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
