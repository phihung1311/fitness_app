import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/plan/admin_plan_bloc.dart';
import '../../bloc/plan/admin_plan_event.dart';
import '../../bloc/plan/admin_plan_state.dart';
import '../../bloc/admin_food/admin_food_bloc.dart';
import '../../bloc/admin_food/admin_food_event.dart';
import '../../bloc/admin_food/admin_food_state.dart';
import '../../bloc/exercise/admin_exercise_bloc.dart';
import '../../bloc/exercise/admin_exercise_event.dart';
import '../../bloc/exercise/admin_exercise_state.dart';
import 'admin_add_food_to_plan_screen.dart';
import 'admin_edit_food_in_plan_screen.dart';
import 'admin_add_exercise_to_plan_screen.dart';
import 'admin_edit_exercise_in_plan_screen.dart';

class AdminPlanDetailScreen extends StatefulWidget {
  final int mealPlanId;
  final int workoutPlanId;

  const AdminPlanDetailScreen({
    super.key,
    required this.mealPlanId,
    required this.workoutPlanId,
  });

  static const String routeName = '/admin/plan-detail';

  @override
  State<AdminPlanDetailScreen> createState() => _AdminPlanDetailScreenState();
}

class _AdminPlanDetailScreenState extends State<AdminPlanDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data sau khi context đã có access đến providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminPlanBloc>().add(
              LoadTemplatePlanDetailEvent(
                mealPlanId: widget.mealPlanId,
                workoutPlanId: widget.workoutPlanId,
              ),
            );
        context.read<AdminFoodBloc>().add(const LoadFoods());
        context.read<AdminExerciseBloc>().add(const LoadExercises());
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
    return BlocConsumer<AdminPlanBloc, AdminPlanState>(
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
          // Reload plan detail sau khi xóa món ăn/bài tập thành công
          final message = state.successMessage!;
          if (message.contains('Xóa món ăn') || message.contains('Xóa bài tập')) {
            // Delay một chút để đảm bảo API đã hoàn thành
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                context.read<AdminPlanBloc>().add(
                      LoadTemplatePlanDetailEvent(
                        mealPlanId: widget.mealPlanId,
                        workoutPlanId: widget.workoutPlanId,
                      ),
                    );
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

        final planDetail = state.planDetail;
        if (planDetail == null) {
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
                'Không tìm thấy kế hoạch',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final mealPlan = planDetail['meal_plan'] as Map<String, dynamic>?;
        final workoutPlan = planDetail['workout_plan'] as Map<String, dynamic>?;
        final mealsByDay = planDetail['meals_by_day'] as Map<String, dynamic>? ?? {};
        final exercisesByDay = planDetail['exercises_by_day'] as Map<String, dynamic>? ?? {};

        return Scaffold(
          backgroundColor: const Color(0xFF0D0F0E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1C1E1D),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              mealPlan?['name'] as String? ?? 'Chi tiết kế hoạch',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF52C41A),
              unselectedLabelColor: Colors.white70,
              indicatorColor: const Color(0xFF52C41A),
              tabs: const [
                Tab(text: 'Thông tin'),
                Tab(text: 'Món ăn'),
                Tab(text: 'Bài tập'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(mealPlan, workoutPlan),
              _buildMealsTab(mealsByDay, widget.mealPlanId),
              _buildExercisesTab(exercisesByDay, widget.workoutPlanId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(Map<String, dynamic>? mealPlan, Map<String, dynamic>? workoutPlan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mealPlan != null) ...[
            _buildInfoCard('Kế hoạch ăn uống', [
              _buildInfoRow('Tên', mealPlan['name'] as String? ?? 'N/A'),
              _buildInfoRow('Mục tiêu', mealPlan['goal_type'] as String? ?? 'N/A'),
              _buildInfoRow('Calories/ngày', '${mealPlan['target_calories'] ?? 'N/A'} kcal'),
              _buildInfoRow('Thời gian', '${mealPlan['duration_days'] ?? 'N/A'} ngày'),
              if (mealPlan['description'] != null)
                _buildInfoRow('Mô tả', mealPlan['description'] as String),
            ]),
            const SizedBox(height: 16),
          ],
          if (workoutPlan != null) ...[
            _buildInfoCard('Kế hoạch tập luyện', [
              _buildInfoRow('Tên', workoutPlan['name'] as String? ?? 'N/A'),
              _buildInfoRow('Mục tiêu', workoutPlan['goal_type'] as String? ?? 'N/A'),
              _buildInfoRow('Độ khó', workoutPlan['level'] as String? ?? 'N/A'),
              _buildInfoRow('Thời gian', '${workoutPlan['duration_days'] ?? 'N/A'} ngày'),
              if (workoutPlan['target_value'] != null)
                _buildInfoRow('Thay đổi cân nặng', '${workoutPlan['target_value']} kg'),
              if (workoutPlan['description'] != null)
                _buildInfoRow('Mô tả', workoutPlan['description'] as String),
            ]),
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
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsTab(Map<String, dynamic> mealsByDay, int mealPlanId) {
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayLabels = {
      'Monday': 'Thứ 2',
      'Tuesday': 'Thứ 3',
      'Wednesday': 'Thứ 4',
      'Thursday': 'Thứ 5',
      'Friday': 'Thứ 6',
      'Saturday': 'Thứ 7',
      'Sunday': 'Chủ nhật',
    };

    return BlocBuilder<AdminFoodBloc, AdminFoodState>(
      builder: (context, foodState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch trình món ăn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF52C41A)),
                    onPressed: () => _showAddFoodDialog(context, mealPlanId, foodState.displayedFoods),
                    tooltip: 'Thêm món ăn',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...daysOfWeek.map((day) {
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildMealSessions(dayMeals, mealPlanId),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMealSessions(Map<String, dynamic> meals, int mealPlanId) {
    final mealLabels = {
      'breakfast': 'Bữa sáng',
      'lunch': 'Bữa trưa',
      'dinner': 'Bữa tối',
      'snack': 'Bữa phụ',
    };

    return mealLabels.entries.map((entry) {
      final session = entry.key;
      final label = entry.value;
      final sessionMeals = meals[session] as List<dynamic>? ?? [];

      if (sessionMeals.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF52C41A),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...sessionMeals.map((meal) {
            final mealMap = meal as Map<String, dynamic>;
            final foodName = mealMap['food_name'] as String? ?? 'Unknown';
            final sizeGram = mealMap['size_gram'] ?? 0;
            final calories = mealMap['calories'] ?? 0;
            final foodId = mealMap['id'] as int?;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2C2B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$foodName (${sizeGram}g - $calories kcal)',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: foodId != null
                        ? () => _showEditFoodDialog(context, mealPlanId, foodId!, mealMap)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: foodId != null
                        ? () => _showDeleteFoodDialog(context, mealPlanId, foodId!)
                        : null,
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  Widget _buildExercisesTab(Map<String, dynamic> exercisesByDay, int workoutPlanId) {
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayLabels = {
      'Monday': 'Thứ 2',
      'Tuesday': 'Thứ 3',
      'Wednesday': 'Thứ 4',
      'Thursday': 'Thứ 5',
      'Friday': 'Thứ 6',
      'Saturday': 'Thứ 7',
      'Sunday': 'Chủ nhật',
    };

    return BlocBuilder<AdminExerciseBloc, AdminExerciseState>(
      builder: (context, exerciseState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch trình bài tập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF52C41A)),
                    onPressed: () => _showAddExerciseDialog(context, workoutPlanId, exerciseState.displayedExercises),
                    tooltip: 'Thêm bài tập',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...daysOfWeek.map((day) {
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
                          fontSize: 16,
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
                        final exerciseId = exMap['id'] as int?;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2C2B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exerciseName,
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    if (sets != null && reps != null)
                                      Text(
                                        '$sets x $reps',
                                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                                      ),
                                    if (durationMin != null)
                                      Text(
                                        '$durationMin phút',
                                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: exerciseId != null
                                    ? () => _showEditExerciseDialog(context, workoutPlanId, exerciseId!, exMap)
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: exerciseId != null
                                    ? () => _showDeleteExerciseDialog(context, workoutPlanId, exerciseId!)
                                    : null,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showAddFoodDialog(BuildContext context, int mealPlanId, List foods) {
    Navigator.of(context)
        .pushNamed(
          AdminAddFoodToPlanScreen.routeName,
          arguments: {'mealPlanId': mealPlanId},
        )
        .then((result) {
      if (result == true && mounted) {
        // Reload plan detail
        context.read<AdminPlanBloc>().add(
              LoadTemplatePlanDetailEvent(
                mealPlanId: widget.mealPlanId,
                workoutPlanId: widget.workoutPlanId,
              ),
            );
      }
    });
  }

  void _showEditFoodDialog(BuildContext context, int mealPlanId, int foodId, Map<String, dynamic> meal) {
    Navigator.of(context)
        .pushNamed(
          AdminEditFoodInPlanScreen.routeName,
          arguments: {
            'mealPlanId': mealPlanId,
            'foodId': foodId,
            'mealData': meal,
          },
        )
        .then((result) {
      if (result == true && mounted) {
        // Reload plan detail
        context.read<AdminPlanBloc>().add(
              LoadTemplatePlanDetailEvent(
                mealPlanId: widget.mealPlanId,
                workoutPlanId: widget.workoutPlanId,
              ),
            );
      }
    });
  }

  void _showDeleteFoodDialog(BuildContext context, int mealPlanId, int foodId) {
    final bloc = context.read<AdminPlanBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<AdminPlanBloc, AdminPlanState>(
          builder: (context, state) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1E1D),
              title: const Text('Xóa món ăn', style: TextStyle(color: Colors.white)),
              content: const Text('Bạn có chắc muốn xóa món ăn này?', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          bloc.add(
                                DeleteFoodFromMealPlanEvent(
                                  mealPlanId: mealPlanId,
                                  foodId: foodId,
                                ),
                              );
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context, int workoutPlanId, List exercises) {
    Navigator.of(context)
        .pushNamed(
          AdminAddExerciseToPlanScreen.routeName,
          arguments: {'workoutPlanId': workoutPlanId},
        )
        .then((result) {
      if (result == true && mounted) {
        // Reload plan detail
        context.read<AdminPlanBloc>().add(
              LoadTemplatePlanDetailEvent(
                mealPlanId: widget.mealPlanId,
                workoutPlanId: widget.workoutPlanId,
              ),
            );
      }
    });
  }

  void _showEditExerciseDialog(BuildContext context, int workoutPlanId, int exerciseId, Map<String, dynamic> exercise) {
    Navigator.of(context)
        .pushNamed(
          AdminEditExerciseInPlanScreen.routeName,
          arguments: {
            'workoutPlanId': workoutPlanId,
            'exerciseId': exerciseId,
            'exerciseData': exercise,
          },
        )
        .then((result) {
      if (result == true && mounted) {
        // Reload plan detail
        context.read<AdminPlanBloc>().add(
              LoadTemplatePlanDetailEvent(
                mealPlanId: widget.mealPlanId,
                workoutPlanId: widget.workoutPlanId,
              ),
            );
      }
    });
  }

  void _showDeleteExerciseDialog(BuildContext context, int workoutPlanId, int exerciseId) {
    final bloc = context.read<AdminPlanBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<AdminPlanBloc, AdminPlanState>(
          builder: (context, state) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1E1D),
              title: const Text('Xóa bài tập', style: TextStyle(color: Colors.white)),
              content: const Text('Bạn có chắc muốn xóa bài tập này?', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          bloc.add(
                                DeleteExerciseFromWorkoutPlanEvent(
                                  workoutPlanId: workoutPlanId,
                                  exerciseId: exerciseId,
                                ),
                              );
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
