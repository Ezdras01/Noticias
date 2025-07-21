import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home.dart'; // Asegúrate que esta ruta sea correcta

/// Pantalla de splash para teléfonos móviles.
/// Muestra una imagen de fondo y redirige automáticamente a HomeScreen usando GetX.
class SplashPhone extends StatefulWidget {
  const SplashPhone({super.key});

  @override
  State<SplashPhone> createState() => _SplashPhoneState();
}

class _SplashPhoneState extends State<SplashPhone> {
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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash/Fcel.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
