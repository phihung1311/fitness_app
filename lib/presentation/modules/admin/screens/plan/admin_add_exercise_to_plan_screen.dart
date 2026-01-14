import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/plan/admin_plan_bloc.dart';
import '../../bloc/plan/admin_plan_event.dart';
import '../../bloc/plan/admin_plan_state.dart';
import '../../bloc/exercise/admin_exercise_bloc.dart';
import '../../bloc/exercise/admin_exercise_state.dart';
import '../../../../../domain/entities/exercise.dart';

class AdminAddExerciseToPlanScreen extends StatefulWidget {
  final int workoutPlanId;

  const AdminAddExerciseToPlanScreen({
    super.key,
    required this.workoutPlanId,
  });

  static const String routeName = '/admin/plan/add-exercise';

  @override
  State<AdminAddExerciseToPlanScreen> createState() => _AdminAddExerciseToPlanScreenState();
}

class _AdminAddExerciseToPlanScreenState extends State<AdminAddExerciseToPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '12');
  final _durationController = TextEditingController();
  final _orderIndexController = TextEditingController();
  final _searchController = TextEditingController();

  Exercise? _selectedExercise;
  String _selectedDayOfWeek = 'Monday';
  bool _isSubmitting = false;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, String> _dayLabels = {
    'Monday': 'Thứ 2',
    'Tuesday': 'Thứ 3',
    'Wednesday': 'Thứ 4',
    'Thursday': 'Thứ 5',
    'Friday': 'Thứ 6',
    'Saturday': 'Thứ 7',
    'Sunday': 'Chủ nhật',
  };

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _orderIndexController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn bài tập'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final sets = int.tryParse(_setsController.text);
    final reps = int.tryParse(_repsController.text);
    final durationMin = _durationController.text.isEmpty
        ? null
        : int.tryParse(_durationController.text);
    final orderIndex = _orderIndexController.text.isEmpty
        ? null
        : int.tryParse(_orderIndexController.text);

    if (sets == null || sets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số sets phải lớn hơn 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số reps phải lớn hơn 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (durationMin != null && durationMin < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian phải lớn hơn hoặc bằng 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isSubmitting = true;
    context.read<AdminPlanBloc>().add(
          AddExerciseToWorkoutPlanEvent(
            workoutPlanId: widget.workoutPlanId,
            exerciseId: _selectedExercise!.id,
            dayOfWeek: _selectedDayOfWeek,
            sets: sets,
            reps: reps,
            durationMin: durationMin,
            orderIndex: orderIndex,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminPlanBloc, AdminPlanState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage;
      },
      listener: (context, state) {
        if (state.errorMessage != null) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.successMessage != null) {
          _isSubmitting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          Future.microtask(() {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0F0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1E1D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Thêm bài tập vào kế hoạch',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<AdminExerciseBloc, AdminExerciseState>(
          builder: (context, exerciseState) {
            final exercises = exerciseState.displayedExercises;
            final filteredExercises = _searchController.text.isEmpty
                ? exercises
                : exercises.where((exercise) {
                    final query = _searchController.text.toLowerCase();
                    return exercise.name.toLowerCase().contains(query) ||
                        (exercise.muscleGroup?.toLowerCase().contains(query) ?? false);
                  }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Chọn bài tập
                    const Text(
                      'Chọn bài tập *',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Search field
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm bài tập...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF1C1E1D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    // Exercise list
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1E1D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: filteredExercises.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _searchController.text.isEmpty
                                      ? 'Không có bài tập nào'
                                      : 'Không tìm thấy bài tập',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredExercises.length,
                              itemBuilder: (context, index) {
                                final exercise = filteredExercises[index];
                                final isSelected = _selectedExercise?.id == exercise.id;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedExercise = exercise;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF52C41A).withOpacity(0.2)
                                          : Colors.transparent,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                exercise.name,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? const Color(0xFF52C41A)
                                                      : Colors.white,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              if (exercise.muscleGroup != null)
                                                Text(
                                                  exercise.muscleGroup!,
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              if (exercise.difficulty != null)
                                                Text(
                                                  'Độ khó: ${exercise.difficulty}',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF52C41A),
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                    // Chọn ngày
                    const Text(
                      'Chọn ngày *',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDayOfWeek,
                      dropdownColor: const Color(0xFF1C1E1D),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1C1E1D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                        ),
                      ),
                      items: _daysOfWeek.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(_dayLabels[day] ?? day),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDayOfWeek = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Sets và Reps
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _setsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Số sets *',
                              hintText: '3',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF1C1E1D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập số sets';
                              }
                              final sets = int.tryParse(value);
                              if (sets == null || sets <= 0) {
                                return 'Số sets phải lớn hơn 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _repsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Số reps *',
                              hintText: '12',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFF1C1E1D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập số reps';
                              }
                              final reps = int.tryParse(value);
                              if (reps == null || reps <= 0) {
                                return 'Số reps phải lớn hơn 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Duration (optional)
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Thời gian (phút)',
                        hintText: '30 (tùy chọn)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        filled: true,
                        fillColor: const Color(0xFF1C1E1D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final duration = int.tryParse(value);
                          if (duration == null || duration < 0) {
                            return 'Thời gian phải lớn hơn hoặc bằng 0';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Order Index (optional)
                    TextFormField(
                      controller: _orderIndexController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Thứ tự (order index)',
                        hintText: '1 (tùy chọn)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        filled: true,
                        fillColor: const Color(0xFF1C1E1D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF52C41A), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final orderIndex = int.tryParse(value);
                          if (orderIndex == null || orderIndex <= 0) {
                            return 'Thứ tự phải lớn hơn 0';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Nút Thêm
                    BlocBuilder<AdminPlanBloc, AdminPlanState>(
                      builder: (context, state) => SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (state.isSubmitting || _isSubmitting) ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF52C41A),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: state.isSubmitting || _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Thêm bài tập',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
