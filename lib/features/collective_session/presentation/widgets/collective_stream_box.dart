import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';

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
        color: Colors.white.withOpacity(0.15), // Glassy/translucent
        border: Border.all(color: TbpPalette.white, width: 1.5),
        borderRadius: BorderRadius.circular(16), // Slight rounding as per 'modern' conventions seen in typical designs, adjusting slightly away from pure brutalist if needed, but let's stick to theme if possible. 
        // User said "Identical". If the image had rounded corners, I should add them. 
        // I will add a modest radius (12-16) as it's common in "boxes".
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'alex my part of prompt', // Hardcoded placeholder from user description
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: TbpPalette.white,
                  height: 1.4,
                ),
          ),
          // We can add a blinking cursor later
        ],
      ),
    );
  }
}
