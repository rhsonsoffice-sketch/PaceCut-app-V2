import 'package:flutter/material.dart';
import '../../theme/theme.dart';

// ---------------------------------------------------------------------------
// Template Processing Overlay
//
// A barrier-dismissible=false dialog displayed synchronously while FFmpeg
// renders a template. Shows an animated circular progress indicator and
// "Processing video…" label styled to match the app's dark premium aesthetic.
//
// Usage:
//   final overlayContext = await showTemplateProcessingOverlay(context);
//   // ... await FFmpeg work ...
//   Navigator.of(overlayContext, rootNavigator: true).pop();
// ---------------------------------------------------------------------------

/// Shows a full-screen processing modal and returns a [BuildContext] that can
/// be used to dismiss the dialog once processing is complete.
///
/// The returned context is the dialog's own BuildContext captured inside the
/// builder, surfaced via the [Completer] pattern so the caller always gets it
/// even though [showDialog] itself is async.
Future<BuildContext> showTemplateProcessingOverlay(
  BuildContext parentContext,
) async {
  late BuildContext dialogContext;
  final ready = ValueNotifier<bool>(false);

  showDialog<void>(
    context: parentContext,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.72),
    builder: (ctx) {
      dialogContext = ctx;
      // Signal after the first frame so dialogContext is fully assigned
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ready.value = true;
      });
      return const _ProcessingDialog();
    },
  );

  // Wait until the dialog context is available before returning
  await Future.doWhile(() async {
    await Future.delayed(const Duration(milliseconds: 16));
    return !ready.value;
  });

  return dialogContext;
}

class _ProcessingDialog extends StatefulWidget {
  const _ProcessingDialog();

  @override
  State<_ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<_ProcessingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingXl,
            horizontal: AppTheme.spacingLg,
          ),
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: appColors.glowPurple.withOpacity(AppTheme.opacityGlow),
              width: AppTheme.borderDefault,
            ),
            boxShadow: [
              BoxShadow(
                color: appColors.glowPurple.withOpacity(0.28),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing gradient ring around the spinner
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        appColors.accentGradientStart.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        appColors.accentGradientStart,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Processing video…',
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Applying template effects',
                style: text.bodySmall?.copyWith(
                  color: appColors.subtleText,
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
