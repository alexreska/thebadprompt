import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// State
abstract class GalleryState extends Equatable {
  const GalleryState();
  @override
  List<Object> get props => [];
}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<Map<String, dynamic>> sessions;
  const GalleryLoaded(this.sessions);
  @override
  List<Object> get props => [sessions];
}

class GalleryError extends GalleryState {
  final String message;
  const GalleryError(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class GalleryCubit extends Cubit<GalleryState> {
  final SupabaseClient supabaseClient;

  GalleryCubit({required this.supabaseClient}) : super(GalleryInitial());

  Future<void> loadSessions() async {
    // Only emit loading if we don't have data, or if explicit refresh loop?
    // Let's emit Loading to show spinner on first load.
    if (state is! GalleryLoaded) {
      emit(GalleryLoading());
    }

    try {
      final response = await supabaseClient
          .from('sessions')
          .select()
          .eq('status', 'finished')
          .order('start_time', ascending: false)
          .limit(50);
          
      final sessions = List<Map<String, dynamic>>.from(response);
      emit(GalleryLoaded(sessions));
    } catch (e) {
      emit(GalleryError(e.toString()));
    }
  }

  void prependSession(Map<String, dynamic> session) {
    if (state is GalleryLoaded) {
      final currentSessions = (state as GalleryLoaded).sessions;
      emit(GalleryLoaded([session, ...currentSessions]));
    } else {
      // If not loaded yet, just set it as the list
      emit(GalleryLoaded([session]));
      // But maybe trigger a load too?
      loadSessions();
    }
  }
}
