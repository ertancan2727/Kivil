import 'bundle.dart';
import 'category.dart';

class ContentDetail {
  const ContentDetail({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.category,
    required this.isNew,
    required this.isPremium,
    this.difficulty,
    this.bundle,
  });

  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final Category category;
  final bool isNew;
  final bool isPremium;
  final String? difficulty;
  final Bundle? bundle;

  factory ContentDetail.fromJson(Map<String, dynamic> json) {
    return ContentDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      isNew: json['isNew'] as bool,
      isPremium: json['isPremium'] as bool,
      difficulty: json['difficulty'] as String?,
      bundle: json['bundle'] != null ? Bundle.fromJson(json['bundle'] as Map<String, dynamic>) : null,
    );
  }
}
