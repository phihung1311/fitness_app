import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/template_plan/template_plan_bloc.dart';
import '../../bloc/template_plan/template_plan_event.dart';
import '../../bloc/template_plan/template_plan_state.dart';
import 'template_plan_detail_screen.dart';

class TemplatePlansScreen extends StatefulWidget {
  const TemplatePlansScreen({super.key});

  static const String routeName = '/user/template-plans';

  @override
  State<TemplatePlansScreen> createState() => _TemplatePlansScreenState();
}

class _TemplatePlansScreenState extends State<TemplatePlansScreen> {
  String? _selectedGoalType;
  String? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TemplatePlanBloc()..add(const LoadTemplatePlans()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1E1D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Kế hoạch mẫu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<TemplatePlanBloc, TemplatePlanState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
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
                            context.read<TemplatePlanBloc>().add(
                                  LoadTemplatePlans(
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
                            context.read<TemplatePlanBloc>().add(
                                  LoadTemplatePlans(
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
                // Plans List
                Expanded(
                  child: state.templatePlans == null || state.templatePlans!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.library_books_outlined,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có kế hoạch mẫu',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF52C41A),
                          backgroundColor: const Color(0xFF1C1E1D),
                          onRefresh: () async {
                            context.read<TemplatePlanBloc>().add(
                                  LoadTemplatePlans(
                                    goalType: _selectedGoalType,
                                    level: _selectedLevel,
                                  ),
                                );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.templatePlans!.length,
                            itemBuilder: (context, index) {
                              final plan = state.templatePlans![index];
                              return _buildPlanCard(context, plan);
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

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
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
          final mealPlanId = plan['meal_plan_id'] as int?;
          final workoutPlanId = plan['workout_plan_id'] as int?;
          if (mealPlanId != null && workoutPlanId != null) {
            Navigator.pushNamed(
              context,
              TemplatePlanDetailScreen.routeName,
              arguments: {
                'mealPlanId': mealPlanId,
                'workoutPlanId': workoutPlanId,
                'plan': plan,
              },
            );
          }
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
                  if (durationDays != null)
                    _buildChip(
                      '$durationDays ngày',
                      Colors.purple,
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
}
