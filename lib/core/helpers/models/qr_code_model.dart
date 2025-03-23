import 'package:equatable/equatable.dart';

class QrCodeModel extends Equatable {
  final int? id;
  final String code;

  const QrCodeModel({
    this.id,
    required this.code,
  });

  @override
  List<Object?> get props => [id, code];
}