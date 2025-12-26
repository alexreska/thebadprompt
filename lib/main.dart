import 'dart:async'; // Added
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added
import 'core/app_constants.dart';
import 'design_system/tbp_theme.dart';
import 'features/navigation/presentation/widgets/main_layout.dart';
import 'injected_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/gallery/presentation/cubit/gallery_cubit.dart';
import 'features/collective_session/presentation/bloc/collective_session_bloc.dart'; // Added import
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tbp_v2/l10n/app_localizations.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await dotenv.load(fileName: '.env'); // Load Environment Variables
      
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
      
      await di.init();
      
      runApp(const TbpApp());
    } catch (e, stack) {
      // ignore: avoid_print
      print('CRITICAL STARTUP ERROR: $e');
      // ignore: avoid_print
      print(stack);
      // Optional: Run a simple error app?
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Startup Error: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ));
    }
  }, (error, stackTrace) {
    // ignore: avoid_print
    print('Caught by Global Boundary: $error'); 
  });
}

class TbpApp extends StatelessWidget {
  const TbpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<GalleryCubit>()..loadSessions()),
        BlocProvider(create: (_) => di.sl<CollectiveSessionBloc>()..add(LoadRoomsRequested())), // Added here
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: TbpTheme.lightTheme,
        home: const MainLayout(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
        ],
      ),
    );
  }
}

