import '../repositories/collective_repository.dart';

class SubmitFragment {
  final CollectiveRepository repository;

  SubmitFragment(this.repository);

  Future<void> call(String sessionId, String fragment, String authorName) {
    return repository.submitFragment(sessionId, fragment, authorName);
  }
}
