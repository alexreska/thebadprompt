import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/fragment.dart';
import '../../domain/entities/tbp_session.dart';
import 'generation_remote_data_source.dart';

abstract class CollectiveRemoteDataSource {
  Future<TbpSession> joinSession(String username);
  Future<void> submitFragment({required String sessionId, required String content, required String? authorName});
  Future<String> joinQueue({required String sessionId, required String name, required String deviceId});
  Future<Map<String, dynamic>> getQueueStatus({required String sessionId, required String queueId});
  Future<void> submitFragmentWithQueue({required String sessionId, required String content, required String authorName, required String deviceId});
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
             .select('content, created_at')
             .eq('session_id', session['id'])
             .order('created_at', ascending: true);
             
         final fragmentsList = (fragmentsResponse as List<dynamic>).map((e) => {
           'content': e['content'],
           'created_at': DateTime.parse(e['created_at'])
         }).toList();
         
         // Force Sort Ascending
         fragmentsList.sort((a, b) => (a['created_at'] as DateTime).compareTo(b['created_at'] as DateTime));
         
         final fullPrompt = fragmentsList.map((f) => f['content'] as String).join(' ');
         
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
  Future<void> submitFragment({required String sessionId, required String content, required String? authorName}) async {
    await supabaseClient
        .from('fragments') // Checked: Table is 'fragments'
        .insert({
          'session_id': sessionId,
          'content': content,
          'author_name': authorName ?? 'Anon',
          'created_at': DateTime.now().toIso8601String(),
        });
  }

  @override
  Future<String> joinQueue({required String sessionId, required String name, required String deviceId}) async {
    final response = await supabaseClient.rpc('join_queue', params: {
      'p_session_id': int.parse(sessionId), // BIGINT expects int matching
      'p_name': name,
      'p_device_id': deviceId,
    });
    return response as String;
  }

  @override
  Future<Map<String, dynamic>> getQueueStatus({required String sessionId, required String queueId}) async {
    // 1. Get Session Info (current turn)
    final sessionData = await supabaseClient
        .from('sessions')
        .select('current_queue_id, turn_expires_at')
        .eq('id', sessionId)
        .single();
    
    final currentQueueId = sessionData['current_queue_id'] as String?;
    final turnExpiresAt = sessionData['turn_expires_at'] != null 
        ? DateTime.parse(sessionData['turn_expires_at'] as String) 
        : null;

    if (currentQueueId == queueId) {
      return {
        'status': 'active',
        'position': 0,
        'turnExpiresAt': turnExpiresAt,
      };
    }

    // 2. Get My Queue Info
    final myQueueData = await supabaseClient
        .from('session_queue')
        .select('created_at, status')
        .eq('id', queueId)
        .maybeSingle(); // Use maybeSingle to handle if deleted/completed

    if (myQueueData == null) {
       return {'status': 'none'};
    }
    
    final myStatus = myQueueData['status'] as String;
    if (myStatus == 'completed') return {'status': 'completed'};
    if (myStatus == 'active') {
       // Should have matched above, but maybe delay.
       return {
        'status': 'active',
        'position': 0,
        'turnExpiresAt': turnExpiresAt,
      };
    }
    
    // 3. Calculate Position (waiting ahead of me)
    final myCreatedAt = DateTime.parse(myQueueData['created_at'] as String);
    
    final countResponse = await supabaseClient
        .from('session_queue')
        .select('id') // just count
        .eq('session_id', sessionId)
        .eq('status', 'waiting')
        .lt('created_at', myCreatedAt.toIso8601String())
        .count(CountOption.exact); // Request count

    final position = countResponse.count + 1; // logical position 1st, 2nd...

    return {
      'status': 'waiting',
      'position': position,
      'turnExpiresAt': turnExpiresAt, // Needed? Maybe to show "Current turn ends in..."
    };
  }

  @override
  Future<void> submitFragmentWithQueue({required String sessionId, required String content, required String authorName, required String deviceId}) async {
    await supabaseClient.rpc('submit_fragment_with_queue', params: {
      'p_session_id': int.parse(sessionId),
      'p_content': content,
      'p_author_name': authorName,
      'p_device_id': deviceId,
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
            authorName: map['author_name'] ?? 'Anon',
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
