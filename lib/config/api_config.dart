import 'package:flutter/foundation.dart';

/// Backend adresi.
///
/// - Android emülatöründe `localhost` emülatörün kendisini işaret eder,
///   bilgisayarı değil — bu yüzden Google'ın ayırdığı özel adres 10.0.2.2
///   kullanılır (Android emülatörden host makineye giden sabit yol).
/// - Web / iOS simülatör / Windows masaüstünde localhost olduğu gibi çalışır.
/// - Gerçek telefondan test ederken: bilgisayarınızın yerel ağ IP'sini
///   (örn. 192.168.x.x) yazmanız gerekir, ikisi de aynı Wi-Fi'da olmalı.
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5299';
    }
    return 'http://localhost:5299';
  }
}
