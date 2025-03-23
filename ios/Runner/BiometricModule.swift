import Flutter
import UIKit
import LocalAuthentication

class BiometricModule: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.jams797.ios_channel/biometrics", binaryMessenger: registrar.messenger())
        let instance = BiometricModule()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isBiometricAvailable":
            checkBiometricAvailability(result: result)
        case "authenticateWithBiometrics":
            authenticateWithBiometrics(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func checkBiometricAvailability(result: @escaping FlutterResult) {
        let context = LAContext()
        var error: NSError?
        
        // Comprobamos si el dispositivo puede usar autenticación biométrica
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if canEvaluate {
            result(true)
        } else {
            // Si hay un error, enviamos false
            print("Error en disponibilidad biométrica: \(error?.localizedDescription ?? "desconocido")")
            result(false)
        }
    }
    
    private func authenticateWithBiometrics(result: @escaping FlutterResult) {
        let context = LAContext()
        var error: NSError?
        
        // Verificamos primero si podemos usar biometría
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autentícate para acceder a la aplicación"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        result(true)
                    } else {
                        print("Error de autenticación: \(authenticationError?.localizedDescription ?? "desconocido")")
                        result(false)
                    }
                }
            }
        } else {
            print("No se puede usar autenticación biométrica: \(error?.localizedDescription ?? "desconocido")")
            result(false)
        }
    }
}