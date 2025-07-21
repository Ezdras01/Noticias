import 'package:flutter/material.dart';

// Importación de las variantes del splash por tipo de pantalla
import 'splash_phone.dart';
import 'splash_tablet_vertical.dart';
import 'splash_tablet_horizontal.dart';
import 'splash_desktop.dart';

/// Pantalla SplashScreen principal que selecciona qué versión mostrar
/// según el tamaño del dispositivo y su orientación.
///
/// Esta clase no contiene diseño propio, solo enruta a:
/// - SplashPhone
/// - SplashTabletVertical
/// - SplashTabletHorizontal
/// - SplashDesktop
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    // Es tablet si el lado más corto está entre 600 y 899 px
    final isTablet = shortestSide >= 600 && shortestSide < 1600;

    // Es escritorio si el lado más corto es 900 px o más
    final isDesktop = shortestSide >= 1600;

    // Detecta si el dispositivo está en orientación vertical
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Si no es tablet ni desktop, entonces es un teléfono
    if (!isTablet && !isDesktop) {
      return const SplashPhone();

    // Si es tablet en orientación vertical
    } else if (isTablet && isPortrait) {
      return const SplashTabletVertical();

    // Si es tablet en orientación horizontal
    } else if (isTablet && !isPortrait) {
      return const SplashTabletHorizontal();

    // Para todo lo demás se asume escritorio
    } else {
      return const SplashDesktop();
    }
  }
}
