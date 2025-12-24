import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/profile_api.dart';
import '../../../../../services/storage/token_storage.dart';
import '../../../auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ProfileViewData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<_ProfileViewData> _loadProfile() async {
    final api = injector<ProfileApi>();
    final profileJson = await api.getProfile();
    final metrics = await api.getProfileMetrics();

    return _ProfileViewData(
      name: profileJson['name'] as String?,
      email: profileJson['email'] as String?,
      gender: profileJson['gender'] as String?,
      age: (profileJson['age'] as num?)?.toInt(),
      weight: metrics.weight,
      height: metrics.height,
      bmi: metrics.bmi,
      bmr: metrics.bmr,
      tdee: metrics.tdee,
      calorieGoal: metrics.calorieGoal,
      weightGoal: metrics.weightGoal,
      goalType: metrics.goalType,
    );
  }

  void _onRetry() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<void> _onLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
            actions: <Widget>[
              TextButton(
                  onPressed: ()=> Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
              ),
              TextButton(
                  onPressed: ()=> Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Đăng xuất'),
              ),
            ],
          );
        },
    );
    if (shouldLogout == true){
      await injector<TokenStorage>().clear();
      if(mounted){
        Navigator.pushNamedAndRemoveUntil(
            context,
            LoginScreen.routeName,
            (route)=>false);
      }
    }
  }

  Future<void> _showEditDialog(_ProfileViewData current) async {
    final nameCtrl = TextEditingController(text: current.name ?? '');
    final ageCtrl = TextEditingController(
      text: current.age != null ? current.age.toString() : '',
    );
    String genderValue = (current.gender ?? 'male').toLowerCase();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1E1D),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chỉnh sửa thông tin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: nameCtrl,
                      label: 'Họ và tên',
                      hint: 'Nhập tên của bạn',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: ageCtrl,
                      label: 'Tuổi',
                      hint: 'Ví dụ: 25',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
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
                          value: genderValue,
                          dropdownColor: const Color(0xFF1C1E1D),
                          iconEnabledColor: Colors.white70,
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Nam'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Nữ'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                genderValue = value;
                              });
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        onPressed: () async {
                          try {
                            final api = injector<ProfileApi>();
                            final ageVal = int.tryParse(ageCtrl.text.trim());
                            await api.updateProfile(
                              name: nameCtrl.text.trim().isEmpty
                                  ? null
                                  : nameCtrl.text.trim(),
                              gender: genderValue,
                              age: ageVal,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã cập nhật thông tin'),
                                  backgroundColor: Color(0xFF52C41A),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                            setState(() {
                              _profileFuture = _loadProfile();
                            });
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      body: SafeArea(
        child: FutureBuilder<_ProfileViewData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF52C41A),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorState(snapshot.error?.toString());
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Header(onBack: () => Navigator.maybePop(context)),
                  const SizedBox(height: 24),
                  _Identity(name: data.name, email: data.email),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Các chỉ số sức khỏe'),
                  const SizedBox(height: 12),
                  _StatGrid(data: data),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Tuổi',
                    value: data.age != null ? '${data.age} tuổi' : '--',
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    title: 'Giới tính',
                    value: _formatGender(data.gender),
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    title: 'Cân nặng mục tiêu',
                    value: data.weightGoal != null ? '${data.weightGoal!.toStringAsFixed(1)} kg' : '--',
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    title: 'Mục tiêu',
                    value: data.goalTypeDisplay,
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    title: 'Ước tính hoàn thành',
                    value: _estimateGoalEta(data),
                  ),
                  const SizedBox(height: 20),
                  _PrimaryButton(
                    icon: Icons.edit_rounded,
                    label: 'Chỉnh sửa thông tin',
                    onPressed: () => _showEditDialog(data),
                  ),
                  const SizedBox(height: 12),
                  _DangerButton(
                    label: 'Đăng xuất',
                    onPressed: _onLogout,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatGender(String? gender) {
    switch ((gender ?? '').toLowerCase()) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      default:
        return '--';
    }
  }

  String _estimateGoalEta(_ProfileViewData data) {
    final double? weight = data.weight;
    final double? weightGoal = data.weightGoal;
    final int? tdee = data.tdee;
    final int? calorieGoal = data.calorieGoal;
    final String goal = (data.goalType ?? '').toLowerCase();

    if (weight == null || weightGoal == null || tdee == null || calorieGoal == null) {
      return '--';
    }

    const double kcalPerKg = 7700.0;
    double deltaKg;
    double dailyGap;

    if (goal == 'lose') {
      deltaKg = weight - weightGoal;
      dailyGap = (tdee - calorieGoal).toDouble();
      if (deltaKg <= 0 || dailyGap <= 200) return '--'; // không đủ chênh lệch hoặc đã đạt
    } else if (goal == 'gain' || goal == 'muscle_gain') {
      deltaKg = weightGoal - weight;
      dailyGap = (calorieGoal - tdee).toDouble();
      if (deltaKg <= 0 || dailyGap <= 150) return '--';
    } else {
      return '--';
    }

    final days = (deltaKg * kcalPerKg) / dailyGap;
    if (days.isNaN || days.isInfinite || days <= 0) return '--';

    if (days < 14) {
      return '~${days.ceil()} ngày';
    }
    final weeks = (days / 7).ceil();
    return '~$weeks tuần';
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 36),
            const SizedBox(height: 12),
            Text(
              'Không tải được thông tin',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error ?? 'Đã có lỗi xảy ra',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52C41A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _onRetry,
              child: const Text(
                'Thử lại',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
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
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        const Text(
          'Hồ sơ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.name, required this.email});

  final String? name;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name ?? 'Chưa có tên',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          email ?? '---',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.data});

  final _ProfileViewData data;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard('Cân nặng', data.weight != null ? '${data.weight!.toStringAsFixed(1)} kg' : '--'),
      _StatCard('Chiều cao', data.height != null ? '${data.height!.toStringAsFixed(0)} cm' : '--'),
      _StatCard('BMI', data.bmi != null ? data.bmi!.toStringAsFixed(1) : '--'),
      _StatCard('BMR', data.bmr != null ? '${data.bmr} kcal' : '--'),
      _StatCard('TDEE', data.tdee != null ? '${data.tdee} kcal' : '--'),
      _StatCard('Mục tiêu/ngày', data.calorieGoal != null ? '${data.calorieGoal} kcal' : '--'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: cards,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.title, this.value);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2C2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E1D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2C2B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C1E1D),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF2A2C2B)),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _ProfileViewData {
  final String? name;
  final String? email;
  final String? gender;
  final int? age;
  final double? weight;
  final double? height;
  final double? bmi;
  final int? bmr;
  final int? tdee;
  final int? calorieGoal;
  final double? weightGoal;
  final String? goalType;

  _ProfileViewData({
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.calorieGoal,
    required this.weightGoal,
    required this.goalType,
  });

  String get goalTypeDisplay {
    switch ((goalType ?? '').toLowerCase()) {
      case 'lose':
        return 'Giảm cân';
      case 'gain':
        return 'Tăng cân';
      case 'muscle_gain':
        return 'Tăng cơ';
      case 'maintain':
        return 'Duy trì';
      default:
        return '--';
    }
  }
}


