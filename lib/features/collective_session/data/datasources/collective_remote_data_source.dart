import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/tbp_session.dart';

abstract class CollectiveRemoteDataSource {
  Future<TbpSession> joinSession(String username);
  Future<void> submitFragment(String sessionId, String fragment);
}

class CollectiveRemoteDataSourceImpl implements CollectiveRemoteDataSource {
  final SupabaseClient supabaseClient;

  CollectiveRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<TbpSession> joinSession(String username) async {
    // Placeholder logic
    return const TbpSession(id: 'mock-session-id');
  }

  @override
  Future<void> submitFragment(String sessionId, String fragment) async {
    // Placeholder logic
  }
}
