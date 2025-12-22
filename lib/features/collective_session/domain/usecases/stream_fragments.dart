import '../entities/fragment.dart';
import '../repositories/collective_repository.dart';

class StreamFragments {
  final CollectiveRepository repository;

  StreamFragments(this.repository);

  Stream<List<Fragment>> call(String sessionId) {
    return repository.streamFragments(sessionId);
  }
}
