import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/template_plan/template_plan_bloc.dart';
import '../../bloc/template_plan/template_plan_event.dart';
import '../../bloc/template_plan/template_plan_state.dart';
import '../../bloc/plan/plan_bloc.dart';
import '../../bloc/plan/plan_event.dart';

class TemplatePlanDetailScreen extends StatefulWidget {
  final int mealPlanId;
  final int workoutPlanId;
  final Map<String, dynamic>? plan;

  const TemplatePlanDetailScreen({
    super.key,
    required this.mealPlanId,
    required this.workoutPlanId,
    this.plan,
  });

  static const String routeName = '/user/template-plan-detail';

  @override
  State<TemplatePlanDetailScreen> createState() => _TemplatePlanDetailScreenState();
}

class _TemplatePlanDetailScreenState extends State<TemplatePlanDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TemplatePlanBloc>().add(
              LoadTemplatePlanDetail(
                mealPlanId: widget.mealPlanId,
                workoutPlanId: widget.workoutPlanId,
              ),
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TemplatePlanBloc, TemplatePlanState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          // Reload user plan và quay về màn hình plan
          if (state.successMessage!.contains('Áp dụng')) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<PlanBloc>().add(const LoadUserPlan());
                Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/plan');
              }
            });
          }
        }
      },
      builder: (context, state) {
        if (state.isLoadingDetail) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D0F0E),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1C1E1D),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Chi tiết kế hoạch',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFF52C41A)),
            ),
          );
        }

        final detail = state.templatePlanDetail;
        if (detail == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D0F0E),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1C1E1D),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Chi tiết kế hoạch',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: const Center(
              child: Text(
                'Không tìm thấy chi tiết kế hoạch',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0D0F0E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1C1E1D),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Chi tiết kế hoạch',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF52C41A),
              unselectedLabelColor: Colors.white70,
              indicatorColor: const Color(0xFF52C41A),
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Món ăn'),
                Tab(text: 'Bài tập'),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(detail),
                    _buildMealsTab(detail),
                    _buildExercisesTab(detail),
                  ],
                ),
              ),
              // Apply button
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF1C1E1D),
                child: BlocBuilder<TemplatePlanBloc, TemplatePlanState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isApplying
                            ? null
                            : () {
                                context.read<TemplatePlanBloc>().add(
                                      ApplyTemplatePlan(
                                        mealPlanId: widget.mealPlanId,
                                        workoutPlanId: widget.workoutPlanId,
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF52C41A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state.isApplying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Áp dụng kế hoạch này',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> detail) {
    final mealPlan = detail['meal_plan'] as Map<String, dynamic>?;
    final workoutPlan = detail['workout_plan'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mealPlan != null) ...[
            _buildInfoCard(
              'Kế hoạch ăn uống',
              [
                _buildInfoRow('Tên', mealPlan['name'] ?? 'N/A'),
                _buildInfoRow('Mục tiêu', mealPlan['goal_type'] ?? 'N/A'),
                _buildInfoRow('Calories mục tiêu', '${mealPlan['target_calories'] ?? 0} kcal'),
                _buildInfoRow('Thời gian', '${mealPlan['duration_days'] ?? 0} ngày'),
                if (mealPlan['description'] != null)
                  _buildInfoRow('Mô tả', mealPlan['description']),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (workoutPlan != null) ...[
            _buildInfoCard(
              'Kế hoạch tập luyện',
              [
                _buildInfoRow('Tên', workoutPlan['name'] ?? 'N/A'),
                _buildInfoRow('Mục tiêu', workoutPlan['goal_type'] ?? 'N/A'),
                _buildInfoRow('Độ khó', workoutPlan['level'] ?? 'N/A'),
                _buildInfoRow('Thời gian', '${workoutPlan['duration_days'] ?? 0} ngày'),
                if (workoutPlan['target_value'] != null)
                  _buildInfoRow(
                    'Mục tiêu cân nặng',
                    workoutPlan['target_value'] > 0
                        ? '+${workoutPlan['target_value']} kg'
                        : '${workoutPlan['target_value']} kg',
                  ),
                if (workoutPlan['description'] != null)
                  _buildInfoRow('Mô tả', workoutPlan['description']),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
      ),
    );
  }

  Widget _buildMealsTab(Map<String, dynamic> detail) {
    final mealsByDay = detail['meals_by_day'] as Map<String, dynamic>? ?? {};

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

    final mealLabels = {
      'breakfast': 'Bữa sáng',
      'lunch': 'Bữa trưa',
      'dinner': 'Bữa tối',
      'snack': 'Bữa phụ',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: daysOfWeek.map((day) {
          final dayMeals = mealsByDay[day] as Map<String, dynamic>? ?? {};
          final hasMeals = (dayMeals['breakfast'] as List?)?.isNotEmpty == true ||
              (dayMeals['lunch'] as List?)?.isNotEmpty == true ||
              (dayMeals['dinner'] as List?)?.isNotEmpty == true ||
              (dayMeals['snack'] as List?)?.isNotEmpty == true;

          if (!hasMeals) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1E1D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                const SizedBox(height: 16),
                ...mealLabels.entries.map((entry) {
                  final session = entry.key;
                  final label = entry.value;
                  final sessionMeals = dayMeals[session] as List<dynamic>? ?? [];

                  if (sessionMeals.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF52C41A),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...sessionMeals.map((meal) {
                        final mealMap = meal as Map<String, dynamic>;
                        final foodName = mealMap['food_name'] as String? ?? 'Unknown';
                        final sizeGram = mealMap['size_gram'] ?? 0;
                        final calories = mealMap['calories'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2C2B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$foodName (${sizeGram}g - $calories kcal)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExercisesTab(Map<String, dynamic> detail) {
    final exercisesByDay = detail['exercises_by_day'] as Map<String, dynamic>? ?? {};

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: daysOfWeek.map((day) {
          final dayExercises = exercisesByDay[day] as List<dynamic>? ?? [];

          if (dayExercises.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1E1D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                ...dayExercises.map((exercise) {
                  final exMap = exercise as Map<String, dynamic>;
                  final exerciseName = exMap['exercise_name'] as String? ?? 'Unknown';
                  final sets = exMap['sets'];
                  final reps = exMap['reps'];
                  final durationMin = exMap['duration_min'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2C2B),
                      borderRadius: BorderRadius.circular(8),
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
