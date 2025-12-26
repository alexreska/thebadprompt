import '../repositories/collective_repository.dart';
import '../entities/tbp_session.dart';

class JoinSession {
  final CollectiveRepository repository;

  JoinSession(this.repository);

  Future<TbpSession> call(String username) {
    return repository.joinSession(username);
  }

  Future<TbpSession> createRoom(String roomName) {
    return repository.createRoom(roomName);
  }

  Future<List<TbpSession>> listRooms() {
    return repository.listRooms();
  }

  Future<TbpSession> joinRoom(String roomCode) {
    return repository.joinRoom(roomCode);
  }
}
