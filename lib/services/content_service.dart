import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/category.dart';
import '../models/content_item.dart';

class ContentService {
  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/content/categories'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Backend'e ulaşılamıyorsa boş liste dön, ekran boş kategori göstermeyi yönetir.
    }
    return [];
  }

  static Future<List<ContentItem>> fetchContent({int? categoryId}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/content').replace(
        queryParameters: categoryId != null ? {'categoryId': '$categoryId'} : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.map((e) => ContentItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Backend'e ulaşılamıyorsa boş liste dön.
    }
    return [];
  }
}
