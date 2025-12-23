import '../repositories/collective_repository.dart';

class SubmitQueueFragment {
  final CollectiveRepository repository;

  SubmitQueueFragment(this.repository);

  Future<void> call({required String sessionId, required String content, required String authorName, required String deviceId}) {
    return repository.submitFragmentWithQueue(sessionId: sessionId, content: content, authorName: authorName, deviceId: deviceId);
  }
}
