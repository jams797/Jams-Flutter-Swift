import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/helpers/statics/var_routers.dart';
import '../../bloc/qr_bloc.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  late final QrBloc _qrBloc;

  @override
  void initState() {
    super.initState();
    developer.log('QrScannerPage - initState', name: 'QrScannerPage');
    // Obtenemos la referencia al bloc aquí para usarla en dispose
    _qrBloc = context.read<QrBloc>();
    _startQrScanner();
  }

  void _startQrScanner() {
    developer.log('Iniciando escáner QR', name: 'QrScannerPage');
    _qrBloc.add(StartQrScan());
  }

  @override
  void dispose() {
    developer.log('QrScannerPage - dispose', name: 'QrScannerPage');
    // Usamos la referencia guardada en initState
    // _qrBloc.add(StopQrScan());
    super.dispose();
  }

  returnHome(){
    _qrBloc.add(LoadQrCodes());
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(VarRouters.home.path);
        }
  }

  @override
  Widget build(BuildContext context) {
    double sizeSquareQr = 250;

    return WillPopScope(
      // Interceptar el botón de regreso para garantizar que los recursos se liberen
      onWillPop: () async {
        developer.log('Botón de retroceso presionado', name: 'QrScannerPage');
        _qrBloc.add(StopQrScan());
        // Esperar un momento para asegurarse de que los recursos se liberan
        await Future.delayed(const Duration(milliseconds: 100));
        // Devolver true para permitir la navegación de retorno
        returnHome();
        
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escanear QR'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              developer.log(
                'Botón de retroceso en AppBar presionado',
                name: 'QrScannerPage',
              );
              _qrBloc.add(StopQrScan());
              // Esperar un momento para asegurarse de que los recursos se liberan
              Future.delayed(const Duration(milliseconds: 100), () {
                returnHome();
              });
            },
          ),
        ),
        body: BlocConsumer<QrBloc, QrState>(
          listener: (context, state) {
            developer.log(
              'Estado del bloc: ${state.runtimeType}',
              name: 'QrScannerPage',
            );

            if (state is QrCodeSaved) {
              // Cuando se detecta y guarda un código QR, ir a la página de resultado
              context.pushReplacement('${VarRouters.home.path}/${VarRouters.result.path}', extra: state.qrCode);
            } else if (state is QrError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            if (state is QrLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QrScanStarted) {
              // Si tenemos un ID de textura, mostrar la vista previa de la cámara
              if (state.textureId != null) {
                return Stack(
                  children: [
                    // Vista previa de la cámara usando Texture
                    Positioned.fill(
                      child: Texture(textureId: state.textureId!),
                    ),
                    // Fondo oscuro
                    _backgroundWidget(sizeSquareQr),
                    // Recuadro de guía para escaneo
                    Center(
                      child: Container(
                        width: sizeSquareQr,
                        height: sizeSquareQr,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Texto informativo
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'Escanee el código QR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset.zero,
                                blurRadius: 4,
                              ),
                            ]
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Si el ID de textura es nulo, mostrar mensaje de error
                return const Center(child: Text('Error al iniciar la cámara'));
              }
            }

            // Estado por defecto
            return const Center(child: Text('Preparando cámara...'));
          },
        ),
      ),
    );
  }

  Widget _backgroundWidget(double sizeSquareQr) {
    Color colorBackground = Colors.black87;
    return Row(
      children: [
        Expanded(
          child: Container(
            color: colorBackground,
          ),
        ),
        SizedBox(
          width: sizeSquareQr,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: colorBackground,
                ),
              ),
              Container(
                width: sizeSquareQr,
                height: sizeSquareQr,
                color: Colors.transparent,
              ),
              Expanded(
                child: Container(
                  color: colorBackground,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: colorBackground,
          ),
        ),
      ],
    );
  }
}
