import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/fragment.dart';
import '../../domain/entities/tbp_session.dart';
import 'generation_remote_data_source.dart';

import 'package:logger/logger.dart'; // Added

abstract class CollectiveRemoteDataSource {
  Future<TbpSession> createRoom(String roomName);
  Future<List<TbpSession>> listRooms();
  Future<TbpSession> joinRoom(String roomCode);
  Future<TbpSession> joinSession(String username);
  Future<void> submitFragment({required String sessionId, required String content, required String? authorName});
  Future<String> joinQueue({required String sessionId, required String name, required String deviceId});
  Future<Map<String, dynamic>> getQueueStatus({required String sessionId, required String queueId});
  Future<void> submitFragmentWithQueue({required String sessionId, required String content, required String authorName, required String deviceId});
  Stream<List<Fragment>> streamFragments(String sessionId);
  Stream<TbpSession> streamSession(String sessionId);
  Future<void> fastForwardSession(String sessionId);
  Future<String?> expireSession(String sessionId); // Change return type
}





class CollectiveRemoteDataSourceImpl implements CollectiveRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GenerationRemoteDataSource generationDataSource;
  final logger = Logger(); // Added

  CollectiveRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.generationDataSource,
  });

  @override
  Future<TbpSession> createRoom(String roomName) async {
    // 1. Anon Auth
    await supabaseClient.auth.signInAnonymously();

    // 2. Call RPC
    final response = await supabaseClient.rpc('create_tbp_room', params: {'p_room_name': roomName});
    final data = response as Map<String, dynamic>;

    return TbpSession(
      id: data['id'].toString(),
      startTime: DateTime.parse(data['start_time']).toLocal(),
      roomCode: data['room_code'],
      roomName: data['room_name'],
    );
  }

  @override
  Future<List<TbpSession>> listRooms() async {
     await supabaseClient.auth.signInAnonymously();
     
     final response = await supabaseClient.rpc('list_active_rooms');
     final list = response as List<dynamic>;

     return list.map((data) => TbpSession(
       id: data['id'].toString(),
       startTime: DateTime.parse(data['start_time']).toLocal(),
       roomCode: data['room_code'],
       roomName: data['room_name'],
     )).toList();
  }

  @override
  Future<TbpSession> joinRoom(String roomCode) async {
     // 1. Anon Auth
    await supabaseClient.auth.signInAnonymously();

    // 2. Call RPC
    final response = await supabaseClient.rpc('join_tbp_room', params: {'p_room_code': roomCode});
    final data = response as Map<String, dynamic>;

    if (data.containsKey('error')) {
      throw Exception(data['error']);
    }

    return TbpSession(
      id: data['id'].toString(),
      startTime: DateTime.parse(data['start_time']).toLocal(),
      roomCode: data['room_code'],
    );
  }

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
         await expireSession(session['id'].toString());
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
    // ... existing creation logic ...
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
    final response = await supabaseClient.rpc('get_queue_status', params: {
      'p_session_id': int.parse(sessionId),
      'p_queue_id': queueId,
    });
    
    final data = response as Map<String, dynamic>;
    
    final turnExpiresAt = data['turnExpiresAt'] != null 
        ? DateTime.parse(data['turnExpiresAt'] as String) 
        : null;

    return {
      'status': data['status'],
      'position': data['position'],
      'turnExpiresAt': turnExpiresAt,
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
  Stream<TbpSession> streamSession(String sessionId) {
    return supabaseClient
        .from('sessions')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId)
        .map((maps) {
          if (maps.isEmpty) {
             throw Exception('Session not found');
          }
          final map = maps.first;
          return TbpSession(
            id: map['id'].toString(),
            startTime: DateTime.parse(map['start_time']).toLocal(),
            imageUrl: map['image_url'],
            roomCode: map['room_code'],
            roomName: map['room_name'],
          );
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

  @override
   Future<String?> expireSession(String sessionId) async {
     // 1. Fetch fragments to construct prompt
     final fragmentsResponse = await supabaseClient
         .from('fragments')
         .select('content, created_at')
         .eq('session_id', sessionId)
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
            final generatedImage = await generationDataSource.generateImage(fullPrompt);
            
            // 2b. Check if Base64 (starts with data:image)
            if (generatedImage.startsWith('data:image')) {
                try {
                  final base64String = generatedImage.split(',').last;
                  final imageBytes = base64Decode(base64String);
                  final fileName = 'session_$sessionId.png';
                  
                  // Upload to 'session_images' bucket
                  await supabaseClient.storage
                      .from('session_images')
                      .uploadBinary(fileName, imageBytes, fileOptions: const FileOptions(upsert: true));
                  
                  // Get Public URL
                  imageUrl = supabaseClient.storage
                      .from('session_images')
                      .getPublicUrl(fileName);
                      
                } catch (e) {
                  // ignore: avoid_print
                  logger.e('MRO: Failed to upload to storage: $e');
                  // Fallback to storing Base64 directly if upload fails (e.g. bucket missing)
                  imageUrl = generatedImage;
                }
            } else {
               // Already a URL (e.g. from fallback or other provider)
               imageUrl = generatedImage;
            }
         } catch (e) {
            // ignore: avoid_print
            logger.e('Error generating image: $e');
         }
     }

     // 2. Update session
     await supabaseClient
        .from('sessions')
        .update({
          'status': 'finished',
          'image_url': imageUrl,
        })
        .eq('id', sessionId);
     
     return imageUrl; // Return the URL
  }
}
