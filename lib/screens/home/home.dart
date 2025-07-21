import 'package:flutter/material.dart';
import 'home_phone.dart';
import 'home_tablet_vertical.dart';
import 'home_tablet_horizontal.dart';
import 'home_desktop.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Widget _selectedLayout;

  @override
  void initState() {
    super.initState();
    _selectedLayout = const SizedBox.shrink(); // pantalla vacía temporal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final orientation = MediaQuery.of(context).orientation;
      final shortestSide = size.shortestSide;

      final isTablet = shortestSide >= 600 && shortestSide < 1600;
      final isDesktop = shortestSide >= 1600;
      final isPortrait = orientation == Orientation.portrait;

      debugPrint('🔍 ---[ DETECCIÓN DE DISPOSITIVO ]---');
      debugPrint('📱 Tamaño pantalla: $size');
      debugPrint('📐 shortestSide: $shortestSide');
      debugPrint('📲 Orientación: $orientation');
      debugPrint('🧩 isTablet: $isTablet');
      debugPrint('🧩 isDesktop: $isDesktop');
      debugPrint('------------------------------------');

      Widget layout;
      if (!isTablet && !isDesktop) {
        layout = const HomePhone();
        debugPrint('✅ MOSTRANDO: HomePhone');
      } else if (isTablet && isPortrait) {
        layout = const HomeTabletVertical();
        debugPrint('✅ MOSTRANDO: HomeTabletVertical');
      } else if (isTablet && !isPortrait) {
        layout = const HomeTabletHorizontal();
        debugPrint('✅ MOSTRANDO: HomeTabletHorizontal');
      } else {
        layout = const HomeDesktop();
        debugPrint('✅ MOSTRANDO: HomeDesktop');
      }

      setState(() {
        _selectedLayout = layout;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _selectedLayout;
  }
}
