import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../../../design_system/palette.dart';
import '../../../collective_session/presentation/widgets/lobby_page.dart'; // Add import
import '../../../collective_session/presentation/widgets/collective_stream_box.dart';
import '../../../collective_session/presentation/widgets/contribution_form.dart';
import '../../../collective_session/presentation/widgets/session_timer.dart';
import '../../../collective_session/presentation/widgets/instructions_section.dart';
import '../../../collective_session/presentation/bloc/collective_session_bloc.dart';
import '../../../gallery/presentation/cubit/gallery_cubit.dart'; 

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectiveSessionBloc, CollectiveSessionState>(
      listener: (context, state) {
          if (state is CollectiveSessionActive && state.session.imageUrl != null) {
              
              // New: Instant Gallery Update
              // We construct the map as Supabase would return it
              final newSessionMap = {
                 'id': state.session.id,
                 'start_time': state.session.startTime.toIso8601String(),
                 'image_url': state.session.imageUrl,
                 'status': 'finished'
              };
              context.read<GalleryCubit>().prependSession(newSessionMap);

              // Trigger Reveal
              showDialog(
                context: context, 
                barrierDismissible: false,
                builder: (dialogContext) => _RevealDialog(
                  imageUrl: state.session.imageUrl!,
                  onClose: () {
                    context.read<CollectiveSessionBloc>().add(LeaveSession());
                  },
                ),
              );
           }
        },
        child: BlocBuilder<CollectiveSessionBloc, CollectiveSessionState>(
          builder: (context, state) {
            if (state is CollectiveSessionActive) {
               return const LandingPageView();
            }
            if (state is CollectiveSessionLoading) {
               return const Scaffold(
                 body: Center(child: CircularProgressIndicator(color: TbpPalette.darkViolet)),
               );
            }
            if (state is CollectiveSessionError) {
               return Scaffold(
                 body: Center(child: Text('Error: ${state.message}')),
               );
            }
            if (state is CollectiveSessionLobby) {
              return const Scaffold(
                body: LobbyPage(),
              );
            }
            // Initial/Fallback
            return const Scaffold(
              body: LobbyPage(), 
            );
          },
        ),
    );
  }
}

class _RevealDialog extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onClose; // Add Callback
  
  const _RevealDialog({
    required this.imageUrl,
    this.onClose,
  });

  Widget _buildImage() {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last;
        return Image.memory(
          const Base64Decoder().convert(base64String),
          fit: BoxFit.contain,
          errorBuilder: (c, o, s) => const Center(child: Icon(Icons.error, color: Colors.white, size: 50)),
        );
      } catch (e) {
        return const Center(child: Icon(Icons.error, color: Colors.white, size: 50));
      }
    }
    
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (c, o, s) => const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
      loadingBuilder: (c, child, p) {
         if (p == null) return child;
         return const Center(child: CircularProgressIndicator(color: TbpPalette.lilac));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
           // Image
           _buildImage(),
           
           // Close / Gallery Button
           Positioned(
             bottom: 50,
             left: 0,
             right: 0,
             child: Center(
               child: ElevatedButton(
                  onPressed: () {
                    // Close dialog first
                    Navigator.of(context).pop();
                    // trigger callback
                    onClose?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TbpPalette.lilac,
                    foregroundColor: TbpPalette.darkViolet,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('CLOSE & CONTINUE'),
               ),
             ),
           ),
        ],
      ),
    );
  }
}

class LandingPageView extends StatelessWidget {
  const LandingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: TbpPalette.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600), // Max width for clean look
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       // 1. LOGO (Bigger as requested)
                       Image.asset(
                         'assets/TBP_logo.png',
                         height: 180, // Increased from 120
                         errorBuilder: (c, o, s) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                       ),
                       const SizedBox(height: 32),

                       // 2. TEXT DESCRIPTION
                       Text(
                         'An experience of collective and democratic art, generated by AI and human touch. Participate!\n\nThe Experience last 7 minutes, once the countdown is complete, You will find the artwork in the Gallery.\n\nThis is a BETA',
                         textAlign: TextAlign.center,
                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                           color: TbpPalette.darkViolet, // Changed to Dark Violet
                           fontSize: 16,
                           height: 1.5,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                       const SizedBox(height: 40),

                       // 3. COUNTDOWN & FAST FORWARD
                       const Center(child: SessionTimer()),
                       const SizedBox(height: 40),

                       // 4. STREAM BOX
                       const SizedBox(
                         height: 300, // Fixed height for stream
                         child: CollectiveStreamBox(),
                       ),
                       const SizedBox(height: 40),

                       // 5/6/7. INPUTS & SUBMIT (ContributionForm)
                       const ContributionForm(),
                       
                       const SizedBox(height: 64),

                       // 8. INSTRUCTIONS
                       // Instructions might need dark text update too, need to check that widget.
                       const InstructionsSection(),
                       
                       const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
