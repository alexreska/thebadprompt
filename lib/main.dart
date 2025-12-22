import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_constants.dart';
import 'design_system/palette.dart';
import 'design_system/tbp_theme.dart';
import 'features/collective_session/presentation/widgets/collective_stream_box.dart';
import 'features/collective_session/presentation/widgets/contribution_form.dart';
import 'features/collective_session/presentation/bloc/collective_session_bloc.dart';
import 'injected_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  await di.init();

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
    return BlocProvider(
      create: (_) => di.sl<CollectiveSessionBloc>(),
      child: const LandingPageView(),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 40.0), // Generous padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top
              children: [
                // LEFT SIDE: Collective Prompt Box
                const Expanded(
                  flex: 5, // Takes 50% or so
                  child: CollectiveStreamBox(),
                ),
                
                const SizedBox(width: 48), // Spacer between columns

                // RIGHT SIDE: Inputs
                const Expanded(
                  flex: 4, // Takes 40%
                  child: Center(
                    child: ContributionForm(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

