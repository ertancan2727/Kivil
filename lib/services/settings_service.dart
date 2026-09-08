import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/app_settings.dart';

class SettingsService {
  static Future<AppSettings> fetch() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/settings'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return AppSettings.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // Backend'e ulaşılamıyorsa sessizce varsayılana düş.
    }
    return AppSettings.fallback;
  }
}
