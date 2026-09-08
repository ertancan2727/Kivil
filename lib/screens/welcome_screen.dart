import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/app_settings.dart';
import '../services/ad_service.dart';
import '../services/membership_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final Future<AppSettings> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = SettingsService.fetch();
    _settingsFuture.then(AdService.preloadFromSettings);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSettings>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        final settings = snapshot.data ?? AppSettings.fallback;
        return _WelcomeScreenBody(settings: settings);
      },
    );
  }
}

class _WelcomeScreenBody extends StatelessWidget {
  const _WelcomeScreenBody({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          settings.welcomeBackgroundUrl != null
              ? Image.network(
                  settings.welcomeBackgroundUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/welcome_bg.png',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/welcome_bg.png',
                  fit: BoxFit.cover,
                ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Zeminin ışıltısından ayrıştırmak için logonun arkasını yumuşakça karart.
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.background.withValues(alpha: 0.8),
                                AppColors.background.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                        // Alev temasıyla uyumlu sıcak bir hale.
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFF7A45).withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/logo.png',
                          width: 260,
                        ),
                      ],
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppColors.flameGradient,
                    ).createShader(bounds),
                    child: Text(
                      'Keşfet. Hisset. Yaşa.',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.fromHex(settings.welcomeTaglineColorHex),
                        AppColors.fromHex(settings.welcomeTaglineColorHex2),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      settings.welcomeTagline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  _PrimaryButton(
                    label: 'Hemen Başla',
                    onPressed: () => _continueFromWelcome(context, settings),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _continueFromWelcome(BuildContext context, AppSettings settings) {
  void goHome() {
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  final shouldShowAd = settings.adsEnabled && !MembershipService.isVip;
  if (shouldShowAd) {
    AdService.showThenContinue(goHome);
  } else {
    goHome();
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
