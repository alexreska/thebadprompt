import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/collective_session_bloc.dart';

class ContributionForm extends StatefulWidget {
  const ContributionForm({super.key});

  @override
  State<ContributionForm> createState() => _ContributionFormState();
}

class _ContributionFormState extends State<ContributionForm> {
  final _promptController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    _nameController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectiveSessionBloc, CollectiveSessionState>(
      builder: (context, state) {
        // If not active or error, just show empty or loading?
        // Actually prompt "Join Session" generic if initial?
        if (state is! CollectiveSessionActive) {
           return const Center(child: CircularProgressIndicator(color: TbpPalette.darkViolet));
        }

        final queueStatus = state.queueStatus;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // DYNAMIC CONTENT BASED ON QUEUE STATE
            if (queueStatus == QueueStatus.none || queueStatus == QueueStatus.completed || queueStatus == QueueStatus.skipped)
              _buildJoinState(context, queueStatus),
            
            if (queueStatus == QueueStatus.joining)
               const Padding(
                 padding: EdgeInsets.all(32.0),
                 child: Center(child: CircularProgressIndicator(color: TbpPalette.darkViolet)),
               ),

            if (queueStatus == QueueStatus.waiting)
              _buildWaitingState(context, state.queuePosition),

            if (queueStatus == QueueStatus.active)
              _buildActiveState(context, state.turnRemainingTime),

            const SizedBox(height: 32),

            // Archive Link (Always Visible)
            ElevatedButton(
              onPressed: () {
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GalleryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TbpPalette.lilac,
                foregroundColor: TbpPalette.darkViolet,
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), 
                ),
                fixedSize: const Size.fromHeight(50), 
                elevation: 4,
                shadowColor: TbpPalette.lilac.withValues(alpha: 0.4),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: const Text('VIEW ARCHIVE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJoinState(BuildContext context, QueueStatus status) {
    String title = 'Join the Collective';
    if (status == QueueStatus.completed) title = 'Great Contribution! Go again?';
    if (status == QueueStatus.skipped) title = 'Turn Expired. Try again?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: TbpPalette.darkViolet,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your Name', 
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: TbpPalette.darkViolet,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: TbpPalette.darkViolet.withValues(alpha: 0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: TbpPalette.darkViolet, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(15),
               borderSide: const BorderSide(color: TbpPalette.darkViolet, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintText: 'Enter your alias...',
            hintStyle: TextStyle(color: TbpPalette.darkViolet.withValues(alpha: 0.5)),
          ),
          style: const TextStyle(color: TbpPalette.darkViolet),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text;
            if (name.isNotEmpty) {
               context.read<CollectiveSessionBloc>().add(JoinQueueRequested(name));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TbpPalette.lilac, 
            foregroundColor: TbpPalette.darkViolet, 
             shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), 
            ),
            fixedSize: const Size.fromHeight(50), 
            elevation: 4,
            shadowColor: TbpPalette.lilac.withValues(alpha: 0.4),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          child: const Text('JOIN QUEUE'),
        ),
      ],
    );
  }

  Widget _buildWaitingState(BuildContext context, int? position) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TbpPalette.darkViolet.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TbpPalette.darkViolet, width: 1),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: TbpPalette.darkViolet),
          const SizedBox(height: 16),
          Text(
            'Limit reached or Line full?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TbpPalette.darkViolet),
          ),
          const SizedBox(height: 8),
          Text(
            position != null ? 'You are #$position in line' : 'Hold tight...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: TbpPalette.darkViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prepare your word...',
             style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TbpPalette.darkViolet.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveState(BuildContext context, Duration remaining) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Countdown
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
             color: TbpPalette.darkViolet,
             borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.timer, color: TbpPalette.lilac),
               const SizedBox(width: 8),
               Text(
                 remaining.isNegative 
                    ? 'TURN OVER!' 
                    : 'YOUR TURN! ${remaining.inSeconds}s left',
                 style: const TextStyle(
                   color: TbpPalette.lilac, 
                   fontWeight: FontWeight.bold,
                   fontSize: 18,
                 ),
               ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'One Word Only', 
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: TbpPalette.darkViolet,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _promptController,
          autocorrect: false,
          enableSuggestions: false,
          autofocus: true, // Focus immediately!
          decoration: InputDecoration(
            filled: true,
            fillColor: TbpPalette.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: TbpPalette.darkViolet, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(15),
               borderSide: const BorderSide(color: TbpPalette.darkViolet, width: 3),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(color: TbpPalette.darkViolet, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            final content = _promptController.text;
            if (content.isNotEmpty) {
               context.read<CollectiveSessionBloc>().add(SubmitQueueFragmentRequested(content));
               _promptController.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TbpPalette.lilac, 
            foregroundColor: TbpPalette.darkViolet, 
             shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), 
            ),
            fixedSize: const Size.fromHeight(50), 
            elevation: 4,
            shadowColor: TbpPalette.lilac.withValues(alpha: 0.4),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          child: const Text('SUBMIT'),
        ),
      ],
    );
  }
}
