class Category {
  const Category({required this.id, required this.name, this.iconUrl});

  final int id;
  final String name;
  final String? iconUrl;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String?,
    );
  }
}
