import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../services/storage/role_storage.dart';
import '../../../../services/storage/token_storage.dart';
import '../../auth/screens/login_screen.dart';
import 'food/admin_food_management_screen.dart';
import 'exercise/admin_exercise_management_screen.dart';
import 'user/admin_user_management_screen.dart';
import 'plan/admin_plan_management_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const String routeName = '/admin/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1E1D),
        title: const Text(
          'Trang quản lý',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => _onLogout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Chào mừng Admin!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildMenuCard(
              context,
              icon: Icons.restaurant,
              title: 'Quản lý thực phẩm',
              description: 'Thêm, sửa, xóa thực phẩm',
              onTap: () {
                Navigator.of(context).pushNamed(AdminFoodManagementScreen.routeName);
              },
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.fitness_center,
              title: 'Quản lý bài tập',
              description: 'Thêm, sửa, xóa bài tập',
              onTap: () {
                Navigator.of(context).pushNamed(AdminExerciseManagementScreen.routeName);
              },
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.people,
              title: 'Quản lý tài khoản',
              description: 'Xem, phân quyền, khóa tài khoản',
              onTap: () {
                Navigator.of(context).pushNamed(AdminUserManagementScreen.routeName);
              },
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: Icons.calendar_today,
              title: 'Quản lý kế hoạch',
              description: 'Tạo và quản lý kế hoạch mẫu',
              onTap: () {
                Navigator.of(context).pushNamed(AdminPlanManagementScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1C1E1D),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF52C41A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF52C41A), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
            const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await injector<TokenStorage>().clear();
      await injector<RoleStorage>().clear();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (route) => false,
        );
      }
    }
  }
}

