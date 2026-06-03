import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class ComplianceLinks extends StatelessWidget {
  const ComplianceLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppTheme.spacingMd,
        runSpacing: AppTheme.spacingSm,
        children: [
          _ComplianceLink(label: 'Privacy Policy', appColors: appColors, text: text),
          _Dot(appColors: appColors),
          _ComplianceLink(label: 'Terms of Service', appColors: appColors, text: text),
          _Dot(appColors: appColors),
          _ComplianceLink(label: 'Support', appColors: appColors, text: text),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AppColorsExtension appColors;

  const _Dot({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Text('·', style: TextStyle(color: appColors.subtleText, fontSize: 14));
  }
}

class _ComplianceLink extends StatelessWidget {
  final String label;
  final AppColorsExtension appColors;
  final TextTheme text;

  const _ComplianceLink({
    required this.label,
    required this.appColors,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label,
        style: text.labelSmall?.copyWith(
          color: appColors.subtleText,
          decoration: TextDecoration.underline,
          decorationColor: appColors.subtleText,
        ),
      ),
    );
  }
}
