import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: Colors.green.shade100,
          backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/men/1.jpg'), // Placeholder
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Xin chào, Hưng!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
              SizedBox(height: 2),
              Text('Chúc bạn 1 ngày nhiều năng lượng! 🌞',style: TextStyle(color: Colors.grey,fontSize: 13)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_forward_ios,color: Colors.green,size: 22),
          tooltip: 'Trang cá nhân',
        )
      ],
    );
  }
}
