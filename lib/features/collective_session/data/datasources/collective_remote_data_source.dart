import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/fragment.dart';
import '../../domain/entities/tbp_session.dart';

abstract class CollectiveRemoteDataSource {
  Future<TbpSession> joinSession(String username);
  Future<void> submitFragment(String sessionId, String fragment);
  Stream<List<Fragment>> streamFragments(String sessionId);
}

class CollectiveRemoteDataSourceImpl implements CollectiveRemoteDataSource {
  final SupabaseClient supabaseClient;

  CollectiveRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<TbpSession> joinSession(String username) async {
    // 1. Anon Auth
    await supabaseClient.auth.signInAnonymously();

    // 2. Find active session (or create one if none exists - simplifed for now to just fetch 'active')
    // Assuming table 'sessions' has a row with status = 'active'
    final response = await supabaseClient
        .from('sessions')
        .select()
        .eq('status', 'active')
        .maybeSingle();

    if (response == null) {
      // If no active session, create one (Mock logic or Admin logic? For now, we assume one exists or we create it)
      final newSession = await supabaseClient
          .from('sessions')
          .insert({'status': 'active', 'start_time': DateTime.now().toIso8601String()})
          .select()
          .single();
      return TbpSession(id: newSession['id'].toString());
    }

    return TbpSession(id: response['id'].toString());
  }

  @override
  Future<void> submitFragment(String sessionId, String fragment) async {
    // Insert into 'fragments'
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await supabaseClient.from('fragments').insert({
      'session_id': sessionId,
      'content': fragment,
      'user_id': userId,
      // 'author_name': username // Typically stored in a 'profiles' table, but for speed we might send it here? 
      // User requested "Alex my part of prompt". The name is in the input.
    });
  }

  @override
  Stream<List<Fragment>> streamFragments(String sessionId) {
    return supabaseClient
        .from('fragments')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('created_at')
        .map((maps) => maps.map((map) => Fragment(
              id: map['id'].toString(),
              content: map['content'] ?? '',
              authorName: 'Anon', // TODO: Join with profiles or store name in fragment
              createdAt: DateTime.parse(map['created_at']),
            )).toList());
  }
}
