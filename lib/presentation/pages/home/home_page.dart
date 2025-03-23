import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jams_flutter_swift/core/helpers/statics/var_routers.dart';
import 'package:jams_flutter_swift/core/helpers/statics/var_styles.dart';

import '../../bloc/qr_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadQrCodes();
  }

  void _loadQrCodes() {
    context.read<QrBloc>().add(LoadQrCodes());
  }

  void _navigateToScannerPage() {
    context.push('${VarRouters.home.path}/${VarRouters.scan.path}');
  }

  void _deleteQrCode(int id) {
    context.read<QrBloc>().add(DeleteQrCode(id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App QR Code'),
        centerTitle: true,
      ),
      body: BlocBuilder<QrBloc, QrState>(
        builder: (context, state) {
          developer.log('ESTADO: $state', name: 'HOME WIDGET');
          if (state is QrLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QrCodesLoaded) {
            if (state.qrCodes.isEmpty) {
              return const Center(
                child: Text(
                  'No hay códigos QR escaneados.\nEmpieza escaneando uno!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: Text('Listado de Códigos QR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
                      GestureDetector(
                        onTap: _navigateToScannerPage,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: VarStyles.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.qr_code,
                            color: Colors.white,
                            size: 20,
                          )
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.qrCodes.length,
                    itemBuilder: (context, index) {
                      final qrCode = state.qrCodes[index];
                      
                      return Card(
                        elevation: 5.0,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            qrCode.code,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            context.push('${VarRouters.home.path}/${VarRouters.detail.path}', extra: qrCode);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red,),
                            onPressed: () => _deleteQrCode(qrCode.id!),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is QrError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          return const Center(child: Text('Comienza a escanear códigos QR'));
        },
      ),
    );
  }
}