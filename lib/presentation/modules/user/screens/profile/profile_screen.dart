import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../data/datasources/remote/profile_api.dart';
import '../../../../../services/storage/token_storage.dart';
import '../../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileViewData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<ProfileViewData> _loadProfile() async {
    final api = injector<ProfileApi>();
    final profileJson = await api.getProfile();
    final metrics = await api.getProfileMetrics();

    return ProfileViewData(
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

  Future<void> _navigateToEditProfile(ProfileViewData current) async {
    final result = await Navigator.of(context).pushNamed(
      EditProfileScreen.routeName,
      arguments: current,
    );

    if (result == true && mounted) {
      setState(() {
        _profileFuture = _loadProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      body: SafeArea(
        child: FutureBuilder<ProfileViewData>(
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
                    onPressed: () => _navigateToEditProfile(data),
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

  String _estimateGoalEta(ProfileViewData data) {
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
          'Hồ sơ cá nhân',
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

  final ProfileViewData data;

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

// Export để có thể sử dụng ở các file khác
class ProfileViewData {
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

  ProfileViewData({
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


