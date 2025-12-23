import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/palette.dart';
import '../../presentation/bloc/collective_session_bloc.dart';

class CollectiveStreamBox extends StatelessWidget {
  const CollectiveStreamBox({super.key});

  @override
  Widget build(BuildContext context) {
    // The "Left Box"
    return Container(
      width: double.infinity,
      height: 400, // Fixed height or flexible? User said "box".
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: TbpPalette.darkViolet.withValues(alpha: 0.05), // Light Violet BG matches inputs
        border: Border.all(color: TbpPalette.darkViolet, width: 1.5),
        borderRadius: BorderRadius.circular(16), 
      ),
      child: BlocBuilder<CollectiveSessionBloc, CollectiveSessionState>(
        builder: (context, state) {
          if (state is CollectiveSessionActive) {
            // Display fragments as a continuous stream text
            return SingleChildScrollView(
              reverse: true, // Auto-scroll to bottom like a terminal
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: state.fragments.map((fragment) {
                  return Text(
                    fragment.content,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: TbpPalette.darkViolet,
                          height: 1.4,
                        ),
                  );
                }).toList(),
              ),
            );
          } else if (state is CollectiveSessionLoading) {
            return const Center(child: CircularProgressIndicator(color: TbpPalette.darkViolet));
          } else if (state is CollectiveSessionError) {
             return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: TbpPalette.error)));
          }
          
          return Center(
            child: Text(
              'Waiting for authors...', 
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: TbpPalette.darkViolet.withValues(alpha: 0.5),
                ),
            ),
          );
        },
      ),
    );
  }
}
