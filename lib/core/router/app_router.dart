import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jams_flutter_swift/core/helpers/models/qr_code_model.dart';
import 'package:jams_flutter_swift/core/helpers/statics/var_routers.dart';
import 'package:jams_flutter_swift/presentation/pages/login_page.dart';

import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/home/qr_detail_page.dart';
import '../../presentation/pages/home/qr_result_page.dart';
import '../../presentation/pages/home/qr_scanner_page.dart';
import '../../presentation/pages/splash_page.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: VarRouters.splash.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: VarRouters.splash.path,
        name: VarRouters.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: VarRouters.login.path,
        name: VarRouters.login.name,
        builder: (context, state) {
          // Obtener parámetros de query si existen
          final isBiometricAvailable = state.uri.queryParameters['biometric'] == 'true';
          return LoginPage(isBiometricAvailable: isBiometricAvailable);
        },
      ),
      GoRoute(
        path: VarRouters.home.path,
        name: VarRouters.home.name,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: VarRouters.scan.path,
            name: VarRouters.scan.name,
            builder: (context, state) => const QrScannerPage(),
          ),
          GoRoute(
            path: VarRouters.detail.path,
            name: VarRouters.detail.name,
            builder: (context, state) {
              // Obtener el QR code de los parámetros extras
              final qrCode = state.extra as QrCodeModel?;
              if (qrCode == null) {
                // Si no hay QR code, redirigir a home
                return const HomePage();
              }
              return QrDetailPage(qrCode: qrCode);
            },
          ),
          GoRoute(
            path: VarRouters.result.path,
            name: VarRouters.result.name,
            builder: (context, state) {
              // Obtener el QR code de los parámetros extras
              final qrCode = state.extra as QrCodeModel?;
              if (qrCode == null) {
                // Si no hay QR code, redirigir a home
                return const HomePage();
              }
              return QrResultPage(qrCode: qrCode);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error?.message ?? "Página no encontrada"}'),
      ),
    ),
  );
}