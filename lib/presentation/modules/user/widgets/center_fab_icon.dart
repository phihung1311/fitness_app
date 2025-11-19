import 'package:flutter/material.dart';

class CenterFabIcon extends StatelessWidget {
  final bool isActive;
  const CenterFabIcon({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade700 : Colors.green.shade400,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [BoxShadow(
                color: Colors.greenAccent.withOpacity(0.6),
                blurRadius: 16,
                spreadRadius: 3)]
            : [],
      ),
      padding: const EdgeInsets.all(9),
      child: Icon(Icons.fitness_center,
          size: 28, color: Colors.white),
    );
  }
}
