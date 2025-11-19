import 'package:flutter/material.dart';
import 'greeting_section.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingSection(),
            const SizedBox(height: 12),

            // 3 CARD
            Row(
              children: const [
                Expanded(child: _DashCard(icon: Icons.local_fire_department, value: '1300', label: 'Calo hôm nay', color: Colors.orange)),
                SizedBox(width: 10),
                Expanded(child: _DashCard(icon: Icons.fitness_center, value: '40p', label: 'Tập luyện', color: Colors.green)),
                SizedBox(width: 10),
                Expanded(child: _DashCard(icon: Icons.monitor_weight, value: '59.6kg', label: 'Cân nặng', color: Colors.blue)),
              ],
            ),

            const SizedBox(height: 20),

            // 4 NÚT NHANH
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: const [
                _QuickAction(icon: Icons.restaurant, label: 'Thêm bữa ăn', color: Colors.orange),
                _QuickAction(icon: Icons.play_circle, label: 'Tập ngay', color: Colors.green),
                _QuickAction(icon: Icons.bar_chart, label: 'Thống kê', color: Colors.blue),
                _QuickAction(icon: Icons.health_and_safety, label: 'Phân tích sức khoẻ', color: Colors.purple),
              ],
            ),

            const SizedBox(height: 28),

            // THÔNG BÁO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: const [
                  Icon(Icons.notifications_active, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đừng quên uống đủ nước và kiểm tra tiến độ nhé!',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Dự phòng cho bottom bar
          ],
        ),
      ),
    );
  }
}

// Giữ nguyên _DashCard và _QuickAction như cũ
class _DashCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _DashCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}