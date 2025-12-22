import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/fragment.dart';
import '../../domain/entities/tbp_session.dart';
import '../../domain/usecases/join_session.dart';
import '../../domain/usecases/submit_fragment.dart';
import '../../domain/usecases/stream_fragments.dart';

// Events
abstract class CollectiveSessionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class JoinSessionRequested extends CollectiveSessionEvent {
  final String username;
  JoinSessionRequested(this.username);
}

class FragmentSubmitted extends CollectiveSessionEvent {
  final String content;
  FragmentSubmitted(this.content);
}


// States
abstract class CollectiveSessionState extends Equatable {
  @override
  List<Object> get props => [];
}

class CollectiveSessionInitial extends CollectiveSessionState {}

class CollectiveSessionLoading extends CollectiveSessionState {}

class CollectiveSessionActive extends CollectiveSessionState {
  final TbpSession session;
  final List<Fragment> fragments;

  CollectiveSessionActive({required this.session, this.fragments = const []});
  
  @override
  List<Object> get props => [session, fragments];
}

class CollectiveSessionError extends CollectiveSessionState {
  final String message;
  CollectiveSessionError(this.message);
  @override
  List<Object> get props => [message];
}

class CollectiveSessionBloc extends Bloc<CollectiveSessionEvent, CollectiveSessionState> {
  final JoinSession joinSession;
  final SubmitFragment submitFragment;
  final StreamFragments streamFragments;

  CollectiveSessionBloc({
    required this.joinSession,
    required this.submitFragment,
    required this.streamFragments,
  }) : super(CollectiveSessionInitial()) {
    on<JoinSessionRequested>(_onJoinSessionRequested);
    on<FragmentSubmitted>(_onFragmentSubmitted);

  }

  Future<void> _onJoinSessionRequested(JoinSessionRequested event, Emitter<CollectiveSessionState> emit) async {
    emit(CollectiveSessionLoading());
    try {
      final session = await joinSession(event.username);
      
      // Subscribe to stream
      await emit.forEach(
        streamFragments(session.id),
        onData: (List<Fragment> fragments) => CollectiveSessionActive(
          session: session,
          fragments: fragments,
        ),
        // onError: (error, stackTrace) => CollectiveSessionError('Failed to sync stream'),
        onError: (error, _) => CollectiveSessionError('Failed to sync stream: $error'),
      );
      
      // Note: emit.forEach manages the subscription, but we need to set the initial state first?
      // Actually emit.forEach blocks. We should probably start the subscription separately or yield properly.
      // Better pattern: emit Active state logic inside the onData callback of emit.forEach?
      // Or just listen manually. Let's use emit.forEach carefully.
      // Wait, standard bloc pattern:
      // 1. Join -> Success -> Emit Active(session, [])
      // 2. Add(StartListening) -> calls stream -> yields updates
      
      // Let's simplify: Join gets the ID. Then we immediately start listening.
      // But we can't emit.forEach AND handle other events easily if we await it here.
      

    } catch (e) {
      emit(CollectiveSessionError(e.toString()));
    }
  }

  Future<void> _onFragmentSubmitted(FragmentSubmitted event, Emitter<CollectiveSessionState> emit) async {
    final currentState = state;
    if (currentState is CollectiveSessionActive) {
      try {
        await submitFragment(currentState.session.id, event.content);
        // Success? The stream will update the UI.
      } catch (e) {
        // Show error? For now silent or snackbar via listener.
      }
    }
  }

}
