import 'package:flutter/material.dart';

import '../../../../core/campus/campus_layout_store.dart';
import 'admin_map_layout_preview.dart';
import 'admin_ui.dart';

class AdminMapLayoutCard extends StatefulWidget {
  const AdminMapLayoutCard({super.key});

  @override
  State<AdminMapLayoutCard> createState() => _AdminMapLayoutCardState();
}

class _AdminMapLayoutCardState extends State<AdminMapLayoutCard> {
  late int _desks;
  late int _groups;

  @override
  void initState() {
    super.initState();
    final s = CampusLayoutStore.instance;
    _desks = s.individualDesks;
    _groups = s.groupRooms;
  }

  void _apply() {
    CampusLayoutStore.instance.applyLayout(
      individualDesks: _desks,
      groupRooms: _groups,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Map updated: $_desks desks, $_groups group rooms. Students see this on Reserve.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = CampusLayoutStore.instance;

    return AdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Map layout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            'How many spaces appear on the booking map and student Reserve screen.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.35),
          ),
          const SizedBox(height: 4),
          Text(
            'Active: ${store.individualDesks} individual · ${store.groupRooms} group',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF)),
          ),
          const SizedBox(height: 14),
          Text('Individual desks: $_desks', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Slider(
            value: _desks.toDouble(),
            min: CampusLayoutStore.minIndividualDesks.toDouble(),
            max: CampusLayoutStore.maxIndividualDesks.toDouble(),
            divisions: CampusLayoutStore.maxIndividualDesks - CampusLayoutStore.minIndividualDesks,
            label: '$_desks',
            onChanged: (v) => setState(() => _desks = v.round()),
          ),
          Text('Group rooms: $_groups', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Slider(
            value: _groups.toDouble(),
            min: CampusLayoutStore.minGroupRooms.toDouble(),
            max: CampusLayoutStore.maxGroupRooms.toDouble(),
            divisions: CampusLayoutStore.maxGroupRooms - CampusLayoutStore.minGroupRooms,
            label: '$_groups',
            onChanged: (v) => setState(() => _groups = v.round()),
          ),
          const SizedBox(height: 12),
          AdminMapLayoutPreview(individualDesks: _desks, groupRooms: _groups),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: _apply,
              child: const Text('Apply layout', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
