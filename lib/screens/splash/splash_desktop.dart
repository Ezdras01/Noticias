import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home.dart'; // Asegúrate que esta ruta sea válida

/// Pantalla de splash para escritorio (desktop).
/// Muestra una imagen de fondo (Fdesktop.jpg) y redirige automáticamente
/// a la pantalla principal (HomeScreen) después de 3 segundos usando GetX.
class SplashDesktop extends StatefulWidget {
  const SplashDesktop({super.key});

  @override
  State<SplashDesktop> createState() => _SplashDesktopState();
}

class _SplashDesktopState extends State<SplashDesktop> {
  @override
  void initState() {
    super.initState();

    // Espera 3 segundos y redirige usando GetX
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => const HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Ocupar toda la pantalla
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash/Fdesktop.jpg'), // Imagen de fondo para desktop
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
