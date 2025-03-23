import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/helpers/statics/var_routers.dart';
import '../../core/helpers/statics/var_styles.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  final bool isBiometricAvailable;

  const LoginPage({
    Key? key,
    required this.isBiometricAvailable,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _isPinSetup = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    // Verificar si ya hay un PIN configurado
    context.read<AuthBloc>().add(CheckPinStatus());
    
    // Si hay biometría disponible, intentar autenticar automáticamente
    if (widget.isBiometricAvailable) {
      Future.delayed(Duration.zero, () {
        context.read<AuthBloc>().add(AuthenticateWithBiometrics());
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _authenticateWithBiometrics() {
    context.read<AuthBloc>().add(AuthenticateWithBiometrics());
  }

  void _authenticateWithPin() {
    if (_pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu PIN')),
      );
      return;
    }
    
    context.read<AuthBloc>().add(AuthenticateWithPin(_pinController.text));
  }

  void _setPin() {
    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener al menos 4 dígitos')),
      );
      return;
    }
    
    context.read<AuthBloc>().add(SetPin(_pinController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autenticación'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go(VarRouters.home.path);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PinSetStatus) {
            setState(() {
              _isPinSetup = state.isSet;
            });
          } else if (state is PinSetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN configurado')),
            );
            setState(() {
              _isPinSetup = true;
            });
            _pinController.clear();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Image.asset(VarStyles.imageLogo),
                ),
                
                const SizedBox(height: 10),
                
                // Título según el estado
                Text(
                  _isPinSetup 
                    ? 'Inicie sesión con su biometrico' 
                    : 'Configure su PIN de seguridad',
                  style: const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 22),
                
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: _isObscured,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: _isPinSetup ? 'Ingrese su PIN' : 'Crear PIN',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Botón de acción según estado
                ElevatedButton(
                  onPressed: state is AuthLoading 
                      ? null 
                      : _isPinSetup 
                          ? _authenticateWithPin 
                          : _setPin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: state is AuthLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          _isPinSetup ? 'Iniciar Sesión' : 'Configurar PIN Seguridad',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Botón de biometría si está disponible
                if (widget.isBiometricAvailable && _isPinSetup)
                  OutlinedButton.icon(
                    onPressed: 
                        state is AuthLoading ? null : _authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Usar Biometría'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}