import 'package:fitness_app/presentation/modules/admin/screens/food/admin_food_management_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../modules/admin/bloc/admin_food/admin_food_bloc.dart';
import '../modules/auth/screens/login_screen.dart';
import '../modules/auth/screens/register_screen.dart';
import '../modules/user/screens/home_screen.dart';
import '../modules/user/screens/profile/onboarding_profile_screen.dart';
import '../modules/user/screens/profile/edit_profile_screen.dart';
import '../modules/admin/screens/admin_home_screen.dart';
import '../modules/admin/screens/food/admin_add_food_screen.dart';
import '../modules/admin/screens/food/admin_edit_food_screen.dart';
import '../modules/admin/screens/exercise/admin_exercise_management_screen.dart';
import '../modules/admin/screens/exercise/admin_add_exercise_screen.dart';
import '../modules/admin/screens/exercise/admin_edit_exercise_screen.dart';
import '../modules/admin/screens/user/admin_user_management_screen.dart';
import '../modules/admin/screens/user/admin_user_detail_screen.dart';
import '../modules/admin/bloc/exercise/admin_exercise_bloc.dart';
import '../modules/user/screens/statistics/statistics_screen.dart';
import '../../../domain/entities/food.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/user.dart';
import '../../core/di/injector.dart';
import '../guards/admin_route_guard.dart';
import '../modules/user/screens/profile/profile_screen.dart' show ProfileViewData;

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
      case AdminFoodManagementScreen.routeName:
        return MaterialPageRoute(
            builder: (_)=> const AdminFoodManagementScreen(),
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
      case AdminExerciseManagementScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const AdminExerciseManagementScreen(),
        );
      case AdminAddExerciseScreen.routeName:
        final bloc = settings.arguments as AdminExerciseBloc?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc ?? AdminExerciseBloc(
              injector(),
              injector(),
              injector(),
              injector(),
            ),
            child: const AdminAddExerciseScreen(),
          ),
        );
      case AdminEditExerciseScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        final exercise = args?['exercise'] as Exercise?;
        final bloc = args?['bloc'] as AdminExerciseBloc?;
        
        if (exercise == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Lỗi')),
              body: const Center(child: Text('Không tìm thấy thông tin bài tập')),
            ),
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc ?? AdminExerciseBloc(
              injector(),
              injector(),
              injector(),
              injector(),
            ),
            child: AdminEditExerciseScreen(exercise: exercise),
          ),
        );
      case AdminUserManagementScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const AdminUserManagementScreen(),
        );
      case AdminUserDetailScreen.routeName:
        final user = settings.arguments as User?;
        if (user == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Lỗi')),
              body: const Center(child: Text('Không tìm thấy thông tin user')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AdminUserDetailScreen(user: user),
        );
      case StatisticsScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const StatisticsScreen(),
        );
      case EditProfileScreen.routeName:
        final profileData = settings.arguments as ProfileViewData?;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(initialData: profileData),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

