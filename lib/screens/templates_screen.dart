import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../models/template_preset.dart';
import '../widgets/templates/templates_header.dart';
import '../widgets/templates/template_full_card.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  static const List<_TemplateData> _templates = [
    _TemplateData(
      icon: Icons.bolt_rounded,
      title: 'The 0.8s Hook Master',
      description: 'Rapid intro cuts that grab attention in the first second.',
      duration: '7s',
      tag: 'Trending',
      cutSpeed: '0.8s cuts',
      accentIndex: 0,
      preset: TemplatePreset.hookMaster,
    ),
    _TemplateData(
      icon: Icons.speed_rounded,
      title: 'Vlog Speed-Up',
      description: 'Smooth transitions with high energy and motion blur.',
      duration: '12s',
      tag: 'Popular',
      cutSpeed: '1.2s cuts',
      accentIndex: 1,
      preset: TemplatePreset.vlogSpeedUp,
    ),
    _TemplateData(
      icon: Icons.record_voice_over_rounded,
      title: 'Dialogue Puncher',
      description: 'Auto-zooms for speech segments for max engagement.',
      duration: '15s',
      tag: 'AI-Powered',
      cutSpeed: '0.5s cuts',
      accentIndex: 2,
      preset: TemplatePreset.dialoguePuncher,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppTheme.spacingMd),
                    TemplatesHeader(),
                    SizedBox(height: AppTheme.spacingLg),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final t = _templates[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                      child: TemplateFullCard(
                        icon: t.icon,
                        title: t.title,
                        description: t.description,
                        duration: t.duration,
                        tag: t.tag,
                        cutSpeed: t.cutSpeed,
                        accentIndex: t.accentIndex,
                        preset: t.preset,
                      ),
                    );
                  },
                  childCount: _templates.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.spacingXl),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateData {
  final IconData icon;
  final String title;
  final String description;
  final String duration;
  final String tag;
  final String cutSpeed;
  final int accentIndex;
  final TemplatePreset preset;

  const _TemplateData({
    required this.icon,
    required this.title,
    required this.description,
    required this.duration,
    required this.tag,
    required this.cutSpeed,
    required this.accentIndex,
    required this.preset,
  });
}
