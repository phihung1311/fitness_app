import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/plan/admin_plan_bloc.dart';
import '../../bloc/plan/admin_plan_event.dart';
import '../../bloc/plan/admin_plan_state.dart';

class AdminCreatePlanScreen extends StatefulWidget {
  const AdminCreatePlanScreen({super.key});

  static const String routeName = '/admin/create-plan';

  @override
  State<AdminCreatePlanScreen> createState() => _AdminCreatePlanScreenState();
}

class _AdminCreatePlanScreenState extends State<AdminCreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetWeightChangeController = TextEditingController();
  final _durationDaysController = TextEditingController();
  final _targetCaloriesController = TextEditingController();

  String _selectedGoalType = 'lose';
  String _selectedLevel = 'medium';
  String _selectedActivityLevel = 'moderate';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetWeightChangeController.dispose();
    _durationDaysController.dispose();
    _targetCaloriesController.dispose();
    super.dispose();
  }

  void _submit(BuildContext blocContext) {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Parse values
    final targetWeightChange = double.tryParse(_targetWeightChangeController.text.replaceAll(',', '.'));
    final durationDays = int.tryParse(_durationDaysController.text);
    final targetCalories = _targetCaloriesController.text.trim().isEmpty
        ? null
        : int.tryParse(_targetCaloriesController.text);

    // Validate parsed values
    if (targetWeightChange == null || durationDays == null) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập thay đổi cân nặng và số ngày hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate name
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên kế hoạch'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dispatch event
    blocContext.read<AdminPlanBloc>().add(
          CreateTemplatePlanEvent(
            name: name,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            goalType: _selectedGoalType,
            targetWeightChange: targetWeightChange,
            durationDays: durationDays,
            level: _selectedLevel,
            activityLevel: _selectedActivityLevel,
            targetCalories: targetCalories,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminPlanBloc(),
      child: Builder(
        builder: (blocContext) => Scaffold(
          backgroundColor: const Color(0xFF0D0F0E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1C1E1D),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Tạo kế hoạch mẫu',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
                // Quay lại sau 1 giây
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) Navigator.of(context).pop(true);
                });
              }
            },
            builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tên kế hoạch
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Tên kế hoạch *', 'VD: Giảm 2kg trong 3 tuần'),
                      validator: (value) => value?.trim().isEmpty == true ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    // Mô tả
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: _buildInputDecoration('Mô tả (tùy chọn)', 'Kế hoạch giảm cân an toàn...'),
                    ),
                    const SizedBox(height: 16),
                    // Mục tiêu
                    DropdownButtonFormField<String>(
                      value: _selectedGoalType,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: const Color(0xFF1C1E1D),
                      decoration: _buildInputDecoration('Mục tiêu *', null),
                      items: const [
                        DropdownMenuItem(value: 'lose', child: Text('Giảm cân', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'gain', child: Text('Tăng cân', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'muscle_gain', child: Text('Tăng cơ', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'maintain', child: Text('Duy trì', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (value) => setState(() => _selectedGoalType = value!),
                    ),
                    const SizedBox(height: 16),
                    // Thay đổi cân nặng
                    TextFormField(
                      controller: _targetWeightChangeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        'Thay đổi cân nặng (kg) *',
                        _selectedGoalType == 'lose' ? '-2.0' : '2.0',
                      ),
                      validator: (value) {
                        if (value?.trim().isEmpty == true) return 'Vui lòng nhập';
                        final val = double.tryParse(value!.replaceAll(',', '.'));
                        if (val == null) return 'Phải là số';
                        if (_selectedGoalType == 'lose' && val >= 0) return 'Phải là số âm';
                        if (_selectedGoalType != 'lose' && val <= 0) return 'Phải là số dương';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Số ngày
                    TextFormField(
                      controller: _durationDaysController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Số ngày *', '21'),
                      validator: (value) {
                        if (value?.trim().isEmpty == true) return 'Vui lòng nhập';
                        final val = int.tryParse(value!);
                        if (val == null || val <= 0) return 'Phải là số nguyên dương';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Độ khó
                    DropdownButtonFormField<String>(
                      value: _selectedLevel,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: const Color(0xFF1C1E1D),
                      decoration: _buildInputDecoration('Độ khó *', null),
                      items: const [
                        DropdownMenuItem(value: 'easy', child: Text('Dễ', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'medium', child: Text('Trung bình', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'hard', child: Text('Khó', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (value) => setState(() => _selectedLevel = value!),
                    ),
                    const SizedBox(height: 16),
                    // Mức độ hoạt động
                    DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: const Color(0xFF1C1E1D),
                      decoration: _buildInputDecoration('Mức độ hoạt động (tùy chọn)', null),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Thấp', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'light', child: Text('Nhẹ', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'moderate', child: Text('Trung bình', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'high', child: Text('Cao', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'veryhigh', child: Text('Rất cao', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (value) => setState(() => _selectedActivityLevel = value!),
                    ),
                    const SizedBox(height: 16),
                    // Target calories (optional)
                    TextFormField(
                      controller: _targetCaloriesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Target calories (tùy chọn, để trống = tự động)', '1500'),
                    ),
                    const SizedBox(height: 32),
                    // Nút tạo
                    ElevatedButton(
                      onPressed: state.isSubmitting ? null : () => _submit(blocContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52C41A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Tạo kế hoạch',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
    );
  }
}
