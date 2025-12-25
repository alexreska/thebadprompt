import '../repositories/collective_repository.dart';

class ExpireSession {
  final CollectiveRepository repository;

  ExpireSession(this.repository);

  Future<String?> call(String sessionId) async {
    return repository.expireSession(sessionId);
  }
}
