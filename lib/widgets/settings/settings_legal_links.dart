import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';

/// Always-visible legal links shown on the Settings screen below the upgrade
/// card. Both links are required for App Store compliance and must be visible
/// without any purchase or sign-in gate.
class SettingsLegalLinks extends StatelessWidget {
  const SettingsLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegalTextLink(
          label: 'Privacy Policy',
          url: 'https://forms.gle/smwNZbfTHmYRX9rE8',
          appColors: appColors,
          text: text,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
          child: Text(
            '·',
            style: text.bodySmall?.copyWith(
              color: appColors.subtleText,
              fontSize: 13,
            ),
          ),
        ),
        _LegalTextLink(
          label: 'Terms of Use',
          url: 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
          appColors: appColors,
          text: text,
        ),
      ],
    );
  }
}

class _LegalTextLink extends StatefulWidget {
  final String label;
  final String url;
  final AppColorsExtension appColors;
  final TextTheme text;

  const _LegalTextLink({
    required this.label,
    required this.url,
    required this.appColors,
    required this.text,
  });

  @override
  State<_LegalTextLink> createState() => _LegalTextLinkState();
}

class _LegalTextLinkState extends State<_LegalTextLink> {
  bool _pressed = false;

  Future<void> _launch() async {
    HapticFeedback.selectionClick();
    final uri = Uri.parse(widget.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _launch();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Text(
          widget.label,
          style: widget.text.labelSmall?.copyWith(
            color: widget.appColors.glowPurple,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            decoration: TextDecoration.underline,
            decorationColor: widget.appColors.glowPurple.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
