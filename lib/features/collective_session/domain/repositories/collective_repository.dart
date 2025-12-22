import '../entities/tbp_session.dart';

abstract class CollectiveRepository {
  Future<TbpSession> joinSession(String username);
  Future<void> submitFragment(String sessionId, String fragment);
}
