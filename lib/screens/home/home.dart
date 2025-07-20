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
    final isTablet = shortestSide >= 600 && shortestSide < 900;
    final isDesktop = shortestSide >= 900;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (!isTablet && !isDesktop) {
      return const HomePhone();
    } else if (isTablet && isPortrait) {
      return const HomeTabletVertical();
    } else if (isTablet && !isPortrait) {
      return const HomeTabletHorizontal();
    } else {
      return const HomeDesktop();
    }
  }
}
