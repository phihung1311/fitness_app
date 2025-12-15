import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/profile_api.dart';
import '../../../../../domain/usecases/profile/get_profile_metrics.dart';
import '../../../../../services/storage/token_storage.dart';
import '../../../auth/screens/login_screen.dart';
import '../home_screen.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  static const routeName = '/onboarding-profile';

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _weightGoalCtrl = TextEditingController();

  String _gender = 'male';
  String _goalType = 'lose';
  String _activityLevel = 'moderate';
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _weightGoalCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _submitting) return;

    setState(() => _submitting = true);
    try {
      final api = injector<ProfileApi>();
      await api.onboardingProfile(
        name: _nameCtrl.text.trim(),
        gender: _gender,
        age: int.parse(_ageCtrl.text.trim()),
        height: double.parse(_heightCtrl.text.trim()),
        weight: double.parse(_weightCtrl.text.trim()),
        weightGoal: double.parse(_weightGoalCtrl.text.trim()),
        goalType: _goalType,
        activityLevel: _activityLevel,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu hồ sơ ban đầu'),
          backgroundColor: Color(0xFF52C41A),
        ),
      );

      // Sau onboarding, tải metrics một lần cho chắc chắn rồi vào Home
      try {
        await injector<GetProfileMetrics>()();
      } catch (_) {}

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.routeName,
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _logout() async {
    await injector<TokenStorage>().clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hoàn tất hồ sơ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _logout,
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Nhập thông tin để tính TDEE và mục tiêu calo cá nhân',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameCtrl,
                      label: 'Họ và tên',
                      keyboardType: TextInputType.name,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập họ tên' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Giới tính',
                      value: _gender,
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Nam')),
                        DropdownMenuItem(value: 'female', child: Text('Nữ')),
                      ],
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _ageCtrl,
                      label: 'Tuổi',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Nhập tuổi';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return 'Tuổi không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _heightCtrl,
                      label: 'Chiều cao (cm)',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Nhập chiều cao';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Chiều cao không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _weightCtrl,
                      label: 'Cân nặng hiện tại (kg)',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Nhập cân nặng';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Cân nặng không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _weightGoalCtrl,
                      label: 'Cân nặng mục tiêu (kg)',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Nhập cân nặng mục tiêu';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Cân nặng mục tiêu không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Mục tiêu',
                      value: _goalType,
                      items: const [
                        DropdownMenuItem(value: 'lose', child: Text('Giảm cân')),
                        DropdownMenuItem(value: 'maintain', child: Text('Duy trì')),
                        DropdownMenuItem(value: 'gain', child: Text('Tăng cân')),
                        DropdownMenuItem(value: 'muscle_gain', child: Text('Tăng cơ')),
                      ],
                      onChanged: (v) => setState(() => _goalType = v!),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Mức độ hoạt động',
                      value: _activityLevel,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Thấp')),
                        DropdownMenuItem(value: 'light', child: Text('Nhẹ')),
                        DropdownMenuItem(value: 'moderate', child: Text('Vừa')),
                        DropdownMenuItem(value: 'high', child: Text('Cao')),
                        DropdownMenuItem(value: 'veryhigh', child: Text('Rất cao')),
                      ],
                      onChanged: (v) => setState(() => _activityLevel = v!),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF52C41A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Lưu và tiếp tục',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        filled: true,
        fillColor: const Color(0xFF1C1E1D),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2C2B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF52C41A)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1E1D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2C2B)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              alignment: Alignment.centerLeft,
              dropdownColor: const Color(0xFF1C1E1D),
              iconEnabledColor: Colors.white70,
              items: items,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

