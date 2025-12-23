import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/fragment.dart';
import '../../domain/entities/tbp_session.dart';
import '../../domain/usecases/join_session.dart';
import '../../domain/usecases/submit_fragment.dart';
import '../../domain/usecases/stream_fragments.dart';
import '../../domain/usecases/debug_fast_forward.dart';
import '../../domain/usecases/join_queue.dart';
import '../../domain/usecases/submit_queue_fragment.dart';
import '../../domain/usecases/get_queue_status.dart';

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

class JoinQueueRequested extends CollectiveSessionEvent {
  final String username;
  JoinQueueRequested(this.username);
  @override
  List<Object> get props => [username];
}

class QueueStatusUpdated extends CollectiveSessionEvent {
  final QueueStatus status;
  final int? position;
  final DateTime? turnExpiresAt;
  
  QueueStatusUpdated({required this.status, this.position, this.turnExpiresAt});
  
  @override
  List<Object> get props => [status, position ?? 0, turnExpiresAt ?? DateTime(0)];
}

class SubmitQueueFragmentRequested extends CollectiveSessionEvent {
  final String content;
  SubmitQueueFragmentRequested(this.content);
  @override
  List<Object> get props => [content];
}

// States
abstract class CollectiveSessionState extends Equatable {
  @override
  List<Object> get props => [];
}

class CollectiveSessionInitial extends CollectiveSessionState {}

class CollectiveSessionLoading extends CollectiveSessionState {}

class CollectiveSessionError extends CollectiveSessionState {
  final String message;
  CollectiveSessionError(this.message);
  @override
  List<Object> get props => [message];
}

enum QueueStatus {
  none,
  joining,
  waiting,
  active, // It is my turn!
  completed, // Turn done
  skipped
}

class CollectiveSessionActive extends CollectiveSessionState {
  final TbpSession session;
  final List<Fragment> fragments;
  final Duration remainingTime;
  
  // Queue Fields
  final QueueStatus queueStatus;
  final int? queuePosition;
  final String? myDeviceId;
  final String? myQueueId;
  final Duration turnRemainingTime; // 20s countdown

  CollectiveSessionActive({
    required this.session,
    this.fragments = const [],
    this.remainingTime = const Duration(minutes: 7),
    this.queueStatus = QueueStatus.none,
    this.queuePosition,
    this.myDeviceId,
    this.myQueueId,
    this.turnRemainingTime = Duration.zero,
  });

  CollectiveSessionActive copyWith({
    TbpSession? session,
    List<Fragment>? fragments,
    Duration? remainingTime,
    QueueStatus? queueStatus,
    int? queuePosition,
    String? myDeviceId,
    String? myQueueId,
    Duration? turnRemainingTime,
  }) {
    return CollectiveSessionActive(
      session: session ?? this.session,
      fragments: fragments ?? this.fragments,
      remainingTime: remainingTime ?? this.remainingTime,
      queueStatus: queueStatus ?? this.queueStatus,
      queuePosition: queuePosition ?? this.queuePosition,
      myDeviceId: myDeviceId ?? this.myDeviceId,
      myQueueId: myQueueId ?? this.myQueueId,
      turnRemainingTime: turnRemainingTime ?? this.turnRemainingTime,
    );
  }

  @override
  List<Object> get props => [
        session, 
        fragments, 
        remainingTime, 
        queueStatus, 
        queuePosition ?? -1, 
        myDeviceId ?? '', 
        myQueueId ?? '',
        turnRemainingTime
      ];
}

class CollectiveSessionBloc extends Bloc<CollectiveSessionEvent, CollectiveSessionState> {
  final JoinSession joinSession;
  final SubmitFragment submitFragment;
  final StreamFragments streamFragments;
  final DebugFastForward debugFastForward;
  final JoinQueue joinQueue;
  final SubmitQueueFragment submitQueueFragment;
  final GetQueueStatus getQueueStatus;

  StreamSubscription? _fragmentsSubscription;
  Timer? _timer;
  Timer? _queuePoller;
  String? _cachedDeviceId;

  CollectiveSessionBloc({
    required this.joinSession,
    required this.submitFragment,
    required this.streamFragments,
    required this.debugFastForward,
    required this.joinQueue,
    required this.submitQueueFragment,
    required this.getQueueStatus,
  }) : super(CollectiveSessionInitial()) {
    on<JoinSessionRequested>(_onJoinSessionRequested);
    on<FragmentSubmitted>(_onFragmentSubmitted); // Keeps legacy for now or remove?
    on<FragmentsUpdated>(_onFragmentsUpdated);
    on<TimerTicked>(_onTimerTicked);
    on<DebugFastForwardRequested>(_onDebugFastForwardRequested);
    
    // Queue Events
    on<JoinQueueRequested>(_onJoinQueueRequested);
    on<QueueStatusUpdated>(_onQueueStatusUpdated);
    on<SubmitQueueFragmentRequested>(_onSubmitQueueFragmentRequested);
  }

  Future<void> _onJoinSessionRequested(JoinSessionRequested event, Emitter<CollectiveSessionState> emit) async {
    emit(CollectiveSessionLoading());
    try {
      final session = await joinSession(event.username);

      // Start fetching fragments
      _fragmentsSubscription?.cancel();
      _fragmentsSubscription = streamFragments(session.id).listen((fragments) {
        add(FragmentsUpdated(fragments));
        // Also Trigger Queue Status Check when fragments update (as a proxy for session activity)?
        // Or better, set up a separate Poller. 
        _checkQueueStatus(session.id); 
      });

      _startTimer(session.startTime);
      _startQueuePoller(session.id); // Poll every 3s

      emit(CollectiveSessionActive(session: session));
    } catch (e) {
      emit(CollectiveSessionError(e.toString()));
    }
  }

  void _startQueuePoller(String sessionId) {
    _queuePoller?.cancel();
    _queuePoller = Timer.periodic(const Duration(seconds: 2), (_) {
       _checkQueueStatus(sessionId);
    });
  }

  Future<void> _checkQueueStatus(String sessionId) async {
     if (state is! CollectiveSessionActive) return;
     final currentState = state as CollectiveSessionActive;
     final myQueueId = currentState.myQueueId;

     if (myQueueId == null) return; // Not in queue yet

     try {
       final result = await getQueueStatus(sessionId: sessionId, queueId: myQueueId);
       final statusStr = result['status'];
       final position = result['position'] as int?;
       final turnExpiresAt = result['turnExpiresAt'] as DateTime?;

       QueueStatus newStatus = QueueStatus.waiting;
       if (statusStr == 'active') {
         newStatus = QueueStatus.active;
       } else if (statusStr == 'completed') {
         newStatus = QueueStatus.completed;
       } else if (statusStr == 'none') {
         newStatus = QueueStatus.none;
       }

       // Optimization: Only emit if changed? Or rely on distinct.
       add(QueueStatusUpdated(
          status: newStatus, 
          position: position, 
          turnExpiresAt: turnExpiresAt
       ));
     } catch (e) {
       // Silent error in poller
     }
  }

  Future<void> _onJoinQueueRequested(JoinQueueRequested event, Emitter<CollectiveSessionState> emit) async {
     if (state is CollectiveSessionActive) {
       final currentState = state as CollectiveSessionActive;
       final deviceId = _cachedDeviceId ?? const Uuid().v4();
       _cachedDeviceId = deviceId;
       
       try {
         // Optimistic update
         emit(currentState.copyWith(
           queueStatus: QueueStatus.joining,
           myDeviceId: deviceId,
         ));
         
         final queueId = await joinQueue(
           sessionId: currentState.session.id, 
           name: event.username, 
           deviceId: deviceId
         );
         
         emit(currentState.copyWith(
           queueStatus: QueueStatus.waiting,
           myQueueId: queueId,
           queuePosition: 99, // Placeholder
         ));
         
       } catch (e) {
         // Revert or error
       }
     }
  }
  
  Future<void> _onSubmitQueueFragmentRequested(SubmitQueueFragmentRequested event, Emitter<CollectiveSessionState> emit) async {
    if (state is CollectiveSessionActive) {
      final currentState = state as CollectiveSessionActive;
      try {
        await submitQueueFragment(
          sessionId: currentState.session.id,
          content: event.content,
          authorName: 'User', // TODO: Store name
          deviceId: currentState.myDeviceId!,
        );
        emit(currentState.copyWith(queueStatus: QueueStatus.completed));
      } catch (e) {
        // Error
      }
    }
  }

  // ... (Keep existing methods: _startTimer, _tick, _onFragmentSubmitted, _onFragmentsUpdated, _onTimerTicked, _onDebugFastForwardRequested)

  void _startTimer(DateTime startTime) {
    _timer?.cancel();
    _tick(startTime); 
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(startTime));
  }

  void _tick(DateTime startTime) {
    // ... existing logic ...
    final now = DateTime.now();
    final endTime = startTime.add(const Duration(minutes: 7));
    final remaining = endTime.difference(now);

    if (remaining.isNegative) {
      add(TimerTicked(Duration.zero));
      _timer?.cancel();
      // Auto-refresh logic (keep it)
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
           add(JoinSessionRequested('Anon'));
        }
      });
    } else {
      add(TimerTicked(remaining));
    }
  }
  
  // Handlers for existing events to maintain compatibility
  Future<void> _onFragmentSubmitted(FragmentSubmitted event, Emitter<CollectiveSessionState> emit) async {
      // Legacy or admin bypass
      final currentState = state;
      if (currentState is CollectiveSessionActive) {
         await submitFragment(currentState.session.id, event.content, event.authorName);
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
        await debugFastForward(session.id);
        add(JoinSessionRequested('Anon'));
    }
  }

  Future<void> _onQueueStatusUpdated(QueueStatusUpdated event, Emitter<CollectiveSessionState> emit) async {
     if (state is CollectiveSessionActive) {
        emit((state as CollectiveSessionActive).copyWith(
          queueStatus: event.status,
          queuePosition: event.position,
          turnRemainingTime: event.turnExpiresAt?.difference(DateTime.now())
        ));
     }
  }

  @override
  Future<void> close() {
    _fragmentsSubscription?.cancel();
    _timer?.cancel();
    _queuePoller?.cancel(); // Cancel polling
    return super.close();
  }
}
