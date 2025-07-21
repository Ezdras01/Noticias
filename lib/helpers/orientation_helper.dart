import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

Future<void> configureOrientation() async {
  final shortestSide = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.shortestSide /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  final isTablet = shortestSide >= 600 && shortestSide < 900;
  final isDesktop = shortestSide >= 900 || kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  if (!isTablet && !isDesktop) {
    // Celular: bloquear en modo vertical
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  } else {
    // Tablet/Desktop: permitir ambas orientaciones
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
