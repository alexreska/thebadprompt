import 'package:equatable/equatable.dart';

class TbpSession extends Equatable {
  final String id;
  final DateTime startTime;
  final String? imageUrl;

  const TbpSession({
    required this.id,
    required this.startTime,
    this.imageUrl,
  });

  TbpSession copyWith({
    String? id,
    DateTime? startTime,
    String? imageUrl,
  }) {
    return TbpSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, startTime, imageUrl];
}
