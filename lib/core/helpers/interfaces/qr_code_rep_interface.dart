

import '../models/qr_code_model.dart';

abstract class QrCodeRepositoryInterface {
  Future<List<QrCodeModel>> getAllQrCodes();
  Future<QrCodeModel> saveQrCode(QrCodeModel qrCode);
  Future<void> deleteQrCode(int id);
  Future<int?> startQrScanner(); 
  Future<void> stopQrScanner();
  Stream<String> get qrCodeStream;
}