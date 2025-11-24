import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../bloc/food/food_bloc.dart';
import '../bloc/food/food_event.dart';
import '../bloc/meal/meal_bloc.dart';
import '../bloc/meal/meal_event.dart';
import '../bloc/exercise/exercise_bloc.dart';
import '../bloc/exercise/exercise_event.dart';
import '../bloc/profile_metrics/profile_metrics_bloc.dart';
import '../bloc/profile_metrics/profile_metrics_event.dart';
import '../widgets/dashboard_overview.dart';
import '../widgets/app_drawer.dart';
import 'food/food_library_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'exercise/exercise_library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _pageTitles = [
    'Tổng quan',
    'Món ăn',
    'Dinh dưỡng',
    'Bài tập',
    'Cá nhân',
  ];

  List<Widget> get _screens => [
        DashboardOverview(
          onNavigateToFoodTab: () => setSelectedIndex(1),
          onNavigateToExerciseTab: () => setSelectedIndex(3),
        ),
        BlocProvider(
          create: (context) => FoodBloc(injector())..add(LoadFoods()),
          child: const FoodLibraryScreen(),
        ),
        BlocProvider(
          create: (context) => MealBloc(injector(), injector())..add(LoadTodayMeals()),
          child: const NutritionScreen(),
        ),
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ExerciseBloc(injector())..add(LoadExercises()),
            ),
            BlocProvider(
              create: (context) => ProfileMetricsBloc(injector())..add(LoadProfileMetrics()),
            ),
          ],
          child: const ExerciseLibraryScreen(),
        ),
        const Center(child: Text('Cá nhân')),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3
          ? const Color(0xFF0D0F0E)
          : Colors.white,
      appBar: _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade800,
              elevation: 0,
              title: Text(
                _pageTitles[_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
      drawer: _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3
          ? null 
          : const AppDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1E1D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Trang chủ'),
                _buildNavItem(1, Icons.restaurant_menu_rounded, 'Món ăn'),
                _buildNavItem(2, Icons.local_fire_department_rounded, 'Dinh dưỡng'),
                _buildNavItem(3, Icons.fitness_center_rounded, 'Bài tập'),
                _buildNavItem(4, Icons.person_rounded, 'Cá nhân'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF52C41A).withOpacity(0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFF52C41A) 
                  : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? const Color(0xFF52C41A) 
                    : Colors.grey.shade400,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
