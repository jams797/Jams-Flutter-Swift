import 'qr_code_model.dart';

class QrDBModel extends QrCodeModel {
  const QrDBModel({
    int? id,
    required String code,
  }) : super(
          id: id,
          code: code,
        );

  factory QrDBModel.fromMap(Map<String, dynamic> map) {
    return QrDBModel(
      id: map['id'],
      code: map['code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
    };
  }

  factory QrDBModel.fromEntity(QrCodeModel entity) {
    return QrDBModel(
      id: entity.id,
      code: entity.code,
    );
  }
}