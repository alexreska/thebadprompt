import '../repositories/collective_repository.dart';
import '../entities/tbp_session.dart';

class JoinSession {
  final CollectiveRepository repository;

  JoinSession(this.repository);

  Future<TbpSession> call(String username) {
    return repository.joinSession(username);
  }
}
