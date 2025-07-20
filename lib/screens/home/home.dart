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
    // es una tablet si es mayor o igual a 600 px y menor a 900 px
    final isTablet = shortestSide >= 600 && shortestSide < 900;
    // es desktop si es mayor o igual a 900 px
    final isDesktop = shortestSide >= 900;
    // determina si la orientación es vertical o horizontal
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

// si es difrente de tablet y difrente de desktop, entonces es phone
    if (!isTablet && !isDesktop) {
      return const HomePhone();
      // si es una tablet y esta en modo vertical
    } else if (isTablet && isPortrait) {
      return const HomeTabletVertical();
      // si es una tablet y esta en modo horizontal
    } else if (isTablet && !isPortrait) {
      return const HomeTabletHorizontal();
      // para todo lo demás es desktop
    } else {
      return const HomeDesktop();
    }
  }
}
