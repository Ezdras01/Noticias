import 'package:flutter/material.dart';
import 'home_phone.dart';
import 'home_tablet_vertical.dart';
import 'home_tablet_horizontal.dart';
import 'home_desktop.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    
    // Es una tablet si el lado más corto es mayor o igual a 600 px y menor a 900 px
    final isTablet = shortestSide >= 600 && shortestSide < 900;
    
    // Es desktop si el lado más corto es mayor o igual a 900 px
    final isDesktop = shortestSide >= 900;
    
    // Determina si la orientación es vertical o horizontal
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Si no es tablet ni desktop, entonces es phone
    if (!isTablet && !isDesktop) {
      return const HomePhone();
      
    // Si es una tablet y está en modo vertical
    } else if (isTablet && isPortrait) {
      return const HomeTabletVertical();
      
    // Si es una tablet y está en modo horizontal
    } else if (isTablet && !isPortrait) {
      return const HomeTabletHorizontal();
      
    // Para todo lo demás, se asume que es desktop
    } else {
      return const HomeDesktop();
    }
  }
}
