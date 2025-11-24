import '../entities/food.dart';

abstract class FoodRepository {
  Future<List<Food>> getAllFoods();
}

