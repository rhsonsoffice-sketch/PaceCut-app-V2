import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/hero_banner.dart';
import '../widgets/home/create_project_card.dart';
import '../widgets/home/template_grid.dart';
import '../widgets/home/drafts_section.dart';
import '../widgets/home/compliance_links.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              SizedBox(height: AppTheme.spacingSm),
              HomeHeader(),
              SizedBox(height: AppTheme.spacingLg),
              HeroBanner(),
              SizedBox(height: AppTheme.spacingLg),
              CreateProjectCard(),
              SizedBox(height: AppTheme.spacingMd),
              TemplateGrid(),
              SizedBox(height: AppTheme.spacingLg),
              DraftsSection(),
              SizedBox(height: AppTheme.spacingXl),
              ComplianceLinks(),
              SizedBox(height: AppTheme.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}
