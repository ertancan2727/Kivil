import 'package:flutter/material.dart';

/// Kıvıl marka renkleri — kullanıcının tasarım referansına göre:
/// koyu/siyaha yakın zemin + pembe-turuncu-altın alev gradyanı.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color textPrimary = Color(0xFFF5EDE6);
  static const Color textMuted = Color(0xFFB8ADA6);
  static const Color textGold = Color(0xFFE6C185);

  static const List<Color> flameGradient = [
    Color(0xFFFFC857), // altın
    Color(0xFFFF7A45), // turuncu
    Color(0xFFE0245E), // pembe-kırmızı
  ];

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF7A45), Color(0xFFE0245E)],
  );

  /// "#RRGGBB" -> Color. Geçersiz girişte [textGold]'a düşer.
  static Color fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null || cleaned.length != 6) return textGold;
    return Color(0xFF000000 | value);
  }
}
