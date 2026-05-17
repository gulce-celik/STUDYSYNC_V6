import 'package:flutter/material.dart';

import '../../../../core/campus/campus_layout_generator.dart';
import '../../../reservation/domain/reservation_models.dart';

/// Mini map preview for admin layout sliders — same grid as student Reserve.
class AdminMapLayoutPreview extends StatelessWidget {
  const AdminMapLayoutPreview({
    super.key,
    required this.individualDesks,
    required this.groupRooms,
  });

  final int individualDesks;
  final int groupRooms;

  @override
  Widget build(BuildContext context) {
    final workspaces = CampusLayoutGenerator.build(
      individualCount: individualDesks,
      groupCount: groupRooms,
    );
    final mapW = CampusLayoutGenerator.mapWidth;
    final mapH = CampusLayoutGenerator.mapHeightFor(
      individualCount: individualDesks,
      groupCount: groupRooms,
    );
    final deskRows = individualDesks == 0 ? 0 : (individualDesks + 7) ~/ 8;
    final groupLabelY = 35.0 + deskRows * 65 + 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Preview', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(width: 8),
            Text(
              '$individualDesks desks · $groupRooms rooms',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 148,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: mapW,
                height: mapH,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Individual desks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    if (groupRooms > 0)
                      Positioned(
                        top: groupLabelY,
                        left: 0,
                        right: 0,
                        child: Text(
                          'Group rooms',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ...workspaces.map(_workspaceTile),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Blue = desk · Purple = group room. Matches student Reserve after Apply.',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500, height: 1.3),
        ),
      ],
    );
  }

  Widget _workspaceTile(Workspace ws) {
    final isDesk = ws.type == 'individual';
    final w = isDesk ? 35.0 : 70.0;
    final h = isDesk ? 50.0 : 100.0;
    final occupied = ws.status == 'occupied';
    final fill = isDesk
        ? (occupied ? const Color(0xFF94A3B8) : const Color(0xFF2563EB))
        : (occupied ? const Color(0xFFC084FC) : const Color(0xFF9333EA));

    return Positioned(
      left: ws.x.toDouble(),
      top: ws.y.toDouble(),
      width: w,
      height: h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(isDesk ? 3 : 6),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: isDesk
            ? null
            : Center(
                child: Text(
                  ws.id.replaceFirst('group-', 'G'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
              ),
      ),
    );
  }
}
