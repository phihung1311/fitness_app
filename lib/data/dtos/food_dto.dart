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
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final normalized = value.replaceAll(',', '.');
        return double.tryParse(normalized);
      }
      return null;
    }

    return FoodDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      calories100g: _parseDouble(json['calories_100g']) ?? 0.0,
      protein100g: _parseDouble(json['protein']),
      carbs100g: _parseDouble(json['carbs']),
      fat100g: _parseDouble(json['fat']),
      mealType: json['meal_type']?.toString() ?? json['category']?.toString(),
      imageUrl: json['image_url']?.toString(),
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

