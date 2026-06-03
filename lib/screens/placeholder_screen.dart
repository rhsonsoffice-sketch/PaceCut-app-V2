import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: appColors.cardSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: AppTheme.iconXl, color: colors.primary),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(title, style: text.titleLarge),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                description,
                style: text.bodyMedium?.copyWith(color: appColors.subtleText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
