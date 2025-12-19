import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/auth/screens/login_screen.dart';
import '../modules/auth/screens/register_screen.dart';
import '../modules/user/screens/home_screen.dart';
import '../modules/user/screens/profile/onboarding_profile_screen.dart';
import '../modules/admin/screens/admin_home_screen.dart';
import '../modules/admin/screens/admin_add_food_screen.dart';
import '../modules/admin/screens/admin_edit_food_screen.dart';
import '../modules/admin/bloc/admin_food/admin_food_bloc.dart';
import '../../../domain/entities/food.dart';
import '../../core/di/injector.dart';
import '../guards/admin_route_guard.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RegisterScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case HomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case OnboardingProfileScreen.routeName:
        return MaterialPageRoute(builder: (_) => const OnboardingProfileScreen());
      case AdminHomeScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const AdminRouteGuard(
            child: AdminHomeScreen(),
          ),
        );
      case AdminAddFoodScreen.routeName:
        // BLoC sẽ được truyền từ màn hình trước qua Navigator.push
        // Nếu không có, tạo mới từ injector
        final bloc = settings.arguments as AdminFoodBloc?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc ?? AdminFoodBloc(
              injector(),
              injector(),
              injector(),
              injector(),
            ),
            child: const AdminAddFoodScreen(),
          ),
        );
      case AdminEditFoodScreen.routeName:
        // Arguments: {'food': Food, 'bloc': AdminFoodBloc}
        final args = settings.arguments as Map<String, dynamic>?;
        final food = args?['food'] as Food?;
        final bloc = args?['bloc'] as AdminFoodBloc?;
        
        if (food == null) {
          // Nếu không có Food, quay lại màn hình trước
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Lỗi')),
              body: const Center(child: Text('Không tìm thấy thông tin món ăn')),
            ),
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc ?? AdminFoodBloc(
              injector(),
              injector(),
              injector(),
              injector(),
            ),
            child: AdminEditFoodScreen(food: food),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

