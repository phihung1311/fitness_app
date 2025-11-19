import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(top: 48, left:12, right: 12),
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
          ),
          const SizedBox(height: 12),
          const Text('Hưng Nguyễn', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          const SizedBox(height: 2),
          const Text('user@example.com'),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
