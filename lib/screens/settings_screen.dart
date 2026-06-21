import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../widgets/settings/settings_header.dart';
import '../widgets/settings/pro_upgrade_card.dart';
import '../widgets/settings/settings_list.dart';
import '../widgets/settings/settings_legal_links.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: AppTheme.spacingMd),
              SettingsHeader(),
              SizedBox(height: AppTheme.spacingLg),
              ProUpgradeCard(),
              SizedBox(height: AppTheme.spacingMd),
              SettingsLegalLinks(),
              SizedBox(height: AppTheme.spacingLg),
              SettingsList(),
              SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}
