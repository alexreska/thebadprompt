import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/collective_session_bloc.dart';
import 'package:tbp_v2/l10n/app_localizations.dart'; // Added import

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
              child: Text(AppLocalizations.of(context)!.viewArchive),
            ),
          ],
        );
      },
    );
  }



// ...

  Widget _buildJoinState(BuildContext context, QueueStatus status) {
    final l10n = AppLocalizations.of(context)!;
    String title = l10n.joinTheCollective;
    if (status == QueueStatus.completed) title = l10n.greatContribution;
    if (status == QueueStatus.skipped) title = l10n.turnExpired;

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
          l10n.yourName, 
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
          maxLength: 15, // Added Sanitization
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
            hintText: l10n.enterYourAlias,
            hintStyle: TextStyle(color: TbpPalette.darkViolet.withValues(alpha: 0.5)),
            counterText: '', // Hide counter
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
          child: Text(l10n.joinQueue),
        ),
      ],
    );
  }

  Widget _buildWaitingState(BuildContext context, int? position) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.limitReached,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TbpPalette.darkViolet),
          ),
          const SizedBox(height: 8),
          Text(
            position != null ? l10n.youArePosition(position) : l10n.holdTight,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: TbpPalette.darkViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.prepareYourWord,
             style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TbpPalette.darkViolet.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveState(BuildContext context, Duration remaining) {
    final l10n = AppLocalizations.of(context)!;
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
                    ? l10n.turnOver 
                    : l10n.yourTurn(remaining.inSeconds),
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
          l10n.oneWordOnly, 
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
          maxLength: 20, // Added Sanitization (One word usually)
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
             counterText: '', // Hide counter
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
          child: Text(l10n.submit),
        ),
      ],
    );
  }
}
