import 'package:flutter/material.dart';

class OrientationHelper {
  /// Devuelve `true` si el dispositivo es una tablet (ancho entre 600 y 1280dp)
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600 && shortestSide < 1280;
  }

  /// Devuelve `true` si el dispositivo es una computadora de escritorio (ancho >= 1280dp)
  static bool isDesktop(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 1280;
  }

  /// Devuelve `true` si el dispositivo está en modo vertical
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Devuelve `true` si el dispositivo está en modo horizontal
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}
