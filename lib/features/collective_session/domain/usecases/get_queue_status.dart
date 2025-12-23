import '../repositories/collective_repository.dart';

class GetQueueStatus {
  final CollectiveRepository repository;

  GetQueueStatus(this.repository);

  Future<Map<String, dynamic>> call({required String sessionId, required String queueId}) {
    return repository.getQueueStatus(sessionId: sessionId, queueId: queueId);
  }
}
