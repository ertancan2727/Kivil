import 'package:flutter/material.dart';

import 'models/app_settings.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/ad_service.dart';
import 'services/membership_service.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.initialize();
  // Reklamı ayarlar backend'den gelmeden, varsayılanla hemen yüklemeye başla —
  // kullanıcı "Hemen Başla"ya basana kadar hazır olma ihtimalini artırır.
  AdService.preloadFromSettings(AppSettings.fallback);

  runApp(KivilApp(showWelcome: !MembershipService.isVip));
}

class KivilApp extends StatelessWidget {
  const KivilApp({super.key, this.showWelcome = true});

  final bool showWelcome;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kıvıl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: showWelcome ? const WelcomeScreen() : const HomeScreen(),
    );
  }
}
