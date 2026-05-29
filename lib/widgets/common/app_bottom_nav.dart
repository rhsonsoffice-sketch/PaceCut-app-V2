import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';

class ScaffoldWithNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.outlineVariant, width: AppTheme.borderDefault),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingSm),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
              items: [
                _item(Icons.home_rounded, Icons.home_outlined, 'Home', navigationShell.currentIndex == 0, colors, appColors),
                _item(Icons.movie_creation_rounded, Icons.movie_creation_outlined, 'Studio', navigationShell.currentIndex == 1, colors, appColors),
                _item(Icons.dashboard_customize_rounded, Icons.dashboard_customize_outlined, 'Templates', navigationShell.currentIndex == 2, colors, appColors),
                _item(Icons.settings_rounded, Icons.settings_outlined, 'Settings', navigationShell.currentIndex == 3, colors, appColors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _item(
    IconData activeIcon,
    IconData icon,
    String label,
    bool isActive,
    ColorScheme colors,
    AppColorsExtension appColors,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(isActive ? activeIcon : icon),
      label: label,
    );
  }
}
