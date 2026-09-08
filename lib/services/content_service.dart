import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/category.dart';
import '../models/content_detail.dart';
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

  static Future<List<ContentItem>> fetchContent({int? categoryId, String? search}) async {
    try {
      final queryParameters = <String, String>{
        if (categoryId != null) 'categoryId': '$categoryId',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      };
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/content')
          .replace(queryParameters: queryParameters.isEmpty ? null : queryParameters);
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

  static Future<ContentDetail?> fetchDetail(int id) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/content/$id'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return ContentDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // Backend'e ulaşılamıyorsa null dön, ekran hata durumunu yönetir.
    }
    return null;
  }
}
