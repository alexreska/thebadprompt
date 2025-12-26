import '../../domain/entities/fragment.dart';
import '../../domain/entities/tbp_session.dart';
import '../../domain/repositories/collective_repository.dart';
import '../datasources/collective_remote_data_source.dart';

class CollectiveRepositoryImpl implements CollectiveRepository {
  final CollectiveRemoteDataSource remoteDataSource;

  CollectiveRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TbpSession> createRoom(String roomName) {
    return remoteDataSource.createRoom(roomName);
  }

  @override
  Future<List<TbpSession>> listRooms() {
    return remoteDataSource.listRooms();
  }

  @override
  Future<TbpSession> joinRoom(String roomCode) {
    return remoteDataSource.joinRoom(roomCode);
  }

  @override
  Future<TbpSession> joinSession(String username) {
    return remoteDataSource.joinSession(username);
  }

  @override
  Future<void> submitFragment(String sessionId, String fragment, String authorName) {
    // Legacy direct submit (keep for now or refactor to use queue internally if needed, but we have a dedicated method)
    return remoteDataSource.submitFragment(sessionId: sessionId, content:  fragment, authorName: authorName);
  }

  @override
  Future<String> joinQueue({required String sessionId, required String name, required String deviceId}) {
    return remoteDataSource.joinQueue(sessionId: sessionId, name: name, deviceId: deviceId);
  }

  @override
  Future<Map<String, dynamic>> getQueueStatus({required String sessionId, required String queueId}) {
    return remoteDataSource.getQueueStatus(sessionId: sessionId, queueId: queueId);
  }

  @override
  Future<void> submitFragmentWithQueue({required String sessionId, required String content, required String authorName, required String deviceId}) {
    return remoteDataSource.submitFragmentWithQueue(sessionId: sessionId, content: content, authorName: authorName, deviceId: deviceId);
  }

  @override
  Stream<List<Fragment>> streamFragments(String sessionId) {
    return remoteDataSource.streamFragments(sessionId);
  }

  @override
  Stream<TbpSession> streamSession(String sessionId) {
    return remoteDataSource.streamSession(sessionId);
  }

  @override
  Future<String?> expireSession(String sessionId) {
    return remoteDataSource.expireSession(sessionId);
  }

  @override
  Future<void> fastForwardSession(String sessionId) async {
    return remoteDataSource.fastForwardSession(sessionId);
  }
}
