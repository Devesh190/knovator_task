import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:knovator_task/provider/portfolio_provider.dart';
import 'package:knovator_task/repo/coin_repository.dart';
import 'package:knovator_task/repo/portfolio_repository.dart';
import 'package:knovator_task/screen/splash_screen.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'core/object_box.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final objectBox = await ObjectBox.create();
  getIt.registerSingleton<ObjectBox>(objectBox);

  getIt.registerLazySingleton<ApiService>(() => ApiService());

  getIt.registerLazySingleton<CoinRepository>(
        () => CoinRepository(objectBox, getIt<ApiService>()),
  );
  getIt.registerLazySingleton<PortfolioRepository>(
        () => PortfolioRepository(objectBox),
  );
  getIt.registerFactory<PortfolioProvider>(() => PortfolioProvider(
    getIt<CoinRepository>(),
    getIt<PortfolioRepository>(),
  ));
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioProvider>(
          create: (_) => getIt<PortfolioProvider>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crypto Portfolio',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const SplashScreen(),
      ),
    );
  }
}

