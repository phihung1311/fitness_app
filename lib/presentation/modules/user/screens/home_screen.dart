import 'package:flutter/material.dart';
import '../widgets/center_fab_icon.dart';
import '../widgets/dashboard_overview.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _pageTitles = [
    'Tổng quan',
    'Món ăn',
    'Bài tập',
    'Thông báo',
    'Cá nhân',
  ];

  final List<Widget> _screens = const [
    DashboardOverview(),
    Center(child: Text('Món ăn')), // Placeholder for FoodScreen
    Center(child: Text('Bài tập')), // Placeholder for WorkoutScreen
    Center(child: Text('Thông báo')), // Placeholder for NotificationScreen
    Center(child: Text('Cá nhân')), // Placeholder for ProfileScreen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex == 0 ? Colors.green.shade800 : Colors.white,
      appBar: _selectedIndex == 0
          ? null // Ẩn AppBar cho trang chủ để gradient full màn hình
          : AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade800,
              elevation: 0,
              title: Text(
                _pageTitles[_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
      drawer: _selectedIndex == 0 ? null : const AppDrawer(), // Ẩn drawer cho trang chủ
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Món ăn',
          ),
          BottomNavigationBarItem(
            icon: CenterFabIcon(isActive: _selectedIndex==2),
            label: 'Bài tập',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
