import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jams_flutter_swift/core/helpers/statics/var_styles.dart';

import 'core/helpers/dbresources/database_helper.dart';
import 'core/helpers/repositories/auth_repository.dart';
import 'core/helpers/repositories/qr_code_repository.dart';
import 'core/router/app_router.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/qr_bloc.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final databaseHelper = DatabaseHelper();
  final authRepository = AuthRepository();
  final qrRepository = QrCodeRepository(databaseHelper);
  
  runApp(MyApp(
    authRepository: authRepository, 
    qrRepository: qrRepository
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final QrCodeRepository qrRepository;

  const MyApp({super.key,
    required this.authRepository, 
    required this.qrRepository
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository),
        ),
        BlocProvider<QrBloc>(
          create: (context) => QrBloc(qrRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'App QR Code',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: VarStyles.primaryColor),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}