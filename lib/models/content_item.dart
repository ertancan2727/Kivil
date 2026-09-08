import 'category.dart';

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.category,
    required this.isNew,
    required this.isPremium,
    this.difficulty,
  });

  final int id;
  final String title;
  final String? imageUrl;
  final Category category;
  final bool isNew;
  final bool isPremium;
  final String? difficulty;

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      isNew: json['isNew'] as bool,
      isPremium: json['isPremium'] as bool,
      difficulty: json['difficulty'] as String?,
    );
  }
}
