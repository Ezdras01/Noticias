import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class ResponsiveScaffold extends StatefulWidget {
  final Widget mobile;
  final Widget tablet;
  final PreferredSizeWidget? appBar;

  const ResponsiveScaffold({
    super.key,
    required this.mobile,
    required this.tablet,
    this.appBar,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> with WidgetsBindingObserver {
  bool? _isTablet;
  bool _orientationLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockInitialOrientation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  Future<void> _lockInitialOrientation() async {
    // 1. Bloqueo temporal inicial
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // 2. Accedemos al tamaño físico de pantalla desde platformDispatcher
    // Esto reemplaza el uso de `window`, que está deprecado desde Flutter 3.7+
    // También evita el uso de `View.of(context)`, que no es válido en initState
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final physicalSize = platformDispatcher.views.first.physicalSize;
    final devicePixelRatio = platformDispatcher.views.first.devicePixelRatio;
    final shortestSide = physicalSize.shortestSide / devicePixelRatio;

    // 3. Detectamos si es tablet (usamos heurística estándar + validación adicional en Android)
    bool isTablet;
    if (Platform.isAndroid) {
      isTablet = shortestSide >= 600 || 
                (physicalSize.width >= 2000 && physicalSize.height >= 2000);
    } else {
      isTablet = shortestSide >= 600;
    }

    // 4. Aplicamos bloqueo de orientación según tipo de dispositivo
    if (!isTablet) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    // 5. Actualizamos estado si el widget sigue montado
    if (mounted) {
      setState(() {
        _isTablet = isTablet;
        _orientationLocked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_orientationLocked || _isTablet == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 6. Aplicamos layout según tipo de dispositivo y orientación actual
    return Scaffold(
      appBar: widget.appBar,
      body: _isTablet!
          ? OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.landscape
                    ? widget.tablet
                    : widget.mobile;
              },
            )
          : widget.mobile,
    );
  }
}