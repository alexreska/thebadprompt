import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/fragment.dart';
import '../../domain/entities/tbp_session.dart';
import '../../domain/usecases/join_session.dart';
import '../../domain/usecases/submit_fragment.dart';
import '../../domain/usecases/stream_fragments.dart';
import '../../domain/usecases/debug_fast_forward.dart';

// Events
abstract class CollectiveSessionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class JoinSessionRequested extends CollectiveSessionEvent {
  final String username;
  JoinSessionRequested(this.username);
  @override
  List<Object> get props => [username];
}

class FragmentSubmitted extends CollectiveSessionEvent {
  final String content;
  final String authorName;
  FragmentSubmitted(this.content, this.authorName);
  @override
  List<Object> get props => [content, authorName];
}

class FragmentsUpdated extends CollectiveSessionEvent {
  final List<Fragment> fragments;
  FragmentsUpdated(this.fragments);
  @override
  List<Object> get props => [fragments];
}

class TimerTicked extends CollectiveSessionEvent {
  final Duration remainingTime;
  TimerTicked(this.remainingTime);
  @override
  List<Object> get props => [remainingTime];
}

class DebugFastForwardRequested extends CollectiveSessionEvent {}

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
  final Duration remainingTime;

  CollectiveSessionActive({
    required this.session,
    this.fragments = const [],
    this.remainingTime = const Duration(minutes: 7),
  });

  CollectiveSessionActive copyWith({
    TbpSession? session,
    List<Fragment>? fragments,
    Duration? remainingTime,
  }) {
    return CollectiveSessionActive(
      session: session ?? this.session,
      fragments: fragments ?? this.fragments,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  List<Object> get props => [session, fragments, remainingTime];
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
  final DebugFastForward debugFastForward;

  StreamSubscription? _fragmentsSubscription;
  Timer? _timer;

  CollectiveSessionBloc({
    required this.joinSession,
    required this.submitFragment,
    required this.streamFragments,
    required this.debugFastForward,
  }) : super(CollectiveSessionInitial()) {
    on<JoinSessionRequested>(_onJoinSessionRequested);
    on<FragmentSubmitted>(_onFragmentSubmitted);
    on<FragmentsUpdated>(_onFragmentsUpdated);
    on<TimerTicked>(_onTimerTicked);
    on<DebugFastForwardRequested>(_onDebugFastForwardRequested);
  }

  Future<void> _onJoinSessionRequested(JoinSessionRequested event, Emitter<CollectiveSessionState> emit) async {
    emit(CollectiveSessionLoading());
    try {
      final session = await joinSession(event.username);

      // Start fetching fragments
      _fragmentsSubscription?.cancel();
      _fragmentsSubscription = streamFragments(session.id).listen((fragments) {
        add(FragmentsUpdated(fragments));
      });

      // Start timer
      _startTimer(session.startTime);

      emit(CollectiveSessionActive(session: session));
    } catch (e) {
      emit(CollectiveSessionError(e.toString()));
    }
  }

  void _startTimer(DateTime startTime) {
    _timer?.cancel();
    _tick(startTime); // Initial tick
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(startTime));
  }

  void _tick(DateTime startTime) {
    final now = DateTime.now();
    // Assuming 7 minutes duration
    final endTime = startTime.add(const Duration(minutes: 7));
    // final remaining = endTime.difference(now);
    final remaining = endTime.difference(now);
    // print('DEBUG: Tick remaining: ${remaining.inSeconds}');

    if (remaining.isNegative) {
      add(TimerTicked(Duration.zero));
      _timer?.cancel();
      // Auto-refresh session logic
      // Wait a moment for UX then refresh
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
           add(JoinSessionRequested('Anon')); // Re-join to trigger expiry/new session
        }
      });
    } else {
      add(TimerTicked(remaining));
    }
  }

  Future<void> _onFragmentSubmitted(FragmentSubmitted event, Emitter<CollectiveSessionState> emit) async {
    final currentState = state;
    if (currentState is CollectiveSessionActive) {
      try {
        await submitFragment(currentState.session.id, event.content, event.authorName);
        // Success? The stream will update the UI.
      } catch (e) {
        // Show error
      }
    }
  }

  void _onFragmentsUpdated(FragmentsUpdated event, Emitter<CollectiveSessionState> emit) {
    if (state is CollectiveSessionActive) {
      emit((state as CollectiveSessionActive).copyWith(fragments: event.fragments));
    }
  }

  void _onTimerTicked(TimerTicked event, Emitter<CollectiveSessionState> emit) {
    if (state is CollectiveSessionActive) {
      emit((state as CollectiveSessionActive).copyWith(remainingTime: event.remainingTime));
    }
  }

  Future<void> _onDebugFastForwardRequested(DebugFastForwardRequested event, Emitter<CollectiveSessionState> emit) async {
    if (state is CollectiveSessionActive) {
      final session = (state as CollectiveSessionActive).session;
      try {
        await debugFastForward(session.id);
        add(JoinSessionRequested('Anon')); // Re-join to get updated time
      } catch (e) {
        // ignore: avoid_print
        print('Debug FF Error: $e');
      }
    }
  }

  @override
  Future<void> close() {
    _fragmentsSubscription?.cancel();
    _timer?.cancel();
    return super.close();
  }
}
