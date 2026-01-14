import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/plan/admin_plan_bloc.dart';
import '../../bloc/plan/admin_plan_event.dart';
import '../../bloc/plan/admin_plan_state.dart';

class AdminEditExerciseInPlanScreen extends StatefulWidget {
  final int workoutPlanId;
  final int exerciseId;
  final Map<String, dynamic> exerciseData;

  const AdminEditExerciseInPlanScreen({
    super.key,
    required this.workoutPlanId,
    required this.exerciseId,
    required this.exerciseData,
  });

  static const String routeName = '/admin/plan/edit-exercise';

  @override
  State<AdminEditExerciseInPlanScreen> createState() => _AdminEditExerciseInPlanScreenState();
}

class _AdminEditExerciseInPlanScreenState extends State<AdminEditExerciseInPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _durationController = TextEditingController();
  final _orderIndexController = TextEditingController();

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
  void initState() {
    super.initState();
    // Khởi tạo giá trị từ exerciseData
    _setsController.text = (widget.exerciseData['sets'] ?? 3).toString();
    _repsController.text = (widget.exerciseData['reps'] ?? 12).toString();
    _durationController.text = widget.exerciseData['duration_min'] != null
        ? widget.exerciseData['duration_min'].toString()
        : '';
    _orderIndexController.text = widget.exerciseData['order_index'] != null
        ? widget.exerciseData['order_index'].toString()
        : '';
    _selectedDayOfWeek = widget.exerciseData['day_of_week'] as String? ?? 'Monday';
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
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

    if (orderIndex != null && orderIndex <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thứ tự phải lớn hơn 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isSubmitting = true;
    context.read<AdminPlanBloc>().add(
          UpdateExerciseInWorkoutPlanEvent(
            workoutPlanId: widget.workoutPlanId,
            exerciseId: widget.exerciseId,
            sets: sets,
            reps: reps,
            durationMin: durationMin,
            dayOfWeek: _selectedDayOfWeek,
            orderIndex: orderIndex,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final exerciseName = widget.exerciseData['exercise_name'] as String? ?? 'Unknown';
    final exercise = widget.exerciseData['exercise'] as Map<String, dynamic>?;

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
            'Chỉnh sửa bài tập',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hiển thị tên bài tập (read-only)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1E1D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bài tập',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exerciseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (exercise != null) ...[
                        if (exercise['muscle_group'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              exercise['muscle_group'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        if (exercise['difficulty'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Độ khó: ${exercise['difficulty']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ],
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
                // Nút Lưu
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
                              'Lưu thay đổi',
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
        ),
      ),
    );
  }
}
