import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../design_system/palette.dart';

class GalleryDetailPage extends StatelessWidget {
  final String sessionId;
  final String? imageUrl;

  const GalleryDetailPage({
    super.key,
    required this.sessionId,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TbpPalette.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Close Button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: TbpPalette.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Full Image
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: TbpPalette.white, width: 2),
                        ),
                        child: _buildImage(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info Section
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: Supabase.instance.client
                        .from('fragments')
                        .select('content, created_at, author_name')
                        .eq('session_id', sessionId)
                        .order('created_at', ascending: true)
                        .withConverter<List<Map<String, dynamic>>>((data) => List<Map<String, dynamic>>.from(data)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                         return const Center(child: CircularProgressIndicator(color: TbpPalette.white));
                      }
                      
                      final fragments = snapshot.data ?? [];
                      // Reconstruct prompt
                      final prompt = fragments.map((f) => f['content']).join(' ');
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prompt
                          Text(
                            'PROMPT:',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prompt.isNotEmpty ? prompt : 'No prompt data',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: TbpPalette.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Artists
                          Text(
                            'ARTISTS:',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fragments.isEmpty ? 'Unknown' : fragments.map((f) => f['author_name'] as String? ?? 'Anon').join(', '),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TbpPalette.white),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Download Button
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download not implemented in Beta (Requires Storage permission)')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('DOWNLOAD IMAGE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TbpPalette.white,
                      foregroundColor: TbpPalette.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(Icons.broken_image, color: Colors.grey, size: 50);
    }

    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64String = imageUrl!.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
        );
      } catch (e) {
        return const Icon(Icons.error, color: Colors.red);
      }
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.contain,
    );
  }
}
