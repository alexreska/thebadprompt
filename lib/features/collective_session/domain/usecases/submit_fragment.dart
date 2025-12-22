import '../repositories/collective_repository.dart';

class SubmitFragment {
  final CollectiveRepository repository;

  SubmitFragment(this.repository);

  Future<void> call(String sessionId, String fragment) {
    return repository.submitFragment(sessionId, fragment);
  }
}
