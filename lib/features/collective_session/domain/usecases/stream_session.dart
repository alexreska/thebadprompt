import '../entities/tbp_session.dart';
import '../repositories/collective_repository.dart';

class StreamSession {
  final CollectiveRepository repository;

  StreamSession(this.repository);

  Stream<TbpSession> call(String sessionId) {
    return repository.streamSession(sessionId);
  }
}
