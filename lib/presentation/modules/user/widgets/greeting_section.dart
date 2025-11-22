import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  final String? userName;
  
  const GreetingSection({super.key, this.userName});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String _getDisplayName() {
    if (userName != null && userName!.isNotEmpty) {
      // Lấy tên đầu tiên nếu có nhiều từ
      return userName!.split(' ').last;
    }
    return 'Bạn';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.green.shade100,
          backgroundImage: const NetworkImage(
            'https://randomuser.me/api/portraits/men/1.jpg',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, ${_getDisplayName()}!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings, color: Colors.white, size: 26),
          tooltip: 'Cài đặt',
        ),
      ],
    );
  }
}
