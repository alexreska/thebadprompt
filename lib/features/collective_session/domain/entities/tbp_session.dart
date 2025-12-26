import 'package:equatable/equatable.dart';

class TbpSession extends Equatable {
  final String id;
  final DateTime startTime;
  final String? imageUrl;
  final String? roomCode;
  final String? roomName;

  const TbpSession({
    required this.id,
    required this.startTime,
    this.imageUrl,
    this.roomCode,
    this.roomName,
  });

  TbpSession copyWith({
    String? id,
    DateTime? startTime,
    String? imageUrl,
    String? roomCode,
    String? roomName,
  }) {
    return TbpSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      imageUrl: imageUrl ?? this.imageUrl,
      roomCode: roomCode ?? this.roomCode,
      roomName: roomName ?? this.roomName,
    );
  }

  @override
  List<Object?> get props => [id, startTime, imageUrl, roomCode, roomName];
}
