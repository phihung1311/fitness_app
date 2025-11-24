import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/usecases/food/get_foods.dart';
import 'food_event.dart';
import 'food_state.dart';
import '../../../../../domain/entities/food.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final GetFoods _getFoods;

  FoodBloc(this._getFoods) : super(const FoodState()) {
    on<LoadFoods>(_onLoadFoods);
    on<SearchFoods>(_onSearchFoods);
    on<FilterFoodsByCategory>(_onFilterFoodsByCategory);
  }

  Future<void> _onLoadFoods(
    LoadFoods event,
    Emitter<FoodState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final foods = await _getFoods();
      emit(state.copyWith(
        allFoods: foods,
        displayedFoods: foods,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearchFoods(
    SearchFoods event,
    Emitter<FoodState> emit,
  ) {
    final query = event.query.toLowerCase();
    List<Food> filtered = state.allFoods;

    // Filter by meal type if selected
    if (state.selectedCategory != null) {
      filtered = filtered
          .where((food) => food.mealType == state.selectedCategory || food.mealType == 'all')
          .toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      filtered = filtered
          .where((food) => food.name.toLowerCase().contains(query))
          .toList();
    }

    emit(state.copyWith(
      searchQuery: query,
      displayedFoods: filtered,
    ));
  }

  void _onFilterFoodsByCategory(
    FilterFoodsByCategory event,
    Emitter<FoodState> emit,
  ) {
    List<Food> filtered = state.allFoods;

    // Filter by meal type
    if (event.category != null) {
      filtered = filtered
          .where((food) => food.mealType == event.category || food.mealType == 'all')
          .toList();
    }

    // Apply search query if exists
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((food) => food.name.toLowerCase().contains(state.searchQuery))
          .toList();
    }

    emit(state.copyWith(
      selectedCategory: event.category,
      displayedFoods: filtered,
    ));
  }
}

