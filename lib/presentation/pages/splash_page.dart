import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jams_flutter_swift/core/helpers/statics/var_styles.dart';

import '../../core/helpers/statics/var_routers.dart';
import '../bloc/auth_bloc.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Verificar si el dispositivo soporta biometría
      try {
        context.read<AuthBloc>().add(CheckBiometricAvailability());
      } catch (e) {
        developer.log('Error en splash con AuthBloc $e', name: 'SplashPage');
      }
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        
        if (state is BiometricAvailabilityState) {
          developer.log('SplashPage - Biometría disponible: ${state.isAvailable}', name: 'SplashPage');
          context.pushReplacement('${VarRouters.login.path}?biometric=${state.isAvailable}');
        } else if (state is AuthLoading) {
          developer.log('SplashPage - Estado de carga detectado', name: 'SplashPage');
        } else if (state is AuthFailure) {
          developer.log('SplashPage - Error de autenticación: ${state.message}', name: 'SplashPage');
          // Mostrar error y redirigir a AuthPage de todos modos después de un tiempo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LoginPage(isBiometricAvailable: false),
                ),
              );
            }
          });
        } else {
          developer.log('SplashPage - Estado no manejado: ${state.runtimeType}', name: 'SplashPage');
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(35.0),
                child: Image.asset(VarStyles.imageLogo),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              // Añadir indicador de estado de carga
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return Text(
                    'Estado: ${state.runtimeType}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}