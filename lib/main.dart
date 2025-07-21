import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'controllers/theme_controller.dart';
import 'screens/splash/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtenemos el tamaño físico antes de que Flutter dibuje nada
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final logicalSize = view.physicalSize / view.devicePixelRatio;
  final shortestSide = logicalSize.shortestSide;

  final isTablet = shortestSide >= 600 && shortestSide < 1280;

  // 🧭 Establecer orientación ANTES de correr la app
  if (isTablet) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return GetMaterialApp(
      title: 'Noticias Hoy',
      debugShowCheckedModeBanner: false,
      themeMode: themeController.themeMode,
      theme: theme,          // asegúrate que esté definido en app_theme.dart
      darkTheme: darkTheme,
      home: const SplashScreen(),
    );
  }
}
