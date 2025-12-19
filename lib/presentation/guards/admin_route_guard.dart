import 'package:flutter/material.dart';
import '../../core/di/injector.dart';
import '../../services/storage/role_storage.dart';
import '../modules/user/screens/home_screen.dart';

/// Guard để kiểm tra quyền admin trước khi vào màn admin
/// Nếu không phải admin → redirect về HomeScreen của User
class AdminRouteGuard extends StatelessWidget {
  final Widget child;

  const AdminRouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final roleStorage = injector<RoleStorage>();
    
    if (!roleStorage.isAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn không có quyền truy cập'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return const SizedBox.shrink();
    }
    
    return child;
  }
}

