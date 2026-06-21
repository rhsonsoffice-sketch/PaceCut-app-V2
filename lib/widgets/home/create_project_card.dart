import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/theme.dart';

class CreateProjectCard extends StatefulWidget {
  const CreateProjectCard({super.key});

  @override
  State<CreateProjectCard> createState() => _CreateProjectCardState();
}

class _CreateProjectCardState extends State<CreateProjectCard> {
  bool _pressed = false;
  bool _picking = false;

  Future<void> _pickVideo(BuildContext context) async {
    if (_picking) return;
    HapticFeedback.mediumImpact();

    // FilePicker.platform is not registered on Flutter Web — navigate to the
    // Studio workspace immediately with a demo project so the preview feels
    // instant and fully interactive.
    if (kIsWeb) {
      if (!mounted) return;
      context.push('/studio/edit', extra: {
        'title': 'Demo_Project.mp4',
        'videoPath': null,
      });
      return;
    }

    setState(() => _picking = true);
    try {

      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (!mounted) return;
      final path = result?.files.single.path;
      if (path != null) {
        context.push('/studio/edit', extra: {
          'title': result!.files.single.name,
          'videoPath': path,
        });
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => _pickVideo(context),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          // 20 % larger: spacingLg (24) × 1.2 ≈ 29px
          padding: const EdgeInsets.all(AppTheme.spacingCardLg),
          decoration: BoxDecoration(
            color: AppTheme.brandPurple,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              // primary bright-purple glow
              BoxShadow(
                color: AppTheme.brandPurple.withOpacity(0.55),
                blurRadius: 32,
                spreadRadius: 4,
              ),
              // softer outer halo
              BoxShadow(
                color: AppTheme.brandPurple.withOpacity(0.25),
                blurRadius: 64,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                // 20% larger: 56 × 1.2 = 67px
                width: 67,
                height: 67,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: _picking
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colors.onPrimary,
                        ),
                      )
                    : Icon(Icons.add_rounded, size: AppTheme.iconLg, color: colors.onPrimary),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                _picking ? 'Selecting Video…' : 'Create New Project',
                style: text.titleMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Tap to Import Media (0.0s – 0.8s Automatic Fast Cuts)',
                style: text.bodySmall?.copyWith(
                  color: colors.onPrimary.withOpacity(0.75),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
