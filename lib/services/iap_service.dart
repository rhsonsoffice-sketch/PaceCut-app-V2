import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Apple-compliant In-App Purchase service using StoreKit (iOS) /
/// Google Play Billing (Android).
///
/// Product IDs must be registered in App Store Connect and Google Play Console
/// before going live. The constants below match what the stores expect.
class IapService {
  // ── Product IDs ────────────────────────────────────────────────────────────
  /// Weekly auto-renewable subscription — £2.99/week.
  /// Matches the live product ID registered in App Store Connect.
  static const String kWeeklyProductId = 'com.primio.pacecutai.pro_weekly';

  /// Monthly auto-renewable subscription — £5.99/month.
  /// Matches the live product ID registered in App Store Connect.
  static const String kMonthlyProductId = 'com.primio.pacecutai.pro_monthly';

  static const Set<String> _productIds = {kWeeklyProductId, kMonthlyProductId};

  // ── Singleton ──────────────────────────────────────────────────────────────
  IapService._();
  static final IapService instance = IapService._();

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Loaded product details from the store.
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => List.unmodifiable(_products);

  /// Callback invoked when a purchase succeeds.
  void Function()? onPurchaseSuccess;

  /// Callback invoked when a purchase fails.
  void Function(String error)? onPurchaseError;

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Call once at app start (or before showing the paywall) to load products
  /// and start listening to the purchase stream.
  ///
  /// On Flutter Web, [InAppPurchasePlatform] is never registered, so we
  /// return immediately to avoid the `LateInitializationError` crash.
  Future<void> init() async {
    if (kIsWeb) return;

    final available = await _iap.isAvailable();
    if (!available) return;

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) {
        onPurchaseError?.call(error.toString());
      },
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (kIsWeb) return;
    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) return;
    _products = response.productDetails;
  }

  /// Clean up the purchase stream listener when no longer needed.
  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }

  // ── Purchase flow ──────────────────────────────────────────────────────────

  /// Initiates a purchase for the given [productId].
  ///
  /// On iOS this triggers the native StoreKit payment sheet.
  /// The outcome is delivered asynchronously via [onPurchaseSuccess] /
  /// [onPurchaseError] callbacks.
  Future<void> buyProduct(String productId) async {
    if (kIsWeb) {
      onPurchaseError?.call('In-App Purchases are not available on web.');
      return;
    }

    final matches = _products.where((p) => p.id == productId).toList();
    if (matches.isEmpty) {
      // Products not yet loaded — attempt a fresh load before giving up.
      await _loadProducts();
      final retry = _products.where((p) => p.id == productId).toList();
      if (retry.isEmpty) {
        onPurchaseError?.call(
          'Product not found. Please check your internet connection and try again.',
        );
        return;
      }
    }

    final product = _products.firstWhere((p) => p.id == productId);
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Restores previous purchases for the current Apple ID / Google account.
  Future<void> restorePurchases() async {
    if (kIsWeb) return;
    await _iap.restorePurchases();
  }

  // ── Internal purchase handler ──────────────────────────────────────────────

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliverPurchase(purchase);
          break;
        case PurchaseStatus.error:
          onPurchaseError?.call(
            purchase.error?.message ?? 'Purchase failed. Please try again.',
          );
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          // User dismissed the native payment sheet — no action needed.
          break;
        case PurchaseStatus.pending:
          // Awaiting parental approval etc. — no action needed.
          break;
      }
    }
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    if (purchase.pendingCompletePurchase) {
      _iap.completePurchase(purchase);
    }
    onPurchaseSuccess?.call();
  }
}
