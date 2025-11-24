import 'food.dart';

class UserMeal {
  final int id;
  final int userId;
  final int? foodId;
  final String? mealSession; // breakfast, lunch, dinner, snack
  final int? weightGrams;
  final int? calories;
  final DateTime? mealDate;
  final DateTime createdAt;
  final Food? food; // Relation

  const UserMeal({
    required this.id,
    required this.userId,
    this.foodId,
    this.mealSession,
    this.weightGrams,
    this.calories,
    this.mealDate,
    required this.createdAt,
    this.food,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserMeal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

