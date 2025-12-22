import 'package:equatable/equatable.dart';

class TbpSession extends Equatable {
  final String id;

  const TbpSession({required this.id});

  @override
  List<Object?> get props => [id];
}
