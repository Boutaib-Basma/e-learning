class Category {
  final int id;
  final String categoryName;
  final String imageCategory;

  Category({
    required this.id,
    required this.categoryName,
    required this.imageCategory,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      categoryName: json['categoryName'] as String,
      imageCategory: json['imageCategory'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'imageCategory': imageCategory,
    };
  }

  @override
  String toString() =>
      'Category(id: $id, categoryName: $categoryName, imageCategory: $imageCategory)';
}
