import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/palette.dart';
import '../bloc/collective_session_bloc.dart';

class SessionTimer extends StatelessWidget {
  const SessionTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectiveSessionBloc, CollectiveSessionState>(
      builder: (context, state) {
        if (state is CollectiveSessionActive) {
          final minutes = state.remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
          final seconds = state.remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
             children: [
               const Icon(Icons.timer_outlined, color: TbpPalette.darkViolet, size: 24),
               const SizedBox(width: 8),
               Text(
                 '$minutes:$seconds',
                 style: const TextStyle(
                   color: TbpPalette.darkViolet,
                   fontSize: 24,
                   fontWeight: FontWeight.bold,
                   fontFamily: 'Courier', 
                 ),
               ),
               const SizedBox(width: 32),
               
               // DEBUG: Fast Forward Button
               IconButton(
                 onPressed: () {
                    context.read<CollectiveSessionBloc>().add(DebugFastForwardRequested());
                 }, 
                 icon: const Icon(Icons.fast_forward, color: TbpPalette.darkViolet, size: 24),
                 tooltip: 'Debug: Jump to 00:10',
               ),
            ],
          );
        }
        return const SizedBox(height: 24); 
      },
    );
  }
}
