class AppSettings {
  const AppSettings({
    required this.welcomeTagline,
    required this.welcomeTaglineColorHex,
    required this.welcomeTaglineColorHex2,
    this.welcomeBackgroundUrl,
    required this.adsEnabled,
    required this.androidInterstitialAdUnitId,
    required this.iosInterstitialAdUnitId,
  });

  final String welcomeTagline;
  final String welcomeTaglineColorHex;
  final String welcomeTaglineColorHex2;
  final String? welcomeBackgroundUrl;
  final bool adsEnabled;
  final String androidInterstitialAdUnitId;
  final String iosInterstitialAdUnitId;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      welcomeTagline: json['welcomeTagline'] as String,
      welcomeTaglineColorHex: json['welcomeTaglineColorHex'] as String,
      welcomeTaglineColorHex2: json['welcomeTaglineColorHex2'] as String,
      welcomeBackgroundUrl: json['welcomeBackgroundUrl'] as String?,
      adsEnabled: json['adsEnabled'] as bool,
      androidInterstitialAdUnitId: json['androidInterstitialAdUnitId'] as String,
      iosInterstitialAdUnitId: json['iosInterstitialAdUnitId'] as String,
    );
  }

  /// Backend'e ulaşılamazsa kullanılacak varsayılan değerler.
  static const fallback = AppSettings(
    welcomeTagline: 'Her dokunuşta yeni bir sır açığa çıkar.',
    welcomeTaglineColorHex: '#FFC857',
    welcomeTaglineColorHex2: '#E0245E',
    adsEnabled: true,
    androidInterstitialAdUnitId: 'ca-app-pub-3940256099942544/1033173712',
    iosInterstitialAdUnitId: 'ca-app-pub-3940256099942544/4411468910',
  );
}
