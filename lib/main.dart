import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_constants.dart';
import 'design_system/tbp_theme.dart';
import 'features/navigation/presentation/widgets/main_layout.dart';
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
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

