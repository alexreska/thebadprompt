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
import '../../domain/usecases/stream_session.dart';
import '../../domain/usecases/expire_session.dart'; // Restored
import 'package:logger/logger.dart';

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

class CreateRoomRequested extends CollectiveSessionEvent {
  final String name;
  CreateRoomRequested(this.name);
  @override
  List<Object> get props => [name];
}

class JoinRoomRequested extends CollectiveSessionEvent {
  final String roomCode;
  JoinRoomRequested(this.roomCode);
  @override
  List<Object> get props => [roomCode];
}

class LeaveSession extends CollectiveSessionEvent {}

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

class SessionUpdated extends CollectiveSessionEvent {
  final TbpSession session;
  SessionUpdated(this.session);
  @override
  List<Object> get props => [session];
}

class SessionExpired extends CollectiveSessionEvent {
  // Triggered when timer ends
}

// Events
class LoadRoomsRequested extends CollectiveSessionEvent {}

// States
abstract class CollectiveSessionState extends Equatable {
  const CollectiveSessionState();
  
  @override
  List<Object?> get props => [];
}

class CollectiveSessionInitial extends CollectiveSessionState {}

class CollectiveSessionLoading extends CollectiveSessionState {}

class CollectiveSessionError extends CollectiveSessionState {
  final String message;
  const CollectiveSessionError(this.message);
  @override
  List<Object?> get props => [message];
}

class CollectiveSessionLobby extends CollectiveSessionState {
  final List<TbpSession> rooms;
  final bool isLoading;
  final String? error;

  const CollectiveSessionLobby({
    this.rooms = const [],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [rooms, isLoading, error];
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
  final String? myAuthorName;
  final Duration turnRemainingTime;
  final bool isGenerating;

  const CollectiveSessionActive({
    required this.session,
    this.fragments = const [],
    this.remainingTime = const Duration(minutes: 7),
    this.queueStatus = QueueStatus.none,
    this.queuePosition,
    this.myDeviceId,
    this.myQueueId,
    this.myAuthorName,
    this.turnRemainingTime = Duration.zero,
    this.isGenerating = false,
  });

  CollectiveSessionActive copyWith({
    TbpSession? session,
    List<Fragment>? fragments,
    Duration? remainingTime,
    QueueStatus? queueStatus,
    int? queuePosition,
    String? myDeviceId,
    String? myQueueId,
    String? myAuthorName,
    Duration? turnRemainingTime,
    bool? isGenerating,
  }) {
    return CollectiveSessionActive(
      session: session ?? this.session,
      fragments: fragments ?? this.fragments,
      remainingTime: remainingTime ?? this.remainingTime,
      queueStatus: queueStatus ?? this.queueStatus,
      queuePosition: queuePosition ?? this.queuePosition,
      myDeviceId: myDeviceId ?? this.myDeviceId,
      myQueueId: myQueueId ?? this.myQueueId,
      myAuthorName: myAuthorName ?? this.myAuthorName,
      turnRemainingTime: turnRemainingTime ?? this.turnRemainingTime,
      isGenerating: isGenerating ?? this.isGenerating,
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
        myAuthorName ?? '',
        turnRemainingTime,
        isGenerating,
      ];
}

class CollectiveSessionBloc extends Bloc<CollectiveSessionEvent, CollectiveSessionState> {
  final JoinSession joinSession;
  final SubmitFragment submitFragment;
  final StreamFragments streamFragments;
  final DebugFastForward debugFastForward;
  final JoinQueue joinQueue;
  final SubmitQueueFragment submitQueueFragment;
  final GetQueueStatus getQueueStatusUseCase; // Restored
  final StreamSession streamSession; // Add this
  final ExpireSession expireSession; // Add this
  final logger = Logger(); // Added

  StreamSubscription? _fragmentsSubscription;
  StreamSubscription? _sessionSubscription; // Add this
  Timer? _timer;
  Timer? _queuePoller;
  String? _cachedDeviceId;
  
  // ... constructor ...
  
  CollectiveSessionBloc({
    required this.joinSession,
    required this.submitFragment,
    required this.streamFragments,
    required this.debugFastForward,
    required this.joinQueue,
    required this.submitQueueFragment,
    required this.getQueueStatusUseCase,
    required this.streamSession, // Add this
    required this.expireSession, // Add this
  }) : super(CollectiveSessionInitial()) {
     // ... handlers ...

     on<JoinSessionRequested>(_onJoinSessionRequested);
     on<LoadRoomsRequested>(_onLoadRoomsRequested);
     on<CreateRoomRequested>(_onCreateRoomRequested);
     on<JoinRoomRequested>(_onJoinRoomRequested);
     on<LeaveSession>(_onLeaveSession);
     on<FragmentSubmitted>(_onFragmentSubmitted);
     on<FragmentsUpdated>(_onFragmentsUpdated);
     on<TimerTicked>(_onTimerTicked);
     on<DebugFastForwardRequested>(_onDebugFastForwardRequested);
     on<JoinQueueRequested>(_onJoinQueueRequested);
     on<QueueStatusUpdated>(_onQueueStatusUpdated);
     on<SubmitQueueFragmentRequested>(_onSubmitQueueFragmentRequested);
     on<SessionUpdated>(_onSessionUpdated); // Handle session updates
     on<SessionExpired>(_onSessionExpired); // Add this

  }

  Future<void> _onSessionExpired(SessionExpired event, Emitter<CollectiveSessionState> emit) async {
     if (state is CollectiveSessionActive) {
        final currentState = state as CollectiveSessionActive;
        try {
           // Notify UI that generation is starting
           emit(currentState.copyWith(isGenerating: true));
           
           final imageUrl = await expireSession(currentState.session.id);
           
           if (imageUrl != null) {
              // FORCE UPDATE STATE
              final updatedSession = currentState.session.copyWith(imageUrl: imageUrl);
              emit(currentState.copyWith(
                session: updatedSession,
                isGenerating: false, // Turn off flag
              ));
           } else {
             // Failed or no image? Reset flag anyway
             emit(currentState.copyWith(isGenerating: false));
           }
        } catch (e) {
           // ignore: avoid_print
           print('Error expiring session: $e');
           emit(currentState.copyWith(isGenerating: false));
        }
     }
  }

  Future<void> _onJoinSessionRequested(JoinSessionRequested event, Emitter<CollectiveSessionState> emit) async {
    emit(CollectiveSessionLoading());
    try {
      final session = await joinSession(event.username);

      // Start fetching fragments
      _fragmentsSubscription?.cancel();
      _fragmentsSubscription = streamFragments(session.id).listen((fragments) {
        add(FragmentsUpdated(fragments));
         _checkQueueStatus(session.id); 
      });
      
      // Start listening to session updates (Reveal Logic)
      _sessionSubscription?.cancel();
      _sessionSubscription = streamSession(session.id).listen((updatedSession) {
         add(SessionUpdated(updatedSession));
      });

      _startTimer(session.startTime);
      _startQueuePoller(session.id);

      emit(CollectiveSessionActive(session: session));
    } catch (e) {
      emit(CollectiveSessionError(e.toString()));
    }
  }

  Future<void> _onLoadRoomsRequested(LoadRoomsRequested event, Emitter<CollectiveSessionState> emit) async {
    emit(const CollectiveSessionLobby(isLoading: true)); // Or copyWith if state was already Lobby
    try {
      final rooms = await joinSession.listRooms();
      emit(CollectiveSessionLobby(rooms: rooms, isLoading: false));
    } catch (e) {
      emit(CollectiveSessionLobby(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateRoomRequested(CreateRoomRequested event, Emitter<CollectiveSessionState> emit) async {
    emit(CollectiveSessionLoading());
    try {
      final session = await joinSession.createRoom(event.name);
      _initializeSession(session, emit);
    } catch (e) {
      emit(CollectiveSessionError(e.toString()));
    }
  }

  Future<void> _onJoinRoomRequested(JoinRoomRequested event, Emitter<CollectiveSessionState> emit) async {
    emit(CollectiveSessionLoading());
    try {
      final session = await joinSession.joinRoom(event.roomCode);
      _initializeSession(session, emit);
    } catch (e) {
      emit(CollectiveSessionError(e.toString()));
    }
  }

  void _initializeSession(TbpSession session, Emitter<CollectiveSessionState> emit) {
     // Start fetching fragments
      _fragmentsSubscription?.cancel();
      _fragmentsSubscription = streamFragments(session.id).listen((fragments) {
        add(FragmentsUpdated(fragments));
         _checkQueueStatus(session.id); 
      });
      
      // Start listening to session updates (Reveal Logic)
      _sessionSubscription?.cancel();
      _sessionSubscription = streamSession(session.id).listen((updatedSession) {
         add(SessionUpdated(updatedSession));
      });

      _startTimer(session.startTime);
      _startQueuePoller(session.id);

      emit(CollectiveSessionActive(session: session));
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
       final result = await getQueueStatusUseCase.call(sessionId: sessionId, queueId: myQueueId); // removed !
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
            myDeviceId: deviceId, // CRITICAL: Persist deviceId as currentState is stale
            myAuthorName: event.username, // NEW: Persist the author name!
            queuePosition: null, // Let poller fetch actual position
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
        final author = currentState.myAuthorName ?? 'User';
        
        await submitQueueFragment(
          sessionId: currentState.session.id,
          content: event.content,
          authorName: author, // Use stored name
          deviceId: currentState.myDeviceId!,
        );
        emit(currentState.copyWith(queueStatus: QueueStatus.completed));
      } catch (e) {
        // ignore: avoid_print
        print('Queue Submit Error: $e');
      }
    }
  }

  // ... (Keep existing methods: _startTimer, _tick, _onFragmentSubmitted, _onFragmentsUpdated, _onTimerTicked, _onDebugFastForwardRequested)

  void _startTimer(DateTime startTime) {
    _timer?.cancel();
    _tick(startTime); 
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(startTime));
  }

  void _onSessionUpdated(SessionUpdated event, Emitter<CollectiveSessionState> emit) {
      if (state is CollectiveSessionActive) {
         final currentState = state as CollectiveSessionActive;
         // Check if image URL appeared
         if (event.session.imageUrl != null && currentState.session.imageUrl == null) {
             emit(currentState.copyWith(
               session: event.session, // Update session with image
             ));
         } else {
             emit(currentState.copyWith(session: event.session));
         }
      }
  }

  // ... (keep _startQueuePoller, _checkQueueStatus ...)

  void _tick(DateTime startTime) {
    if (state is! CollectiveSessionActive) return;

    final now = DateTime.now();
    final endTime = startTime.add(const Duration(minutes: 7));
    final remaining = endTime.difference(now);

    if (remaining.isNegative) {
      if (_timer != null && _timer!.isActive) {
         add(TimerTicked(Duration.zero));
         _timer?.cancel();
         add(SessionExpired()); // Dispatch event instead of direct call
      }
    } else {
      add(TimerTicked(remaining));
    }
  }
  
  Future<void> _onLeaveSession(LeaveSession event, Emitter<CollectiveSessionState> emit) async {
    _fragmentsSubscription?.cancel();
    _sessionSubscription?.cancel();
    _timer?.cancel();
    _queuePoller?.cancel();
    emit(CollectiveSessionInitial());
    // Immediately trigger load rooms for the lobby
    add(LoadRoomsRequested());
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
    _sessionSubscription?.cancel(); // Fixes Memory Leak
    _timer?.cancel();
    _queuePoller?.cancel(); // Cancel polling
    return super.close();
  }
}
