import 'package:flutter/material.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/profile_api.dart';
import '../../../../../data/datasources/remote/progress_api.dart';
import 'profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileViewData? initialData;

  const EditProfileScreen({
    super.key,
    this.initialData,
  });

  static const routeName = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightGoalCtrl = TextEditingController();

  String _gender = 'male';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameCtrl.text = widget.initialData!.name ?? '';
      _ageCtrl.text = widget.initialData!.age?.toString() ?? '';
      _weightCtrl.text = widget.initialData!.weight?.toStringAsFixed(1) ?? '';
      _heightCtrl.text = widget.initialData!.height?.toStringAsFixed(0) ?? '';
      _weightGoalCtrl.text = widget.initialData!.weightGoal?.toStringAsFixed(1) ?? '';
      _gender = (widget.initialData!.gender ?? 'male').toLowerCase();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _weightGoalCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final profileApi = injector<ProfileApi>();
      final progressApi = injector<ProgressApi>();

      await profileApi.updateProfile(
        name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        gender: _gender,
        age: int.tryParse(_ageCtrl.text.trim()),
      );

      final weight = double.tryParse(_weightCtrl.text.trim());
      final height = double.tryParse(_heightCtrl.text.trim());
      
      if (weight != null && height != null && weight > 0 && height > 0) {
        await progressApi.updateProgress(
          weight: weight,
          height: height,
        );
      }

      final weightGoal = double.tryParse(_weightGoalCtrl.text.trim());
      if (weightGoal != null && weightGoal > 0) {
        await profileApi.updateWeightGoal(weightGoal: weightGoal);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật thông tin thành công'),
          backgroundColor: Color(0xFF52C41A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F0E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nameCtrl,
                  label: 'Họ và tên',
                  hint: 'Nhập tên của bạn',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ageCtrl,
                  label: 'Tuổi',
                  hint: 'Ví dụ: 25',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tuổi';
                    }
                    final age = int.tryParse(value.trim());
                    if (age == null || age < 1 || age > 150) {
                      return 'Tuổi không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Giới tính',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0F0E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2C2B)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _gender,
                      dropdownColor: const Color(0xFF1C1E1D),
                      iconEnabledColor: Colors.white70,
                      items: const [
                        DropdownMenuItem(
                          value: 'male',
                          child: Text('Nam', style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Nữ', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _gender = value;
                          });
                        }
                      },
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF2A2C2B)),
                const SizedBox(height: 16),
                const Text(
                  'Cân nặng & Chiều cao',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cập nhật để hệ thống tự động tính lại BMR, TDEE và Calorie Goal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _weightCtrl,
                        label: 'Cân nặng (kg)',
                        hint: 'Ví dụ: 70.0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null; // Optional
                          }
                          final weight = double.tryParse(value.trim());
                          if (weight == null || weight <= 0 || weight > 500) {
                            return 'Cân nặng không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _heightCtrl,
                        label: 'Chiều cao (cm)',
                        hint: 'Ví dụ: 170',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null; // Optional
                          }
                          final height = double.tryParse(value.trim());
                          if (height == null || height <= 0 || height > 300) {
                            return 'Chiều cao không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF2A2C2B)),
                const SizedBox(height: 16),
                const Text(
                  'Mục tiêu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _weightGoalCtrl,
                  label: 'Cân nặng mục tiêu (kg)',
                  hint: 'Ví dụ: 65.0',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // Optional
                    }
                    final weightGoal = double.tryParse(value.trim());
                    if (weightGoal == null || weightGoal <= 0 || weightGoal > 500) {
                      return 'Cân nặng mục tiêu không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF52C41A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            filled: true,
            fillColor: const Color(0xFF0D0F0E),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2C2B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF52C41A)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

