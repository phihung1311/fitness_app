import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/plan/plan_bloc.dart';
import '../../bloc/plan/plan_event.dart';
import '../../bloc/plan/plan_state.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  static const String routeName = '/plan';

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlanBloc>().add(LoadUserPlan());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      body: SafeArea(
        child: BlocBuilder<PlanBloc, PlanState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF52C41A),
                ),
              );
            }

            if (state.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PlanBloc>().add(LoadUserPlan());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52C41A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state.userPlan == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có kế hoạch',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy hoàn tất onboarding để tạo kế hoạch tự động',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFF52C41A),
              backgroundColor: const Color(0xFF1C1E1D),
              onRefresh: () async {
                context.read<PlanBloc>().add(LoadUserPlan());
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
                            'Kế hoạch của bạn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.library_books, color: Color(0xFF52C41A)),
                            onPressed: () {
                              Navigator.pushNamed(context, '/user/template-plans');
                            },
                            tooltip: 'Kế hoạch mẫu',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Plan Overview Card
                      _buildPlanOverviewCard(state),
                      const SizedBox(height: 24),

                      // Weekly Schedule
                      _buildWeeklySchedule(state),
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

  Widget _buildPlanOverviewCard(PlanState state) {
    final plan = state.userPlan!;
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng quan kế hoạch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: plan.status == 'active'
                      ? const Color(0xFF52C41A).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plan.status == 'active' ? 'Đang thực hiện' : 'Đã hoàn thành',
                  style: TextStyle(
                    color: plan.status == 'active'
                        ? const Color(0xFF52C41A)
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Ngày bắt đầu', plan.startDate),
          const SizedBox(height: 8),
          _buildInfoRow('Ngày kết thúc', plan.endDate),
          if (plan.targetWeightChange != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Mục tiêu',
              plan.targetWeightChange! > 0
                  ? '+${plan.targetWeightChange} kg'
                  : '${plan.targetWeightChange} kg',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySchedule(PlanState state) {
    final details = state.planDetails;
    if (details == null || state.isLoadingDetails) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF52C41A)),
        ),
      );
    }

    final mealsByDay = details['meals_by_day'] as Map<String, dynamic>? ?? {};
    final exercisesByDay = details['exercises_by_day'] as Map<String, dynamic>? ?? {};

    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final dayLabels = {
      'Monday': 'Thứ 2',
      'Tuesday': 'Thứ 3',
      'Wednesday': 'Thứ 4',
      'Thursday': 'Thứ 5',
      'Friday': 'Thứ 6',
      'Saturday': 'Thứ 7',
      'Sunday': 'Chủ nhật',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch trình tuần',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...daysOfWeek.map((day) {
          final dayMeals = mealsByDay[day] as Map<String, dynamic>? ?? {};
          final dayExercises = exercisesByDay[day] as List<dynamic>? ?? [];
          
          final hasMeals = (dayMeals['breakfast'] as List?)?.isNotEmpty == true ||
              (dayMeals['lunch'] as List?)?.isNotEmpty == true ||
              (dayMeals['dinner'] as List?)?.isNotEmpty == true ||
              (dayMeals['snack'] as List?)?.isNotEmpty == true;
          final hasExercises = dayExercises.isNotEmpty;

          if (!hasMeals && !hasExercises) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                Text(
                  dayLabels[day] ?? day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (hasMeals) ...[
                  _buildMealsSection(dayMeals),
                  const SizedBox(height: 12),
                ],
                if (hasExercises) ...[
                  _buildExercisesSection(dayExercises),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMealsSection(Map<String, dynamic> meals) {
    final mealLabels = {
      'breakfast': 'Bữa sáng',
      'lunch': 'Bữa trưa',
      'dinner': 'Bữa tối',
      'snack': 'Bữa phụ',
    };

    final mealIcons = {
      'breakfast': Icons.wb_sunny,
      'lunch': Icons.lunch_dining,
      'dinner': Icons.dinner_dining,
      'snack': Icons.cookie,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Món ăn',
          style: TextStyle(
            color: Color(0xFF52C41A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...mealLabels.entries.map((entry) {
          final session = entry.key;
          final label = entry.value;
          final icon = mealIcons[session] ?? Icons.restaurant;
          final sessionMeals = meals[session] as List<dynamic>? ?? [];

          if (sessionMeals.isEmpty) return const SizedBox.shrink();

          final totalCalories = sessionMeals.fold<int>(
            0,
            (sum, meal) => sum + ((meal as Map)['calories'] as int? ?? 0),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2C2B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$totalCalories kcal',
                      style: const TextStyle(
                        color: Color(0xFF52C41A),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...sessionMeals.map((meal) {
                  final mealMap = meal as Map<String, dynamic>;
                  final food = mealMap['food'] as Map<String, dynamic>?;
                  final foodName = food?['name'] ?? mealMap['food_name'] ?? 'Unknown';
                  final sizeGram = mealMap['size_gram'] ?? 0;
                  final calories = mealMap['calories'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      '• $foodName (${sizeGram}g - $calories kcal)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExercisesSection(List<dynamic> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bài tập',
          style: TextStyle(
            color: Color(0xFF52C41A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...exercises.map((exercise) {
          final exMap = exercise as Map<String, dynamic>;
          final ex = exMap['exercise'] as Map<String, dynamic>?;
          final exerciseName = ex?['name'] ?? exMap['exercise_name'] ?? 'Unknown';
          final sets = exMap['sets'];
          final reps = exMap['reps'];
          final durationMin = exMap['duration_min'];

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2C2B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.fitness_center, color: Color(0xFF52C41A), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exerciseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (sets != null && reps != null)
                  Text(
                    '$sets x $reps',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                if (durationMin != null)
                  Text(
                    ' • ${durationMin} phút',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
