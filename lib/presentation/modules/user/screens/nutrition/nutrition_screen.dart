import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../domain/entities/user_meal.dart';
import '../../bloc/meal/meal_bloc.dart';
import '../../bloc/meal/meal_event.dart';
import '../../bloc/meal/meal_state.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MealBloc>().add(LoadTodayMeals());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0F0E), // Pure black background
      ),
      child: SafeArea(
        child: BlocBuilder<MealBloc, MealState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF52C41A)),
              );
            }

            if (state.errorMessage != null) {
              return Center(
                child: Text(
                  'Lỗi: ${state.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final todayMeals = state.todayMeals;
            final totalCalories = state.totalCalories;

            return RefreshIndicator(
              color: const Color(0xFF52C41A),
              backgroundColor: const Color(0xFF1C1E1D),
              onRefresh: () async {
                context.read<MealBloc>().add(LoadTodayMeals());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dinh dưỡng hôm nay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Calorie Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF52C41A).withOpacity(0.8),
                              const Color(0xFF52C41A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF52C41A).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Tổng calo đã nạp',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalCalories',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'kcal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Meal Sessions
                      _buildMealSession(
                        context,
                        'Bữa sáng',
                        Icons.wb_sunny,
                        todayMeals?['breakfast'] ?? [],
                      ),
                      const SizedBox(height: 16),
                      _buildMealSession(
                        context,
                        'Bữa trưa',
                        Icons.lunch_dining,
                        todayMeals?['lunch'] ?? [],
                      ),
                      const SizedBox(height: 16),
                      _buildMealSession(
                        context,
                        'Bữa tối',
                        Icons.dinner_dining,
                        todayMeals?['dinner'] ?? [],
                      ),
                      const SizedBox(height: 16),
                      _buildMealSession(
                        context,
                        'Bữa phụ',
                        Icons.cookie,
                        todayMeals?['snack'] ?? [],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMealSession(
    BuildContext context,
    String title,
    IconData icon,
    List<UserMeal> meals,
  ) {
    final sessionCalories = meals.fold<int>(
      0,
      (sum, meal) => sum + (meal.calories ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF52C41A).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF52C41A), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF52C41A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$sessionCalories kcal',
                  style: const TextStyle(
                    color: Color(0xFF52C41A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Foods
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  'Chưa có món ăn nào',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...meals.map((meal) => _buildFoodItem(meal)).toList(),
        ],
      ),
    );
  }

  Widget _buildFoodItem(UserMeal meal) {
    final food = meal.food;
    if (food == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F0E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildFoodImage(food.imageUrl),
          ),
          const SizedBox(width: 12),

          // Food Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.weightGrams}g • ${meal.calories} kcal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    // Case 1: Full URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    // Case 2: Server upload path
    if (imageUrl.startsWith('/uploads/')) {
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000',
      );
      final serverUrl = baseUrl.replaceAll('/api', '');
      final fullUrl = '$serverUrl$imageUrl';
      return Image.network(
        fullUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    // Case 3: Asset
    final assetPath = imageUrl.contains('assets/')
        ? imageUrl
        : 'assets/images/foods/$imageUrl';
    return Image.asset(
      assetPath,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFF2A2C2B),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: Colors.white.withOpacity(0.3),
          size: 24,
        ),
      ),
    );
  }
}

