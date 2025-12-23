import '../entities/tbp_session.dart';
import '../entities/fragment.dart';

abstract class CollectiveRepository {
  Future<TbpSession> joinSession(String username);
  Future<void> submitFragment(String sessionId, String fragment, String authorName);
  Stream<List<Fragment>> streamFragments(String sessionId);
  Future<void> fastForwardSession(String sessionId);
}
