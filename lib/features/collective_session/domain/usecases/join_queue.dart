import '../repositories/collective_repository.dart';

class JoinQueue {
  final CollectiveRepository repository;

  JoinQueue(this.repository);

  Future<String> call({required String sessionId, required String name, required String deviceId}) {
    return repository.joinQueue(sessionId: sessionId, name: name, deviceId: deviceId);
  }
}
