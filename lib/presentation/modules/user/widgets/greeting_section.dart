import 'package:flutter/material.dart';
import '../../../routes/app_router.dart';
import '../screens/statistics/statistics_screen.dart';

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
    if (userName != null && userName!.trim().isNotEmpty) {
      // Lấy từ cuối cùng (thường là tên chính)
      return userName!.trim().split(' ').last;
    }
    return 'Bạn';
  }

  String _getInitialLetter() {
    final displayName = _getDisplayName();
    if (displayName.isNotEmpty) {
      // Lấy chữ cái đầu, chuyển thành in hoa
      return displayName[0].toUpperCase();
    }
    return 'B'; // fallback
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.green.shade100,
          child: Text(
            _getInitialLetter(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
          onPressed: () {
            Navigator.of(context).pushNamed(StatisticsScreen.routeName);
          },
          icon: const Icon(Icons.stacked_bar_chart, color: Colors.white, size: 26),
          tooltip: 'Thống kê',
        ),
      ],
    );
  }
}