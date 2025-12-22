import '../../domain/entities/tbp_session.dart';
import '../../domain/repositories/collective_repository.dart';
import '../datasources/collective_remote_data_source.dart';

class CollectiveRepositoryImpl implements CollectiveRepository {
  final CollectiveRemoteDataSource remoteDataSource;

  CollectiveRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TbpSession> joinSession(String username) {
    return remoteDataSource.joinSession(username);
  }

  @override
  Future<void> submitFragment(String sessionId, String fragment) {
    return remoteDataSource.submitFragment(sessionId, fragment);
  }
}
