import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/join_session.dart';
import '../../domain/usecases/submit_fragment.dart';

// Events
abstract class CollectiveSessionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// States
abstract class CollectiveSessionState extends Equatable {
  @override
  List<Object> get props => [];
}

class CollectiveSessionInitial extends CollectiveSessionState {}

class CollectiveSessionBloc extends Bloc<CollectiveSessionEvent, CollectiveSessionState> {
  final JoinSession joinSession;
  final SubmitFragment submitFragment;

  CollectiveSessionBloc({
    required this.joinSession,
    required this.submitFragment,
  }) : super(CollectiveSessionInitial()) {
    // Define event handlers later
  }
}
