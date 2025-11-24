import 'package:equatable/equatable.dart';

abstract class FoodEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFoods extends FoodEvent {}

class SearchFoods extends FoodEvent {
  final String query;

  SearchFoods(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterFoodsByCategory extends FoodEvent {
  final String? category;

  FilterFoodsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

