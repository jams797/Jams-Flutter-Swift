import Flutter
import UIKit
import AVFoundation


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Registramos los plugins personalizados
    let controller = window?.rootViewController as! FlutterViewController
    
    // Registro de BiometricModule
      BiometricModule.register(with: registrar(forPlugin: "BiometricModule")!)
    
    // Registro de QRScannerModule
      QRScannerModule.register(with: registrar(forPlugin: "QRScannerModule")!)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
