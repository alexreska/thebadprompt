import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'design_system/palette.dart';
import 'design_system/tbp_theme.dart';

void main() {
  runApp(const TbpApp());
}

class TbpApp extends StatelessWidget {
  const TbpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Bad Prompt',
      theme: TbpTheme.lightTheme,
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Gradient Background Wrapper
      body: Container(
        decoration: const BoxDecoration(
          gradient: TbpPalette.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'THE BAD PROMPT',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'v2.0 Beta',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('ENTER THE VOID'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
