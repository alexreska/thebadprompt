import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/fragment.dart';
import '../../domain/entities/tbp_session.dart';
import 'generation_remote_data_source.dart';

abstract class CollectiveRemoteDataSource {
  Future<TbpSession> joinSession(String username);
  Future<void> submitFragment(String sessionId, String fragment);
  Stream<List<Fragment>> streamFragments(String sessionId);
  Future<void> fastForwardSession(String sessionId);
}



class CollectiveRemoteDataSourceImpl implements CollectiveRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GenerationRemoteDataSource generationDataSource;

  CollectiveRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.generationDataSource,
  });

  @override
  Future<TbpSession> joinSession(String username) async {
    // 1. Anon Auth
    await supabaseClient.auth.signInAnonymously();

    // 2. Find active sessions
    final response = await supabaseClient
        .from('sessions')
        .select()
        .eq('status', 'active');
        
    final List<dynamic> data = response as List<dynamic>;
    
    // Check for any valid active session
    for (var session in data) {
       final startTime = DateTime.parse(session['start_time']).toLocal(); // Convert to local for consistent comparison
       final now = DateTime.now();
       final diff = now.difference(startTime);
       


       if (diff.inMinutes >= 7) {
         // Expire this old session
         
         // 1. Fetch fragments to construct prompt
         final fragmentsResponse = await supabaseClient
             .from('fragments')
             .select('content')
             .eq('session_id', session['id'])
             .order('created_at');
             
         final fragmentsData = fragmentsResponse as List<dynamic>;
         final fullPrompt = fragmentsData.map((f) => f['content'] as String).join(' ');
         
         String? imageUrl;
         if (fullPrompt.trim().isNotEmpty) {
             try {
                imageUrl = await generationDataSource.generateImage(fullPrompt);
             } catch (e) {
                // ignore: avoid_print
                print('Error generating image: $e');
             }
         }

         // 2. Update session
         await supabaseClient
            .from('sessions')
            .update({
              'status': 'finished',
              'image_url': imageUrl,
            })
            .eq('id', session['id']);
       } else {

         // Found a valid active session
         return TbpSession(
           id: session['id'].toString(),
           startTime: startTime,
           imageUrl: session['image_url'], // Likely null for active
         );
       }
    }

    // No valid active session found, create new one
    final nowUtc = DateTime.now().toUtc().toIso8601String();
    final newSession = await supabaseClient
        .from('sessions')
        .insert({'status': 'active', 'start_time': nowUtc})
        .select()
        .single();
    
    return TbpSession(
      id: newSession['id'].toString(),
      startTime: DateTime.parse(newSession['start_time']).toLocal(),
    );
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
        .order('created_at', ascending: true)
        .map((maps) {
          final fragments = maps.map((map) => Fragment(
            id: map['id'].toString(),
            content: map['content'] ?? '',
            authorName: 'Anon',
            createdAt: DateTime.parse(map['created_at']),
          )).toList();
          
          // Force sort by creation time ascending
          fragments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return fragments;
        });
  }

  @override
  Future<void> fastForwardSession(String sessionId) async {
    // Set start time to (Now - 6m 50s) so only 10s remain
    final closeToExpiry = DateTime.now().toUtc().subtract(const Duration(minutes: 6, seconds: 50));
    
    await supabaseClient
        .from('sessions')
        .update({'start_time': closeToExpiry.toIso8601String()})
        .eq('id', sessionId);
  }
}
