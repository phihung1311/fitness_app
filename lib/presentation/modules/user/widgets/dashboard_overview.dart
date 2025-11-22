import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../../../data/datasources/remote/meal_api.dart';
import '../bloc/profile_metrics/profile_metrics_bloc.dart';
import '../bloc/profile_metrics/profile_metrics_event.dart';
import '../bloc/profile_metrics/profile_metrics_state.dart';
import 'greeting_section.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileMetricsBloc(injector())..add(LoadProfileMetrics()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade800,
              Colors.green.shade700,
              Colors.green.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ProfileMetricsBloc, ProfileMetricsState>(
            builder: (context, state) {
              final metrics = state.metrics;
              final targetCalories = metrics?.calorieGoal ?? 2000;
              
              // Load calo hôm nay từ API
              return FutureBuilder<int>(
                future: injector<MealApi>().getTodayCalories(),
                builder: (context, snapshot) {
                  final currentCalories = snapshot.data ?? 0;
                  final progressValue = targetCalories > 0 
                      ? (currentCalories / targetCalories).clamp(0.0, 1.0) 
                      : 0.0;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với greeting
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: GreetingSection(userName: metrics?.name),
                    ),

                    // 4 Metrics Cards (2x2 Grid)
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

                    // Calorie Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lượng calo hôm nay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: progressValue.clamp(0.0, 1.0),
                              minHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentCalories / $targetCalories kcal',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // White background section
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section: "Dành cho bạn hôm nay"
                            const Text(
                              'Dành cho bạn hôm nay',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Workout Cards (Horizontal Scroll)
                            SizedBox(
                              height: 220,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: const [
                                  _WorkoutCard(
                                    title: 'Yoga buổi sáng',
                                    duration: '20 phút',
                                    calories: '150 kcal',
                                    imageUrl: 'https://via.placeholder.com/160x120/4CAF50/FFFFFF?text=Yoga',
                                  ),
                                  SizedBox(width: 16),
                                  _WorkoutCard(
                                    title: 'Cardio 15p',
                                    duration: '15 phút',
                                    calories: '250 kcal',
                                    imageUrl: 'https://via.placeholder.com/160x120/2196F3/FFFFFF?text=Cardio',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Section: "Ăn gì cho khỏe?"
                            const Text(
                              'Ăn gì cho khỏe?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Food Cards (Horizontal Scroll)
                            SizedBox(
                              height: 200,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: const [
                                  _FoodCard(
                                    title: 'Salad ức gà',
                                    mealType: 'Bữa trưa',
                                    calories: '350 kcal',
                                    imageUrl: 'https://via.placeholder.com/160x120/FF9800/FFFFFF?text=Salad',
                                  ),
                                  SizedBox(width: 16),
                                  _FoodCard(
                                    title: 'Sinh tố cải',
                                    mealType: 'Bữa sáng',
                                    calories: '200 kcal',
                                    imageUrl: 'https://via.placeholder.com/160x120/4CAF50/FFFFFF?text=Smoothie',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 100), // Padding cho bottom nav
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
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

// Workout Card Widget
class _WorkoutCard extends StatelessWidget {
  final String title;
  final String duration;
  final String calories;
  final String imageUrl;

  const _WorkoutCard({
    required this.title,
    required this.duration,
    required this.calories,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.green.shade100,
                  child: const Icon(Icons.fitness_center, size: 50, color: Colors.green),
                );
              },
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$duration • $calories',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bắt đầu',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Food Card Widget
class _FoodCard extends StatelessWidget {
  final String title;
  final String mealType;
  final String calories;
  final String imageUrl;

  const _FoodCard({
    required this.title,
    required this.mealType,
    required this.calories,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  color: Colors.orange.shade100,
                  child: const Icon(Icons.restaurant, size: 50, color: Colors.orange),
                );
              },
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$mealType • $calories',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Xem công thức',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
