import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/plan/admin_plan_bloc.dart';
import '../../bloc/plan/admin_plan_event.dart';
import '../../bloc/plan/admin_plan_state.dart';
import 'admin_create_plan_screen.dart';
import 'admin_plan_detail_screen.dart';

class AdminPlanManagementScreen extends StatefulWidget {
  const AdminPlanManagementScreen({super.key});

  static const String routeName = '/admin/plan-management';

  @override
  State<AdminPlanManagementScreen> createState() => _AdminPlanManagementScreenState();
}

class _AdminPlanManagementScreenState extends State<AdminPlanManagementScreen> {
  String? _selectedGoalType;
  String? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminPlanBloc()..add(const LoadTemplatePlansEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1E1D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Quản lý Kế hoạch',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  AdminCreatePlanScreen.routeName,
                );
                if (result == true && mounted) {
                  context.read<AdminPlanBloc>().add(const LoadTemplatePlansEvent());
                }
              },
              tooltip: 'Tạo kế hoạch mới',
            ),
          ],
        ),
        body: BlocConsumer<AdminPlanBloc, AdminPlanState>(
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
              // Reload plans sau khi xóa plan thành công
              final message = state.successMessage!;
              if (message.contains('Xóa template plan')) {
                // Delay một chút để đảm bảo API đã hoàn thành
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    context.read<AdminPlanBloc>().add(
                          LoadTemplatePlansEvent(
                            goalType: _selectedGoalType,
                            level: _selectedLevel,
                          ),
                        );
                  }
                });
              }
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF52C41A)),
              );
            }

            return Column(
              children: [
                // Filters
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1C1E1D),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGoalType,
                          decoration: InputDecoration(
                            labelText: 'Mục tiêu',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF2A2C2B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: const Color(0xFF2A2C2B),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tất cả')),
                            DropdownMenuItem(value: 'lose', child: Text('Giảm cân')),
                            DropdownMenuItem(value: 'gain', child: Text('Tăng cân')),
                            DropdownMenuItem(value: 'muscle_gain', child: Text('Tăng cơ')),
                            DropdownMenuItem(value: 'maintain', child: Text('Duy trì')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedGoalType = value);
                            context.read<AdminPlanBloc>().add(
                                  LoadTemplatePlansEvent(
                                    goalType: value,
                                    level: _selectedLevel,
                                  ),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedLevel,
                          decoration: InputDecoration(
                            labelText: 'Độ khó',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF2A2C2B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: const Color(0xFF2A2C2B),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tất cả')),
                            DropdownMenuItem(value: 'easy', child: Text('Dễ')),
                            DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
                            DropdownMenuItem(value: 'hard', child: Text('Khó')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedLevel = value);
                            context.read<AdminPlanBloc>().add(
                                  LoadTemplatePlansEvent(
                                    goalType: _selectedGoalType,
                                    level: value,
                                  ),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Plans list
                Expanded(
                  child: state.plans.isEmpty
                      ? Center(
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
                                'Chưa có kế hoạch mẫu',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    AdminCreatePlanScreen.routeName,
                                  );
                                  if (result == true && mounted) {
                                    context.read<AdminPlanBloc>().add(const LoadTemplatePlansEvent());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF52C41A),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Tạo kế hoạch đầu tiên'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF52C41A),
                          backgroundColor: const Color(0xFF1C1E1D),
                          onRefresh: () async {
                            context.read<AdminPlanBloc>().add(
                                  LoadTemplatePlansEvent(
                                    goalType: _selectedGoalType,
                                    level: _selectedLevel,
                                  ),
                                );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.plans.length,
                            itemBuilder: (context, index) {
                              final plan = state.plans[index];
                              return _buildPlanCard(context, plan, state);
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan, AdminPlanState state) {
    final goalTypeLabels = {
      'lose': 'Giảm cân',
      'gain': 'Tăng cân',
      'muscle_gain': 'Tăng cơ',
      'maintain': 'Duy trì',
    };
    final levelLabels = {
      'easy': 'Dễ',
      'medium': 'Trung bình',
      'hard': 'Khó',
    };

    final goalType = plan['goal_type'] as String?;
    final level = plan['level'] as String?;
    final targetWeightChange = plan['target_weight_change'] as num?;
    final durationDays = plan['duration_days'] as int?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1C1E1D),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AdminPlanDetailScreen.routeName,
            arguments: {
              'mealPlanId': plan['meal_plan_id'] as int,
              'workoutPlanId': plan['workout_plan_id'] as int,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan['name'] as String? ?? 'Không có tên',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: state.isSubmitting
                        ? null
                        : () => _showDeleteDialog(context, plan),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
              if (plan['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  plan['description'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (goalType != null)
                    _buildChip(
                      goalTypeLabels[goalType] ?? goalType,
                      const Color(0xFF52C41A),
                    ),
                  if (level != null)
                    _buildChip(
                      levelLabels[level] ?? level,
                      Colors.blue,
                    ),
                  if (targetWeightChange != null)
                    _buildChip(
                      targetWeightChange > 0
                          ? '+${targetWeightChange} kg'
                          : '${targetWeightChange} kg',
                      Colors.orange,
                    ),
                  if (durationDays != null)
                    _buildChip(
                      '$durationDays ngày',
                      Colors.purple,
                    ),
                  if (plan['target_calories'] != null)
                    _buildChip(
                      '${plan['target_calories']} kcal',
                      Colors.red,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> plan) {
    final bloc = context.read<AdminPlanBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<AdminPlanBloc, AdminPlanState>(
          builder: (context, state) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1E1D),
              title: const Text(
                'Xóa kế hoạch',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Bạn có chắc muốn xóa kế hoạch "${plan['name']}"?',
                style: const TextStyle(color: Colors.white70),
              ),
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
                          final mealPlanId = plan['meal_plan_id'] as int?;
                          final workoutPlanId = plan['workout_plan_id'] as int?;
                          if (mealPlanId != null && workoutPlanId != null) {
                            bloc.add(
                                  DeleteTemplatePlanEvent(
                                    mealPlanId: mealPlanId,
                                    workoutPlanId: workoutPlanId,
                                  ),
                                );
                          }
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
                      : const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.red),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
