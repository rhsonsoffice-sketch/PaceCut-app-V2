import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IapService {
static final IapService instance = IapService._internal();
factory IapService() => instance;
IapService._internal();

final InAppPurchase _iap = InAppPurchase.instance;
bool _isAvailable = false;

// ✅ EXACT PRODUCT IDS — MUST MATCH APP STORE CONNECT
static const String _unlimitedId = 'pacecut_unlimited_499';
static const String _monthlyId = 'pacecut_monthly_299';

// ✅ STATUS CHECKERS
bool get isPremium => _purchasedUnlimited || _purchasedMonthly;
bool get isUnlimitedForever => _purchasedUnlimited;
bool _purchasedUnlimited = false;
bool _purchasedMonthly = false;

Future<void> init() async {
_isAvailable = await _iap.isAvailable();
if (!_isAvailable) return;

// ✅ LOAD SAVED PURCHASE STATUS FROM PHONE
final prefs = await SharedPreferences.getInstance();
_purchasedUnlimited = prefs.getBool('key_unlimited') ?? false;
_purchasedMonthly = prefs.getBool('key_monthly') ?? false;

// ✅ LISTEN FOR PURCHASE / RESTORE UPDATES
_iap.purchaseStream.listen(_handlePurchaseUpdates);
}

Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
for (final purchase in purchases) {
if (purchase.status == PurchaseStatus.purchased ||
purchase.status == PurchaseStatus.restored) {

// ✅ UNLOCK UNLIMITED FOREVER
if (purchase.productID == _unlimitedId) {
_purchasedUnlimited = true;
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('key_unlimited', true);
}

// ✅ UNLOCK MONTHLY
if (purchase.productID == _monthlyId) {
_purchasedMonthly = true;
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('key_monthly', true);
}

// ✅ CRITICAL: MARK TRANSACTION COMPLETE
if (purchase.pendingCompletePurchase) {
await _iap.completePurchase(purchase);
}
}
}
}

// ✅ BUY FUNCTIONS
Future<void> buyUnlimited() async {
if (!_isAvailable) return;
final product = await _getProduct(_unlimitedId);
await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
}

Future<void> buyMonthly() async {
if (!_isAvailable) return;
final product = await _getProduct(_monthlyId);
await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
}

// ✅ RESTORE PURCHASES — FULLY WORKING
Future<void> restorePurchases() async {
await _iap.restorePurchases();
}

// ✅ GET PRODUCT DETAILS FROM APPLE
Future<ProductDetails> _getProduct(String id) async {
final response = await _iap.queryProductDetails({id});
return response.productDetails.first;
}
}


