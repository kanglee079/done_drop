import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:done_drop/core/errors/result.dart';
import 'package:done_drop/core/services/storage_service.dart';
import 'package:done_drop/features/auth/presentation/controllers/auth_controller.dart';
import 'package:done_drop/features/auth/repositories/user_profile_repository.dart';

const String _sharedMonthlyProductId = String.fromEnvironment(
  'DD_IAP_PREMIUM_MONTHLY',
  defaultValue: 'dd_premium_monthly',
);
const String _sharedYearlyProductId = String.fromEnvironment(
  'DD_IAP_PREMIUM_YEARLY',
  defaultValue: 'dd_premium_yearly',
);
const String _sharedLifetimeProductId = String.fromEnvironment(
  'DD_IAP_PREMIUM_LIFETIME',
  defaultValue: 'dd_premium_lifetime',
);
const String _androidMonthlyProductId = String.fromEnvironment(
  'DD_IAP_ANDROID_PREMIUM_MONTHLY',
  defaultValue: _sharedMonthlyProductId,
);
const String _androidYearlyProductId = String.fromEnvironment(
  'DD_IAP_ANDROID_PREMIUM_YEARLY',
  defaultValue: _sharedYearlyProductId,
);
const String _androidLifetimeProductId = String.fromEnvironment(
  'DD_IAP_ANDROID_PREMIUM_LIFETIME',
  defaultValue: _sharedLifetimeProductId,
);
const String _iosMonthlyProductId = String.fromEnvironment(
  'DD_IAP_IOS_PREMIUM_MONTHLY',
  defaultValue: _sharedMonthlyProductId,
);
const String _iosYearlyProductId = String.fromEnvironment(
  'DD_IAP_IOS_PREMIUM_YEARLY',
  defaultValue: _sharedYearlyProductId,
);
const String _iosLifetimeProductId = String.fromEnvironment(
  'DD_IAP_IOS_PREMIUM_LIFETIME',
  defaultValue: _sharedLifetimeProductId,
);

enum PremiumProductKind { monthly, yearly, lifetime }

class BillingOffer {
  const BillingOffer({
    required this.kind,
    required this.productDetails,
  });

  final PremiumProductKind kind;
  final ProductDetails productDetails;

  String get id => productDetails.id;
  bool get isSubscription => kind != PremiumProductKind.lifetime;
}

class BillingService extends GetxService {
  BillingService({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance,
      _catalog = _BillingCatalogIds.current();

  final InAppPurchase _inAppPurchase;
  final _BillingCatalogIds _catalog;

  final RxBool storeAvailable = false.obs;
  final RxBool isLoadingCatalog = false.obs;
  final RxBool isRestoring = false.obs;
  final RxnString purchaseInFlightProductId = RxnString();
  final RxnString errorCode = RxnString();
  final RxnString errorMessage = RxnString();
  final RxMap<PremiumProductKind, ProductDetails> _offersByKind =
      <PremiumProductKind, ProductDetails>{}.obs;
  final RxList<String> missingProductIds = <String>[].obs;
  final RxList<String> activeProductIds = <String>[].obs;
  final Map<String, PurchaseDetails> _ownedPurchasesByProductId =
      <String, PurchaseDetails>{};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  StreamSubscription<User?>? _authSubscription;
  bool _initialized = false;

  AuthController? get _authControllerOrNull =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  bool get hasCatalog => _offersByKind.isNotEmpty;
  bool get hasSubscriptionOffer =>
      _offersByKind.containsKey(PremiumProductKind.monthly) ||
      _offersByKind.containsKey(PremiumProductKind.yearly);
  bool get hasLifetimeOffer =>
      _offersByKind.containsKey(PremiumProductKind.lifetime);
  bool get isStoreBillingReady =>
      storeAvailable.value &&
      hasSubscriptionOffer &&
      hasLifetimeOffer &&
      errorCode.value != 'billing_store_unavailable';
  bool get hasPremiumAccess =>
      _isPremiumId(_activeEntitlementProductId) ||
      StorageService.instance.isPremium ||
      (_authControllerOrNull?.userProfile?.premiumStatus ?? false);
  bool get isBusy =>
      isLoadingCatalog.value ||
      isRestoring.value ||
      purchaseInFlightProductId.value != null;

  List<BillingOffer> get offers => PremiumProductKind.values
      .map((kind) {
        final details = _offersByKind[kind];
        if (details == null) return null;
        return BillingOffer(kind: kind, productDetails: details);
      })
      .whereType<BillingOffer>()
      .toList(growable: false);

  ProductDetails? offerForKind(PremiumProductKind kind) => _offersByKind[kind];

  PremiumProductKind? get activeKind => _kindForProductId(
    _activeEntitlementProductId,
  );

  String? get activeSubscriptionProductId {
    final kind = activeKind;
    if (kind == PremiumProductKind.monthly || kind == PremiumProductKind.yearly) {
      return _activeEntitlementProductId;
    }
    return null;
  }

  String? get _activeEntitlementProductId {
    final ids = activeProductIds.toSet();
    if (ids.contains(_catalog.lifetime)) return _catalog.lifetime;
    if (ids.contains(_catalog.yearly)) return _catalog.yearly;
    if (ids.contains(_catalog.monthly)) return _catalog.monthly;
    return null;
  }

  bool isOfferActive(PremiumProductKind kind) =>
      _activeEntitlementProductId == _catalog.idFor(kind);

  bool isOfferPurchasing(PremiumProductKind kind) =>
      purchaseInFlightProductId.value == _catalog.idFor(kind);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    activeProductIds.assignAll(
      StorageService.instance.getStringList('premium_active_product_ids') ??
          const <String>[],
    );

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        _setError(
          code: 'billing_purchase_stream_error',
          message: error.toString(),
        );
      },
    );

    if (_isApplePlatform) {
      final iosAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosAddition.setDelegate(_BillingQueueDelegate());
    }

    final authController = _authControllerOrNull;
    if (authController != null) {
      _authSubscription = authController.authStateStream.listen((user) {
        if (user == null) {
          _ownedPurchasesByProductId.clear();
          activeProductIds.clear();
          purchaseInFlightProductId.value = null;
          unawaited(StorageService.instance.setPremium(false));
          unawaited(
            StorageService.instance.setStringList(
              'premium_active_product_ids',
              const <String>[],
            ),
          );
          return;
        }
        unawaited(refreshCatalog(triggerRestore: true));
      });
    }

    await refreshCatalog(
      triggerRestore: authController?.firebaseUser != null,
    );
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    _authSubscription?.cancel();
    if (_isApplePlatform) {
      final iosAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      unawaited(iosAddition.setDelegate(null));
    }
    super.onClose();
  }

  Future<void> refreshCatalog({bool triggerRestore = false}) async {
    if (kIsWeb) {
      storeAvailable.value = false;
      _setError(
        code: 'billing_store_unavailable',
        message: 'In-app purchases are only available on Android and iOS.',
      );
      return;
    }

    isLoadingCatalog.value = true;
    _clearError();

    try {
      final available = await _inAppPurchase.isAvailable();
      storeAvailable.value = available;
      if (!available) {
        _offersByKind.clear();
        missingProductIds.clear();
        _setError(
          code: 'billing_store_unavailable',
          message:
              'The app could not connect to the store. Check the current build, logged-in store account, and tester setup.',
        );
        return;
      }

      final response = await _inAppPurchase.queryProductDetails(
        _catalog.productIds,
      );
      missingProductIds.assignAll(response.notFoundIDs);
      _offersByKind.assignAll(_resolveOfferMap(response.productDetails));

      if (response.error != null) {
        _setError(
          code: response.error!.code,
          message: response.error!.message,
        );
      } else if (_offersByKind.isEmpty) {
        _setError(
          code: 'billing_products_not_found',
          message:
              'No store products were returned. Create the products in the store and publish them to an internal testing track first.',
        );
      }

      if (triggerRestore) {
        await restorePurchases();
      }
    } catch (error) {
      _setError(code: 'billing_catalog_unexpected', message: error.toString());
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  Future<bool> purchase(PremiumProductKind kind) async {
    final productDetails = offerForKind(kind);
    final userId = _authControllerOrNull?.firebaseUser?.uid;
    if (productDetails == null) {
      _setError(
        code: 'billing_product_unavailable',
        message: 'This plan is not available in the current store catalog yet.',
      );
      return false;
    }

    if (!storeAvailable.value) {
      await refreshCatalog(triggerRestore: false);
      if (!storeAvailable.value) {
        return false;
      }
    }

    purchaseInFlightProductId.value = productDetails.id;
    _clearError();

    try {
      final purchaseParam = _buildPurchaseParam(
        productDetails: productDetails,
        applicationUserName: userId,
      );
      return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (error) {
      purchaseInFlightProductId.value = null;
      _setError(code: 'billing_purchase_unexpected', message: error.toString());
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (kIsWeb) return;

    final userId = _authControllerOrNull?.firebaseUser?.uid;
    isRestoring.value = true;
    _clearError();

    try {
      if (_isAndroid) {
        final androidAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final response = await androidAddition.queryPastPurchases(
          applicationUserName: userId,
        );
        if (response.error != null) {
          _setError(
            code: response.error!.code,
            message: response.error!.message,
          );
        } else {
          await _applyOwnedPurchases(
            response.pastPurchases,
            replaceExisting: true,
          );
        }
      } else {
        await _inAppPurchase.restorePurchases(applicationUserName: userId);
      }
    } catch (error) {
      _setError(code: 'billing_restore_unexpected', message: error.toString());
    } finally {
      isRestoring.value = false;
    }
  }

  Future<bool> openManageSubscription() async {
    final activeSubscriptionId = activeSubscriptionProductId;
    if (activeSubscriptionId == null) {
      return false;
    }

    final uri = _isAndroid
        ? Uri.parse(
            'https://play.google.com/store/account/subscriptions?sku=$activeSubscriptionId&package=com.donedrop.app',
          )
        : Uri.parse('https://apps.apple.com/account/subscriptions');

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    if (purchaseDetailsList.isEmpty) return;

    final updatedOwned = activeProductIds.toSet();

    for (final purchase in purchaseDetailsList) {
      if (!_isPremiumId(purchase.productID)) {
        if (purchase.pendingCompletePurchase &&
            purchase.status != PurchaseStatus.pending) {
          await _inAppPurchase.completePurchase(purchase);
        }
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          purchaseInFlightProductId.value = purchase.productID;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _ownedPurchasesByProductId[purchase.productID] = purchase;
          updatedOwned.add(purchase.productID);
          purchaseInFlightProductId.value = null;
          break;
        case PurchaseStatus.canceled:
          purchaseInFlightProductId.value = null;
          _setError(
            code: 'billing_purchase_cancelled',
            message: 'The store purchase was cancelled.',
          );
          break;
        case PurchaseStatus.error:
          purchaseInFlightProductId.value = null;
          _setError(
            code: purchase.error?.code ?? 'billing_purchase_error',
            message:
                purchase.error?.message ??
                'The store could not complete the purchase.',
          );
          break;
      }

      if (purchase.pendingCompletePurchase &&
          purchase.status != PurchaseStatus.pending) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }

    await _applyOwnedPurchases(
      purchaseDetailsList,
      replaceExisting: false,
      seedOwned: updatedOwned,
    );
  }

  Future<void> _applyOwnedPurchases(
    List<PurchaseDetails> purchases, {
    required bool replaceExisting,
    Set<String>? seedOwned,
  }) async {
    final nextOwned = replaceExisting
        ? <String>{}
        : (seedOwned ?? activeProductIds.toSet());

    if (replaceExisting) {
      _ownedPurchasesByProductId.clear();
    }

    for (final purchase in purchases) {
      if (!_isPremiumId(purchase.productID)) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _ownedPurchasesByProductId[purchase.productID] = purchase;
        nextOwned.add(purchase.productID);
      }
    }

    activeProductIds.assignAll(
      nextOwned.toList()..sort((a, b) => a.compareTo(b)),
    );
    await StorageService.instance.setPremium(nextOwned.isNotEmpty);
    await StorageService.instance.setStringList(
      'premium_active_product_ids',
      activeProductIds.toList(growable: false),
    );
    await _syncPremiumStatus(nextOwned.isNotEmpty);
  }

  Future<void> _syncPremiumStatus(bool isPremium) async {
    final auth = _authControllerOrNull;
    if (auth == null) return;
    final user = auth.firebaseUser;
    if (user == null) return;

    var profile = auth.userProfile;
    profile ??= await auth.ensureCurrentUserProfile();
    if (profile == null || profile.premiumStatus == isPremium) {
      return;
    }

    final updated = profile.copyWith(premiumStatus: isPremium);
    final result = await Get.find<UserProfileRepository>().updateUserProfile(
      updated,
    );
    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) {
        _setError(
          code: 'billing_profile_sync_failed',
          message: failure.message,
        );
      },
    );
  }

  Map<PremiumProductKind, ProductDetails> _resolveOfferMap(
    List<ProductDetails> productDetails,
  ) {
    final resolved = <PremiumProductKind, ProductDetails>{};
    for (final details in productDetails) {
      final kind = _kindForProductId(details.id);
      if (kind == null) continue;
      final existing = resolved[kind];
      if (existing == null || details.rawPrice < existing.rawPrice) {
        resolved[kind] = details;
      }
    }
    return resolved;
  }

  PurchaseParam _buildPurchaseParam({
    required ProductDetails productDetails,
    required String? applicationUserName,
  }) {
    if (_isAndroid && productDetails is GooglePlayProductDetails) {
      final oldSubscription = _findOldSubscription(productDetails);
      return GooglePlayPurchaseParam(
        productDetails: productDetails,
        applicationUserName: applicationUserName,
        changeSubscriptionParam: oldSubscription == null
            ? null
            : ChangeSubscriptionParam(
                oldPurchaseDetails: oldSubscription,
                replacementMode: ReplacementMode.withTimeProration,
              ),
      );
    }

    return PurchaseParam(
      productDetails: productDetails,
      applicationUserName: applicationUserName,
    );
  }

  GooglePlayPurchaseDetails? _findOldSubscription(
    GooglePlayProductDetails productDetails,
  ) {
    final targetKind = _kindForProductId(productDetails.id);
    if (targetKind == null || targetKind == PremiumProductKind.lifetime) {
      return null;
    }

    final activeId = activeSubscriptionProductId;
    if (activeId == null || activeId == productDetails.id) {
      return null;
    }

    final purchase = _ownedPurchasesByProductId[activeId];
    if (purchase is GooglePlayPurchaseDetails) {
      return purchase;
    }
    return null;
  }

  PremiumProductKind? _kindForProductId(String? productId) {
    if (productId == null || productId.isEmpty) return null;
    if (productId == _catalog.monthly) return PremiumProductKind.monthly;
    if (productId == _catalog.yearly) return PremiumProductKind.yearly;
    if (productId == _catalog.lifetime) return PremiumProductKind.lifetime;
    return null;
  }

  bool _isPremiumId(String? productId) => _kindForProductId(productId) != null;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _isApplePlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  void _setError({required String code, required String message}) {
    errorCode.value = code;
    errorMessage.value = message;
  }

  void _clearError() {
    errorCode.value = null;
    errorMessage.value = null;
  }
}

class _BillingCatalogIds {
  const _BillingCatalogIds({
    required this.monthly,
    required this.yearly,
    required this.lifetime,
  });

  factory _BillingCatalogIds.current() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return const _BillingCatalogIds(
        monthly: _iosMonthlyProductId,
        yearly: _iosYearlyProductId,
        lifetime: _iosLifetimeProductId,
      );
    }

    return const _BillingCatalogIds(
      monthly: _androidMonthlyProductId,
      yearly: _androidYearlyProductId,
      lifetime: _androidLifetimeProductId,
    );
  }

  final String monthly;
  final String yearly;
  final String lifetime;

  Set<String> get productIds => <String>{monthly, yearly, lifetime};

  String idFor(PremiumProductKind kind) => switch (kind) {
    PremiumProductKind.monthly => monthly,
    PremiumProductKind.yearly => yearly,
    PremiumProductKind.lifetime => lifetime,
  };
}

class _BillingQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() => false;
}
