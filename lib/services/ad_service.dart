import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/app_settings.dart';

/// Geçiş (interstitial) reklamlarını yükler ve gösterir.
///
/// Reklam birimi ID'si backend'deki Ayarlar'dan (AppSettings) gelir —
/// bu servis sadece hangi ID verilirse onunla çalışır, sabit kodlanmış
/// bir ID taşımaz.
class AdService {
  AdService._();

  static InterstitialAd? _interstitialAd;
  static String? _lastAdUnitId;

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  static Future<void> initialize() async {
    if (!isSupportedPlatform) return;
    await MobileAds.instance.initialize();
  }

  static void preload(String adUnitId) {
    if (!isSupportedPlatform) return;
    // Aynı ID zaten yüklü/yükleniyorsa tekrar istek atma.
    if (_lastAdUnitId == adUnitId && _interstitialAd != null) return;

    _lastAdUnitId = adUnitId;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// [settings.adsEnabled] ise platforma uygun reklam birimini önceden yükler.
  /// Uygulama açılır açılmaz (ayarlar backend'den gelmeden, varsayılanla)
  /// çağırıp, gerçek ayarlar gelince tekrar çağırmak reklamın kullanıcı
  /// "Hemen Başla"ya basana kadar hazır olma şansını artırır.
  static void preloadFromSettings(AppSettings settings) {
    if (!settings.adsEnabled) return;
    final adUnitId = defaultTargetPlatform == TargetPlatform.iOS
        ? settings.iosInterstitialAdUnitId
        : settings.androidInterstitialAdUnitId;
    preload(adUnitId);
  }

  /// Yüklüyse reklamı gösterir, kapatıldığında [onComplete]'i çağırır.
  /// Reklam yoksa (yüklenmedi, desteklenmeyen platform vb.) [onComplete]
  /// direkt çağrılır — kullanıcı asla reklam bekleyip kilitlenmez.
  static void showThenContinue(VoidCallback onComplete) {
    final ad = _interstitialAd;
    if (!isSupportedPlatform || ad == null) {
      onComplete();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        if (_lastAdUnitId != null) preload(_lastAdUnitId!);
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        if (_lastAdUnitId != null) preload(_lastAdUnitId!);
        onComplete();
      },
    );
    ad.show();
  }
}
