import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jams_flutter_swift/core/helpers/statics/var_routers.dart';

import '../../../core/helpers/models/qr_code_model.dart';
import '../../bloc/qr_bloc.dart';

class QrResultPage extends StatelessWidget {
  final QrCodeModel qrCode;

  const QrResultPage({Key? key, required this.qrCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    developer.log('QrResultPage - build', name: 'QrResultPage');
    returnHome() {
      context.read<QrBloc>().add(LoadQrCodes());
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(VarRouters.home.path);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        developer.log(
          'QrResultPage - Botón de retroceso presionado',
          name: 'QrResultPage',
        );

        // Indicar que se debe recargar la lista
        returnHome();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resultado del Escaneo'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              returnHome(); 
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contenido del Código QR:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          qrCode.code,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: qrCode.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contenido copiado al portapapeles'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pushReplacement('${VarRouters.home.path}/${VarRouters.scan.path}');
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Escanear Otro'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
