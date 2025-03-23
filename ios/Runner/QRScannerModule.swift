import Flutter
import UIKit
import AVFoundation

class QRScannerModule: NSObject, FlutterPlugin, AVCaptureMetadataOutputObjectsDelegate, FlutterTexture {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.jams797.ios_channel/qr_scanner", binaryMessenger: registrar.messenger())
        let instance = QRScannerModule(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private let registrar: FlutterPluginRegistrar
    private var textureId: Int64 = 0
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var methodChannel: FlutterMethodChannel?
    private var isScanning = false
    
    // Variables para la textura de Flutter
    private var pixelBuffer: CVPixelBuffer?
    private var latestFrameTimestamp = CMTime()
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.methodChannel = FlutterMethodChannel(name: "com.jams797.ios_channel/qr_scanner", binaryMessenger: registrar.messenger())
        super.init()
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startScan":
            startQRScanner(result: result)
        case "stopScan":
            stopQRScanner(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - QR Scanner Implementation
    private func startQRScanner(result: @escaping FlutterResult) {
        // Verificar permisos de cámara primero
        checkCameraPermission { [weak self] hasPermission in
            guard let self = self else { return }
            
            if hasPermission {
                self.setupCaptureSession()
                
                // Registramos la textura en Flutter
                let textureRegistry = self.registrar.textures()
                self.textureId = textureRegistry.register(self)
                
                // Iniciar la sesión de captura en un hilo en segundo plano
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession?.startRunning()
                    self.isScanning = true
                    
                    // Devolver el ID de textura a Flutter
                    DispatchQueue.main.async {
                        result(["textureId": self.textureId])
                    }
                }
            } else {
                result(FlutterError(code: "PERMISSION_ERROR", 
                                  message: "No se han concedido permisos de cámara", 
                                  details: nil))
            }
        }
    }
    
    private func stopQRScanner(result: @escaping FlutterResult) {
        // Detener la sesión de captura en un hilo en segundo plano
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession?.stopRunning()
            self.isScanning = false
            
            DispatchQueue.main.async {
                // Desregistrar la textura
                if self.textureId != 0 {
                    self.registrar.textures().unregisterTexture(self.textureId)
                    self.textureId = 0
                }
                
                self.captureSession = nil
                self.videoOutput = nil
                
                result(true)
            }
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        // Configurar entrada de video
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession?.canAddInput(videoInput) == true {
                captureSession?.addInput(videoInput)
            } else {
                print("No se pudo añadir entrada de video")
                return
            }
            
            // Configurar salida de metadatos para el escaneo de QR
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession?.canAddOutput(metadataOutput) == true {
                captureSession?.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
            } else {
                print("No se pudo añadir salida de metadatos")
                return
            }
            
            // Configurar salida de video para la vista previa
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            if captureSession?.canAddOutput(videoOutput) == true {
                captureSession?.addOutput(videoOutput)
                self.videoOutput = videoOutput
            }
            
        } catch {
            print("Error al configurar la sesión de captura: \(error.localizedDescription)")
        }
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Si ya no estamos escaneando, no procesar más
        if !isScanning { return }
        
        // Buscar códigos QR en los metadatos
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            
            // Detener el escaneo temporalmente para evitar múltiples detecciones
            isScanning = false
            
            // Enviar el código QR detectado a Flutter
            methodChannel?.invokeMethod("onQRCodeDetected", arguments: stringValue)
        }
    }
    
    // MARK: - FlutterTexture Protocol
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        guard let pixelBuffer = pixelBuffer else {
            return nil
        }
        return Unmanaged.passRetained(pixelBuffer)
    }
}

// Extend QRScannerModule para implementar AVCaptureVideoDataOutputSampleBufferDelegate
extension QRScannerModule: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isScanning, let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Actualizamos el buffer de píxeles para la textura
        pixelBuffer = buffer
        
        // Notificamos a Flutter que hay un nuevo frame disponible
        latestFrameTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        registrar.textures().textureFrameAvailable(textureId)
    }
}