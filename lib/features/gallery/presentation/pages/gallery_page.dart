import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Add
import '../cubit/gallery_cubit.dart'; // Add

import '../../../../design_system/palette.dart';
import '../widgets/gallery_card.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: RefreshIndicator(
          color: TbpPalette.darkViolet,
          onRefresh: () => context.read<GalleryCubit>().loadSessions(),
          child: BlocBuilder<GalleryCubit, GalleryState>(
            builder: (context, state) {
              if (state is GalleryLoading) {
                return const Center(child: CircularProgressIndicator(color: TbpPalette.darkViolet));
              }
              
              if (state is GalleryError) {
                 return Stack(
                   children: [
                     ListView(), // Ensure scroll for RefreshIndicator
                     Center(child: Text('Error: ${state.message}', style: const TextStyle(color: TbpPalette.error))),
                   ],
                 );
              }
              
              if (state is GalleryLoaded) {
                 final sessions = state.sessions;
                 if (sessions.isEmpty) {
                    return Stack(
                      children: [
                        ListView(), 
                        const Center(child: Text('No archives yet.', style: TextStyle(color: TbpPalette.darkViolet))),
                      ],
                    );
                 }

                 return GridView.builder(
                   physics: const AlwaysScrollableScrollPhysics(),
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
              }
              
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
