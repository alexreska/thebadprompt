import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';

class InstructionsSection extends StatelessWidget {
  const InstructionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Intro Text
        const Text(
          'Submit your prompt segment for the experience. You’re limited to one word per submission, with only one submission allowed per experience. Wait for the image creation, enjoy your experience.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: TbpPalette.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // 4 Steps Cards (Horizontal Scroll for small screens, Row for large)
        LayoutBuilder(
          builder: (context, constraints) {
            // Simple responsive check
            final isSmall = constraints.maxWidth < 600;
            
            final steps = [
              _StepCard(number: '1', text: 'Enter your part of the prompt. Light a spark with your idea.'),
              _StepCard(number: '2', text: 'Whoever comes after you will add their contribution.'),
              _StepCard(number: '3', text: 'Anyone can participate. Artists, creatives, designers or simply curious.'),
              _StepCard(number: '4', text: 'The AI will generate the image from the collective prompt showing the authors'),
            ];

            if (isSmall) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map((s) => Padding(padding: const EdgeInsets.only(right: 16), child: s)).toList(),
                ),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((s) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: s))).toList(),
              );
            }
          },
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String text;

  const _StepCard({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // Fixed width for nice pill shape look if scrolling, or max width if expanded
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30), // Pill-like shape
        border: Border.all(color: TbpPalette.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            '$number.',
            style: const TextStyle(
              color: TbpPalette.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TbpPalette.white,
              fontSize: 11, // Small text as likely shown in screenshot
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
