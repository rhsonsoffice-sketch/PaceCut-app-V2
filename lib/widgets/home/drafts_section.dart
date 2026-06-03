import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/drafts_provider.dart';
import '../../models/draft_model.dart';

class DraftsSection extends StatelessWidget {
  const DraftsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Consumer<DraftsProvider>(
      builder: (context, draftsProvider, _) {
        final drafts = draftsProvider.drafts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Drafts', style: text.titleMedium),
                Text(
                  'See All',
                  style: text.labelMedium?.copyWith(color: colors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // ── Draft list ─────────────────────────────────────────────────
            if (drafts.isEmpty)
              _EmptyDrafts()
            else
              ...drafts.take(5).toList().asMap().entries.map((entry) {
                final idx = entry.key;
                final draft = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: idx < drafts.take(5).length - 1
                        ? AppTheme.spacingMd
                        : 0,
                  ),
                  child: _DraftCard(draft: draft),
                );
              }),
          ],
        );
      },
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyDrafts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingXl,
        horizontal: AppTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: appColors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: appColors.subtleText.withOpacity(0.15),
          width: AppTheme.borderDefault,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.video_library_outlined,
            color: appColors.subtleText,
            size: AppTheme.iconXl,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No drafts yet',
            style: text.titleSmall?.copyWith(color: appColors.subtleText),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Import a video to create your first project',
            style: text.bodySmall?.copyWith(color: appColors.subtleText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Draft card ─────────────────────────────────────────────────────────────

class _DraftCard extends StatefulWidget {
  final DraftProject draft;

  const _DraftCard({required this.draft});

  @override
  State<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<_DraftCard> {
  bool _pressed = false;
  bool _menuOpen = false;

  DraftProject get _d => widget.draft;

  /// Determines the thumbnail gradient based on the draft's preset.
  List<Color> _gradientColors(AppColorsExtension appColors) {
    switch (_d.preset) {
      case 'viral_fast_cut':
        return [appColors.accentGradientEnd, appColors.accentGradientStart];
      case 'retention_booster':
        return [const Color(0xFF7B2FBE), const Color(0xFFE040FB)];
      case 'dialogue_punch_up':
        return [const Color(0xFFE91E8C), const Color(0xFFFF6B35)];
      default:
        return [const Color(0xFF3B82F6), const Color(0xFF06B6D4)];
    }
  }

  void _openStudio(BuildContext context) {
    HapticFeedback.selectionClick();
    context.push('/studio/edit', extra: {
      'title': _d.title,
      'duration': _d.duration,
      'subtitle': _d.subtitle,
      // Restore the exact video file and pacing preset that were saved with
      // this draft so the Studio timeline and player load the right state.
      'videoPath': _d.videoPath,
      'preset': _d.preset,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => _openStudio(context),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: colors.outline,
              width: AppTheme.borderDefault,
            ),
          ),
          child: Row(
            children: [
              // ── Thumbnail ──────────────────────────────────────────────
              _Thumbnail(
                duration: _d.duration,
                gradientColors: _gradientColors(appColors),
                colors: colors,
                text: text,
              ),
              const SizedBox(width: AppTheme.spacingMd),

              // ── Text info ──────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _d.title,
                      style: text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      _d.subtitle,
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_d.videoPath != null) ...[
                      const SizedBox(height: AppTheme.spacingXs),
                      _VideoPathChip(appColors: appColors, text: text),
                    ],
                  ],
                ),
              ),

              // ── Context menu ───────────────────────────────────────────
              GestureDetector(
                onTap: () => _showDraftMenu(context),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: appColors.subtleText,
                  size: AppTheme.iconMd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDraftMenu(BuildContext context) {
    if (_menuOpen) return;
    setState(() => _menuOpen = true);
    HapticFeedback.lightImpact();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DraftMenuSheet(
        draft: _d,
        onOpen: () => _openStudio(context),
        onDelete: () {
          context.read<DraftsProvider>().removeDraft(_d.id);
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _menuOpen = false);
    });
  }
}

// ── Thumbnail ──────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String duration;
  final List<Color> gradientColors;
  final ColorScheme colors;
  final TextTheme text;

  const _Thumbnail({
    required this.duration,
    required this.gradientColors,
    required this.colors,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: colors.onPrimary.withOpacity(0.8),
              size: AppTheme.iconLg,
            ),
          ),
          Positioned(
            right: AppTheme.spacingXs,
            bottom: AppTheme.spacingXs,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.75),
                borderRadius: BorderRadius.circular(AppTheme.spacingXs),
              ),
              child: Text(
                duration,
                style: text.labelSmall?.copyWith(
                  fontSize: 9,
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Video-path chip (shown when a real file is attached to the draft) ──────

class _VideoPathChip extends StatelessWidget {
  final AppColorsExtension appColors;
  final TextTheme text;

  const _VideoPathChip({required this.appColors, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.link_rounded,
          size: 11,
          color: appColors.accentGradientStart,
        ),
        const SizedBox(width: 3),
        Text(
          'Video attached',
          style: text.labelSmall?.copyWith(
            fontSize: 10,
            color: appColors.accentGradientStart,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Draft context-menu bottom sheet ───────────────────────────────────────

class _DraftMenuSheet extends StatelessWidget {
  final DraftProject draft;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _DraftMenuSheet({
    required this.draft,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: appColors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: colors.outline,
          width: AppTheme.borderDefault,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: appColors.subtleText.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Text(
              draft.title,
              style: text.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _SheetOption(
            icon: Icons.edit_rounded,
            label: 'Open in Studio',
            color: colors.primary,
            onTap: () {
              Navigator.of(context).pop();
              onOpen();
            },
          ),
          _SheetOption(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Draft',
            color: colors.error,
            onTap: () {
              Navigator.of(context).pop();
              onDelete();
            },
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }
}

class _SheetOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SheetOption> createState() => _SheetOptionState();
}

class _SheetOptionState extends State<_SheetOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed
            ? appColors.subtleText.withOpacity(0.08)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: widget.color, size: AppTheme.iconMd),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              widget.label,
              style: text.bodyMedium?.copyWith(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }
}
