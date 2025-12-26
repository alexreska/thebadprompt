import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Add
import '../cubit/gallery_cubit.dart'; // Add
import 'package:tbp_v2/l10n/app_localizations.dart'; // Add

import '../../../../design_system/palette.dart';
import '../widgets/gallery_card.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override


//...

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: TbpPalette.lightBackground, // Light Violet
      appBar: AppBar(
        title: Text(
          l10n.archiveTitle,
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
                     Center(child: Text(l10n.error(state.message), style: const TextStyle(color: TbpPalette.error))),
                   ],
                 );
              }
              
              if (state is GalleryLoaded) {
                 final sessions = state.sessions;
                 if (sessions.isEmpty) {
                    return Stack(
                      children: [
                        ListView(), 
                        Center(child: Text(l10n.noArchivesYet, style: const TextStyle(color: TbpPalette.darkViolet))),
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
