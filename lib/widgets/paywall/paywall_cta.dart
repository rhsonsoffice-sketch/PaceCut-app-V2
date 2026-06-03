import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/session_provider.dart';
import '../../services/iap_service.dart';

class PaywallCta extends StatefulWidget {
  /// Currently selected plan: 0 = Weekly (£1.99), 1 = Monthly (£4.99).
  final int selectedPlan;

  const PaywallCta({super.key, required this.selectedPlan});

  @override
  State<PaywallCta> createState() => _PaywallCtaState();
}

class _PaywallCtaState extends State<PaywallCta>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _processing = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.28, end: 0.52).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wire up real StoreKit callbacks
    IapService.instance.onPurchaseSuccess = _onPurchaseSuccess;
    IapService.instance.onPurchaseError = _onPurchaseError;
  }

  @override
  void dispose() {
    // Remove callbacks so they don't fire after this widget is gone
    IapService.instance.onPurchaseSuccess = null;
    IapService.instance.onPurchaseError = null;
    _pulseController.dispose();
    super.dispose();
  }

  /// Called by [IapService] when StoreKit confirms a successful purchase.
  Future<void> _onPurchaseSuccess() async {
    if (!mounted) return;
    await context.read<SessionProvider>().upgradeToPro();
    if (!mounted) return;

    setState(() => _processing = false);
    HapticFeedback.heavyImpact();
    context.pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '🎉 Welcome to PaceCut PRO! 4K export & watermark removal unlocked.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF9C5FFF),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Called by [IapService] when a purchase fails or is unavailable.
  void _onPurchaseError(String error) {
    if (!mounted) return;
    setState(() => _processing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Initiates a real StoreKit purchase via [IapService].
  Future<void> _handlePurchase() async {
    if (_processing) return;
    setState(() => _processing = true);
    HapticFeedback.mediumImpact();

    final productId = widget.selectedPlan == 0
        ? IapService.kWeeklyProductId
        : IapService.kMonthlyProductId;

    await IapService.instance.buyProduct(productId);
    // Result is delivered asynchronously via onPurchaseSuccess / onPurchaseError.
    // _processing is cleared inside those callbacks.
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pulsing CTA
        GestureDetector(
          onTapDown: (_) {
            setState(() => _pressed = true);
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            _handlePurchase();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) => Container(
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appColors.accentGradientStart,
                      appColors.accentGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.glowPurple.withOpacity(_pulseAnim.value),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
              child: _processing
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: AppTheme.iconMd,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Continue to PRO',
                          style: text.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Subscription notice
        Text(
          'Payment will be charged to your Apple ID account at confirmation. Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.',
          textAlign: TextAlign.center,
          style: text.bodySmall?.copyWith(
            color: appColors.subtleText.withOpacity(0.7),
            fontSize: 10,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Legal fine-print links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RestoreLink(appColors: appColors, text: text),
            _LegalDivider(appColors: appColors),
            _LegalLink(label: 'Terms of Use', appColors: appColors, text: text),
            _LegalDivider(appColors: appColors),
            _LegalLink(label: 'Privacy Policy', appColors: appColors, text: text),
          ],
        ),
      ],
    );
  }
}

// ─── Restore Purchases link ───────────────────────────────────────────────────
// Required by Apple Guideline 3.1.1 — apps with IAP must expose a
// "Restore Purchases" action that calls StoreKit restorePurchases().

class _RestoreLink extends StatefulWidget {
  final AppColorsExtension appColors;
  final TextTheme text;

  const _RestoreLink({required this.appColors, required this.text});

  @override
  State<_RestoreLink> createState() => _RestoreLinkState();
}

class _RestoreLinkState extends State<_RestoreLink> {
  bool _pressed = false;

  Future<void> _restore() async {
    HapticFeedback.selectionClick();
    await IapService.instance.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _restore();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Text(
          'Restore Purchases',
          style: widget.text.labelSmall?.copyWith(
            color: widget.appColors.glowPurple,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            decoration: TextDecoration.underline,
            decorationColor: widget.appColors.glowPurple.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatefulWidget {
  final String label;
  final AppColorsExtension appColors;
  final TextTheme text;

  const _LegalLink({
    required this.label,
    required this.appColors,
    required this.text,
  });

  @override
  State<_LegalLink> createState() => _LegalLinkState();
}

class _LegalLinkState extends State<_LegalLink> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
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
            fontSize: 11,
            decoration: TextDecoration.underline,
            decorationColor: widget.appColors.glowPurple.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _LegalDivider extends StatelessWidget {
  final AppColorsExtension appColors;

  const _LegalDivider({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
      child: Text(
        '·',
        style: TextStyle(
          color: appColors.subtleText,
          fontSize: 12,
        ),
      ),
    );
  }
}
