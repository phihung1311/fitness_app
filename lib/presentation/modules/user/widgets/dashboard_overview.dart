import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../../../data/datasources/remote/exercise_api.dart';
import '../../../../data/datasources/remote/meal_api.dart';
import '../../../../data/dtos/exercise_dto.dart';
import '../../../../data/dtos/food_dto.dart';
import '../bloc/profile_metrics/profile_metrics_bloc.dart';
import '../bloc/profile_metrics/profile_metrics_event.dart';
import '../bloc/profile_metrics/profile_metrics_state.dart';
import '../screens/exercise/exercise_detail_screen.dart';
import '../screens/food/food_detail_screen.dart';
import 'exercise_card.dart';
import 'food_card.dart';
import 'greeting_section.dart';

class DashboardOverview extends StatelessWidget {
  final VoidCallback? onNavigateToFoodTab;
  final VoidCallback? onNavigateToExerciseTab;

  const DashboardOverview({
    super.key,
    this.onNavigateToFoodTab,
    this.onNavigateToExerciseTab,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileMetricsBloc(injector())..add(LoadProfileMetrics()),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0F0E),
        ),
        child: SafeArea(
          child: BlocBuilder<ProfileMetricsBloc, ProfileMetricsState>(
            builder: (context, state) {
              final metrics = state.metrics;
              final targetCalories = metrics?.calorieGoal ?? 2000;
              
              // Load tổng calories hôm nay (meals + exercises)
              return FutureBuilder<Map<String, dynamic>>(
                future: injector<ExerciseApi>().getTodayCalories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF52C41A)),
                    );
                  }
                  
                  final data = snapshot.data;
                  final caloriesIn = data?['calories_in'] as int? ?? 0;
                  final caloriesOut = data?['calories_out'] as int? ?? 0;
                  final netCalories = data?['net_calories'] as int? ?? 0;
                  final remaining = data?['remaining'] as int? ?? 0;
                  
                  final progressValue = targetCalories > 0 
                      ? (netCalories / targetCalories).clamp(0.0, 1.0) 
                      : 0.0;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: GreetingSection(userName: metrics?.name),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Cân nặng',
                              value: metrics?.weightDisplay ?? '--',
                              icon: Icons.monitor_weight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricCard(
                              label: 'Chiều cao',
                              value: metrics?.heightDisplay ?? '--',
                              icon: Icons.height,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'BMI',
                              value: metrics?.bmiDisplay ?? '--',
                              icon: Icons.calculate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricCard(
                              label: 'Calo mục tiêu',
                              value: metrics?.calorieGoalDisplay ?? '--',
                              icon: Icons.local_fire_department,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1E1D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2A2C2B),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calories Hôm Nay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Calories In
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_downward_rounded,
                                      color: Color(0xFF52C41A),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Nạp vào',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$caloriesIn kcal',
                                  style: const TextStyle(
                                    color: Color(0xFF52C41A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Calories Out
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      color: Colors.redAccent.shade200,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đốt cháy',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$caloriesOut kcal',
                                  style: TextStyle(
                                    color: Colors.redAccent.shade200,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFF2A2C2B)),
                            const SizedBox(height: 12),
                            // Net Calories
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Calories',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$netCalories kcal',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progressValue.clamp(0.0, 1.0),
                                minHeight: 10,
                                backgroundColor: const Color(0xFF0D0F0E),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF52C41A)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mục tiêu: $targetCalories kcal',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  remaining >= 0 
                                      ? 'Còn lại: $remaining kcal'
                                      : 'Vượt: ${-remaining} kcal',
                                  style: TextStyle(
                                    color: remaining >= 0 
                                        ? const Color(0xFF52C41A)
                                        : Colors.redAccent.shade200,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D0F0E),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Dành cho bạn hôm nay',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: onNavigateToExerciseTab,
                                  child: const Text(
                                    'Xem tất cả',
                                    style: TextStyle(
                                      color: Color(0xFF52C41A),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            FutureBuilder<List<ExerciseDto>>(
                              future: injector<ExerciseApi>().getRandomExercises(limit: 4),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 220,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF52C41A),
                                      ),
                                    ),
                                  );
                                }
                                
                                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                  return SizedBox(
                                    height: 220,
                                    child: Center(
                                      child: Text(
                                        'Không có bài tập',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final exercises = snapshot.data!;
                                return SizedBox(
                                  height: 220,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: exercises.length,
                                    itemBuilder: (context, index) {
                                      final exercise = exercises[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right: index < exercises.length - 1 ? 16 : 0,
                                        ),
                                        child: ExerciseCard(
                                          exercise: exercise,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ExerciseDetailScreen(
                                                  exercise: exercise.toEntity(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Ăn gì cho khỏe?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: onNavigateToFoodTab,
                                  child: const Text(
                                    'Xem tất cả',
                                    style: TextStyle(
                                      color: Color(0xFF52C41A),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Food Cards (Horizontal Scroll) - Load từ API
                            FutureBuilder<List<FoodDto>>(
                              future: injector<MealApi>().getRandomFoods(limit: 4),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF52C41A),
                                      ),
                                    ),
                                  );
                                }
                                
                                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                  return SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Text(
                                        'Không có món ăn',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final foods = snapshot.data!;
                                return SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: foods.length,
                                    itemBuilder: (context, index) {
                                      final food = foods[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right: index < foods.length - 1 ? 16 : 0,
                                        ),
                                        child: FoodCard(
                                          food: food,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FoodDetailScreen(
                                                  food: food.toEntity(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// Metric Card Widget (2x2 grid)
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2C2B),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
