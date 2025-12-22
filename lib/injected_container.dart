import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/collective_session/data/datasources/collective_remote_data_source.dart';
import 'features/collective_session/data/repositories/collective_repository_impl.dart';
import 'features/collective_session/domain/repositories/collective_repository.dart';
import 'features/collective_session/domain/usecases/join_session.dart';
import 'features/collective_session/domain/usecases/submit_fragment.dart';
import 'features/collective_session/presentation/bloc/collective_session_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  // Supabase is initialized in main.dart, but we register the client here
  sl.registerLazySingleton(() => Supabase.instance.client);

  //! Features - Collective Session
  // Bloc
  sl.registerFactory(
    () => CollectiveSessionBloc(
      joinSession: sl(),
      submitFragment: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => JoinSession(sl()));
  sl.registerLazySingleton(() => SubmitFragment(sl()));

  // Repository
  sl.registerLazySingleton<CollectiveRepository>(
    () => CollectiveRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CollectiveRemoteDataSource>(
    () => CollectiveRemoteDataSourceImpl(supabaseClient: sl()),
  );
}
