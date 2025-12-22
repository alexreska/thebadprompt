// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tbp_v2/core/app_constants.dart';

void main() {
  test('Verify Supabase Connection and Data', () async {
    print('Connecting to Supabase...');
    // We use the raw SupabaseClient to avoid Flutter platform channel dependencies if possible,
    // but here we are in a flutter test environment so it should be fine either way.
    // However, Supabase.initialize() sets up a singleton and might try to access SharedPreferences (which needs mocking).
    // So we just instantiate SupabaseClient directly which is pure Dart (mostly).
    
    final client = SupabaseClient(AppConstants.supabaseUrl, AppConstants.supabaseAnonKey);

    try {
      print('Checking "sessions" table...');
      final sessions = await client.from('sessions').select().limit(5);
      print('Found ${sessions.length} sessions.');
      for (var session in sessions) {
        print(' - Session ID: ${session['id']}, Status: ${session['status']}, Started: ${session['start_time']}');
      }

      print('\nChecking "fragments" table...');
      final fragments = await client.from('fragments').select().limit(5);
      print('Found ${fragments.length} fragments.');
      for (var fragment in fragments) {
        print(' - Fragment ID: ${fragment['id']}, Content: "${fragment['content']}", Session ID: ${fragment['session_id']}');
      }

      print('\nSupabase verification complete.');
    } catch (e) {
      print('Error verifying Supabase: $e');
      // Fail the test so we know
      fail('Supabase verification failed: $e');
    }
  });
}
