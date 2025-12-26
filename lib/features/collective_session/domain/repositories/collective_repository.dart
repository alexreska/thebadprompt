import '../entities/tbp_session.dart';
import '../entities/fragment.dart';

abstract class CollectiveRepository {
  Future<TbpSession> createRoom(String roomName);
  Future<List<TbpSession>> listRooms();
  Future<TbpSession> joinRoom(String roomCode);
  Future<TbpSession> joinSession(String username);
  Future<void> submitFragment(String sessionId, String fragment, String authorName);
  Future<String> joinQueue({required String sessionId, required String name, required String deviceId});
  Future<Map<String, dynamic>> getQueueStatus({required String sessionId, required String queueId});
  Future<void> submitFragmentWithQueue({required String sessionId, required String content, required String authorName, required String deviceId});
  Stream<List<Fragment>> streamFragments(String sessionId);
  Stream<TbpSession> streamSession(String sessionId);
  Future<void> fastForwardSession(String sessionId);
  Future<String?> expireSession(String sessionId);
}
