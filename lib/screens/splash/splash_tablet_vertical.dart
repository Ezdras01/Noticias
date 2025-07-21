import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home.dart'; // Asegúrate que esta ruta sea válida

/// Pantalla de splash para tablets en orientación vertical.
/// Muestra una imagen de fondo (Ftab.png) y redirige automáticamente
/// a la pantalla principal (HomeScreen) después de 3 segundos usando GetX.
class SplashTabletVertical extends StatefulWidget {
  const SplashTabletVertical({super.key});

  @override
  State<SplashTabletVertical> createState() => _SplashTabletVerticalState();
}

class _SplashTabletVerticalState extends State<SplashTabletVertical> {
  @override
  void initState() {
    super.initState();

    // Espera 3 segundos y redirige usando GetX
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => const Home());
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
            image: AssetImage('assets/splash/Ftab.png'), // Imagen de fondo para tablet
            fit: BoxFit.cover, // Ajuste completo a pantalla
          ),
        ),
      ),
    );
  }
}
