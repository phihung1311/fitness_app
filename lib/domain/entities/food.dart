class Food {
  final int id;
  final String name;
  final double calories100g;
  final double? protein100g;
  final double? carbs100g;
  final double? fat100g;
  final String? mealType;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Food({
    required this.id,
    required this.name,
    required this.calories100g,
    this.protein100g,
    this.carbs100g,
    this.fat100g,
    this.mealType,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Food && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

