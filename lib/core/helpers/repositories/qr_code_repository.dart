import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:jams_flutter_swift/core/helpers/interfaces/qr_code_rep_interface.dart';
import 'package:jams_flutter_swift/core/helpers/models/qr_code_model.dart';
import 'package:jams_flutter_swift/core/helpers/models/qr_data_model.dart';

import '../dbresources/database_helper.dart';

class QrCodeRepository implements QrCodeRepositoryInterface {
  final DatabaseHelper _databaseHelper;
  static const MethodChannel _channel = MethodChannel('com.jams797.ios_channel/qr_scanner');
  final StreamController<String> _qrCodeCtr = StreamController<String>.broadcast();
  
  // Para manejar la textura de la cámara
  int? _cameraTextureId;

  QrCodeRepository(this._databaseHelper) {
    _initMethodCallHandler();
    dev.log('QrCodeRepository inicializado', name: 'QrCodeRepository');
  }

  void _initMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      dev.log('Llamada al método: ${call.method} con args: ${call.arguments}', name: 'QrCodeRepository');
      
      if (call.method == 'onQRCodeDetected') {
        final String qrCode = call.arguments;
        dev.log('QR Code detectado en channel: $qrCode', name: 'QrCodeRepository');
        
        // Emitir el código QR en el stream
        _qrCodeCtr.add(qrCode);
        
        // Devolver un valor para completar el Future
        return 'received';
      }
      
      return null;
    });
  }

  @override
  Stream<String> get qrCodeStream => _qrCodeCtr.stream;

  @override
  Future<List<QrCodeModel>> getAllQrCodes() async {
    dev.log('Obteniendo todos los códigos QR', name: 'QrCodeRepository');
    return await _databaseHelper.getAllQrCodes();
  }

  @override
  Future<QrCodeModel> saveQrCode(QrCodeModel qrCode) async {
    dev.log('Guardando código QR: ${qrCode.code}', name: 'QrCodeRepository');
    final qrCodeModel = QrDBModel.fromEntity(qrCode);
    final id = await _databaseHelper.insertQrCode(qrCodeModel);
    return QrDBModel(
      id: id,
      code: qrCode.code,
    );
  }

  @override
  Future<void> deleteQrCode(int id) async {
    dev.log('Eliminando código QR con ID: $id', name: 'QrCodeRepository');
    await _databaseHelper.deleteQrCode(id);
  }

  @override
  Future<int?> startQrScanner() async {
    dev.log('Iniciando escáner de QR', name: 'QrCodeRepository');
    try {
      // Usar dynamic para evitar problemas de tipo
      final dynamic result = await _channel.invokeMethod('startScan');
      dev.log('Resultado bruto del escáner: $result', name: 'QrCodeRepository');
      
      if (result is Map) {
        // Extrae el ID de textura de manera segura
        final textureId = result['textureId'];
        if (textureId is int) {
          _cameraTextureId = textureId;
          dev.log('Escáner de QR iniciado correctamente con textureId: $_cameraTextureId', name: 'QrCodeRepository');
          return _cameraTextureId;
        } else {
          dev.log('Error: textureId no es un entero: $textureId (${textureId.runtimeType})', name: 'QrCodeRepository');
          throw Exception('Error: ID de textura inválido');
        }
      } else {
        dev.log('Error: resultado no es un Map: $result (${result.runtimeType})', name: 'QrCodeRepository');
        throw Exception('Error: formato de respuesta inválido');
      }
    } on PlatformException catch (e) {
      dev.log('Error al iniciar escáner de QR: ${e.message}', name: 'QrCodeRepository', error: e);
      throw Exception('Error al iniciar el escáner de QR: ${e.message}');
    } catch (e) {
      dev.log('Error inesperado al iniciar escáner de QR: $e', name: 'QrCodeRepository', error: e);
      throw Exception('Error inesperado al iniciar el escáner de QR: $e');
    }
  }

  @override
  Future<void> stopQrScanner() async {
    dev.log('Deteniendo escáner de QR', name: 'QrCodeRepository');
    try {
      await _channel.invokeMethod('stopScan');
      _cameraTextureId = null;
      dev.log('Escáner de QR detenido correctamente', name: 'QrCodeRepository');
    } on PlatformException catch (e) {
      dev.log('Error al detener escáner de QR: ${e.message}', name: 'QrCodeRepository', error: e);
      // No lanzamos excepción aquí para no afectar al flujo de la aplicación
    }
  }

  int? get cameraTextureId => _cameraTextureId;

  void dispose() {
    _qrCodeCtr.close();
  }
}