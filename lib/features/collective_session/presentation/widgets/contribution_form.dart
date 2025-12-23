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

  void _onSubmit() {
    final prompt = _promptController.text;
    final name = _nameController.text;
    if (prompt.isEmpty || name.isEmpty) return;

    final bloc = context.read<CollectiveSessionBloc>();
    final state = bloc.state;

    if (state is CollectiveSessionInitial || state is CollectiveSessionError) {
      // First time interaction: Join then Submit?
      // For simplicity, we trigger Join. The user might need to click twice or we handle standard queuing.
      // Better: trigger Join. Logic inside Bloc could handle "JoinAndSubmit"?
      // For now: Just Join. User will see "Joined" state presumably.
      bloc.add(JoinSessionRequested(name));
      // Ideally we wait for join to complete before submitting.
      // We can listen to state changes here or just let the user click again.
      // Let's assume for this MVP, we join first.
    } 
    
    // If active, submit
    if (state is CollectiveSessionActive) {
      bloc.add(FragmentSubmitted(prompt, name));
      _promptController.clear(); // Clear prompt after send
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch for inputs
      mainAxisSize: MainAxisSize.min,
      children: [
          // Prompt Input
          Text(
            'Prompt', 
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: TbpPalette.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _promptController,
            autocorrect: false,
            enableSuggestions: false,
            maxLines: 3, // Suggested for prompt
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1), // Slight background, using withValues
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: TbpPalette.white, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(15),
                 borderSide: const BorderSide(color: TbpPalette.white, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(color: TbpPalette.white),
          ),
          
          const SizedBox(height: 24),
          
          // Name Input
          Text(
            'Your Name', 
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: TbpPalette.white,
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
              fillColor: Colors.white.withValues(alpha: 0.1), // Using withValues
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: TbpPalette.white, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(15),
                 borderSide: const BorderSide(color: TbpPalette.white, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(color: TbpPalette.white),
          ),
  
          const SizedBox(height: 32),
  
          // Submit Button
          ElevatedButton(
            onPressed: _onSubmit,
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: TbpPalette.error, width: 1.5),
              backgroundColor: const Color(0xFFD6A2B7),
              foregroundColor: TbpPalette.black,
               shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), 
              ),
              fixedSize: const Size.fromHeight(50), // Taller button
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text('Submit'),
            ),
          ),
  
          const SizedBox(height: 32),
                  
          // Archive Link
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GalleryPage()),
                );
              },
              child: Text(
                'VIEW ARCHIVE',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                  color: TbpPalette.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
