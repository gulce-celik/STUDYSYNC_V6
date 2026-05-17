import 'package:flutter/material.dart';

/// Prominent yellow lost-item marker for desk / group cells on maps.
class LostMapBadge extends StatelessWidget {
  const LostMapBadge({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFB45309), width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x99F59E0B), blurRadius: 8, spreadRadius: 1, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(Icons.warning_amber_rounded, size: size * 0.72, color: const Color(0xFF78350F)),
    );
  }
}
