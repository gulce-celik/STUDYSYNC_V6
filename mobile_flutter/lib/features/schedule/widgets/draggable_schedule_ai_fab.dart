import 'package:flutter/material.dart';

/// Draggable sparkle FAB — stays out of the way of the schedule grid.
class DraggableScheduleAiFab extends StatefulWidget {
  const DraggableScheduleAiFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<DraggableScheduleAiFab> createState() => _DraggableScheduleAiFabState();
}

class _DraggableScheduleAiFabState extends State<DraggableScheduleAiFab> {
  Offset? _position;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final size = MediaQuery.sizeOf(context);
      final padding = MediaQuery.paddingOf(context);
      _position = Offset(size.width - 76, size.height - padding.bottom - 160);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null) return const SizedBox.shrink();

    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final minX = 8.0;
    final minY = padding.top + 72;
    final maxX = size.width - 64;
    final maxY = size.height - padding.bottom - 88;

    return Positioned(
      left: _position!.dx.clamp(minX, maxX),
      top: _position!.dy.clamp(minY, maxY),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final next = _position! + details.delta;
            _position = Offset(
              next.dx.clamp(minX, maxX),
              next.dy.clamp(minY, maxY),
            );
          });
        },
        onTap: widget.onTap,
        child: Material(
          elevation: 8,
          shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.35),
          shape: const CircleBorder(),
          color: const Color(0xFF2563EB),
          child: const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
