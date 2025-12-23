import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../design_system/palette.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: TbpPalette.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const  Icon(Icons.person, size: 80, color: TbpPalette.darkViolet),
            const SizedBox(height: 24),
            Text(
              'User ID:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: TbpPalette.darkViolet,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.id ?? 'Not Logged In',
               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TbpPalette.darkViolet,
                fontFamily: 'Courier',
              ),
            ),
             const SizedBox(height: 48),
             ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                // Optionally navigate to separate login, but we use anon auth mostly.
                // For now, just show snackbar.
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged Out')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TbpPalette.fuchsia,
                foregroundColor: TbpPalette.white,
              ),
              child: const Text('Log Out'),
             ),
          ],
        ),
      ),
    );
  }
}
