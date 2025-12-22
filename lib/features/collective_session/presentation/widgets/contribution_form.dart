import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';

class ContributionForm extends StatelessWidget {
  const ContributionForm({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: TbpPalette.white,
          fontWeight: FontWeight.bold,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prompt Input
        Text('Prompt', style: textStyle),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            // Overriding theme to match the "Box" look if needed
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: TbpPalette.white, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(12),
               borderSide: const BorderSide(color: TbpPalette.white, width: 2),
            ),
          ),
          style: const TextStyle(color: TbpPalette.white),
        ),
        
        const SizedBox(height: 24),
        
        // Name Input
        Text('Your Name', style: textStyle),
         const SizedBox(height: 8),
        TextFormField(
           decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: TbpPalette.white, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(12),
               borderSide: const BorderSide(color: TbpPalette.white, width: 2),
            ),
          ),
          style: const TextStyle(color: TbpPalette.white),
        ),

        const SizedBox(height: 32),

        // Submit Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            side: const BorderSide(color: TbpPalette.error, width: 1.5), // Using "Error" red for Submit as seen in some brutalist designs? Or maybe pink? User image had a button.
            // Wait, standard theme is black button. User image might show something else. 
            // I'll stick to a visible border button with pinkish fill if requested?
            // User requested "Identical". The text didn't specify color.
            // I'll make it TbpPalette.lilac mixed or just transparent with border.
            // Let's go with a transparent button with a specific border color.
            backgroundColor: const Color(0xFFD6A2B7), // Adding a pinkish placeholder to match typical 'lilac' themes
            foregroundColor: TbpPalette.black, // Dark text
             shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // matching inputs
            ),
          ),
          onPressed: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text('Submit'),
          ),
        ),
      ],
    );
  }
}
