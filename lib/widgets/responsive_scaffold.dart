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
    // Bloqueo INMEDIATO de orientación antes de que se renderice la UI
    _lockInitialOrientation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  Future<void> _lockInitialOrientation() async {
    // 1. Bloqueo TEMPORAL la orientación actual inmediatamente
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // 2. Determino el tipo de dispositivo SIN usar MediaQuery
    final physicalSize = WidgetsBinding.instance.window.physicalSize;
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final shortestSide = physicalSize.shortestSide / devicePixelRatio;

    bool isTablet;
    if (Platform.isAndroid) {
      // Regla mejorada para Samsung
      isTablet = shortestSide >= 600 || 
                (physicalSize.width >= 2000 && physicalSize.height >= 2000);
    } else {
      isTablet = shortestSide >= 600;
    }

    // 3. Aplico la orientación definitiva
    if (!isTablet) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

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