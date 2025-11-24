import '../../domain/entities/food.dart';

class FoodDto {
  final int id;
  final String name;
  final double calories100g;
  final double? protein100g;
  final double? carbs100g;
  final double? fat100g;
  final String? mealType;
  final String? imageUrl;

  const FoodDto({
    required this.id,
    required this.name,
    required this.calories100g,
    this.protein100g,
    this.carbs100g,
    this.fat100g,
    this.mealType,
    this.imageUrl,
  });

  factory FoodDto.fromJson(Map<String, dynamic> json) {
    return FoodDto(
      id: json['id'] as int,
      name: json['name'] as String,
      calories100g: (json['calories_100g'] as num).toDouble(),
      protein100g: json['protein'] != null 
          ? (json['protein'] as num).toDouble() 
          : null,
      carbs100g: json['carbs'] != null 
          ? (json['carbs'] as num).toDouble() 
          : null,
      fat100g: json['fat'] != null 
          ? (json['fat'] as num).toDouble() 
          : null,
      mealType: json['meal_type'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Food toEntity() {
    return Food(
      id: id,
      name: name,
      calories100g: calories100g,
      protein100g: protein100g,
      carbs100g: carbs100g,
      fat100g: fat100g,
      mealType: mealType,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories_100g': calories100g,
      'protein': protein100g,
      'carbs': carbs100g,
      'fat': fat100g,
      'meal_type': mealType,
      'image_url': imageUrl,
    };
  }
}

