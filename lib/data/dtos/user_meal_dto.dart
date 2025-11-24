import '../../domain/entities/user_meal.dart';
import 'food_dto.dart';

class UserMealDto {
  final int id;
  final int userId;
  final int? foodId;
  final String? mealSession;
  final int? weightGrams;
  final int? calories;
  final String? mealDate;
  final String createdAt;
  final FoodDto? food;

  const UserMealDto({
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

  factory UserMealDto.fromJson(Map<String, dynamic> json) {
    return UserMealDto(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      foodId: json['food_id'] as int?,
      mealSession: json['meal_session'] as String?,
      weightGrams: json['weight_grams'] as int?,
      calories: json['calories'] as int?,
      mealDate: json['meal_date'] as String?,
      createdAt: json['created_at'] as String,
      food: json['Food'] != null 
          ? FoodDto.fromJson(json['Food'] as Map<String, dynamic>)
          : null,
    );
  }

  UserMeal toEntity() {
    return UserMeal(
      id: id,
      userId: userId,
      foodId: foodId,
      mealSession: mealSession,
      weightGrams: weightGrams,
      calories: calories,
      mealDate: mealDate != null ? DateTime.parse(mealDate!) : null,
      createdAt: DateTime.parse(createdAt),
      food: food?.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_id': foodId,
      'meal_session': mealSession,
      'weight_grams': weightGrams,
      'calories': calories,
      'meal_date': mealDate,
      'created_at': createdAt,
      if (food != null) 'Food': food!.toJson(),
    };
  }
}

class AddMealRequest {
  final int foodId;
  final String mealSession;
  final int weightGrams;
  final String? mealDate;

  const AddMealRequest({
    required this.foodId,
    required this.mealSession,
    required this.weightGrams,
    this.mealDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'meal_session': mealSession,
      'weight_grams': weightGrams,
      if (mealDate != null) 'meal_date': mealDate,
    };
  }
}

