import '../repositories/collective_repository.dart';

class DebugFastForward {
  final CollectiveRepository repository;

  DebugFastForward(this.repository);

  Future<void> call(String sessionId) async {
    return repository.fastForwardSession(sessionId);
  }
}
