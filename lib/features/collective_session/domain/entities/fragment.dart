import 'package:equatable/equatable.dart';

class Fragment extends Equatable {
  final String id;
  final String content;
  final String authorName; // Display name
  final DateTime createdAt;

  const Fragment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, content, authorName, createdAt];
}
