import 'package:flutter/foundation.dart';

import '../../features/reservation/domain/reservation_models.dart';
import 'campus_layout_generator.dart';

/// Campus map layout (desk / group counts) — session until admin floor-plan APIs exist.
class CampusLayoutStore extends ChangeNotifier {
  CampusLayoutStore._();
  static final CampusLayoutStore instance = CampusLayoutStore._();

  static const int minIndividualDesks = 4;
  static const int maxIndividualDesks = 40;
  static const int minGroupRooms = 0;
  static const int maxGroupRooms = 8;

  int individualDesks = 24;
  int groupRooms = 4;
  String venueLabel = 'Main study hall';

  double get mapWidth => CampusLayoutGenerator.mapWidth;

  double get mapHeight => CampusLayoutGenerator.mapHeightFor(
        individualCount: individualDesks,
        groupCount: groupRooms,
      );

  List<Workspace> get workspaces => CampusLayoutGenerator.build(
        individualCount: individualDesks,
        groupCount: groupRooms,
      );

  /// Instant-book demo desks (2nd desk and last desk when possible).
  List<String> get instantDeskIds {
    if (individualDesks < 2) return const [];
    return ['desk-2', 'desk-$individualDesks'];
  }

  bool workspaceExists(String workspaceId) {
    for (final w in workspaces) {
      if (w.id == workspaceId) return true;
    }
    return false;
  }

  void applyLayout({
    required int individualDesks,
    required int groupRooms,
    String? venueLabel,
  }) {
    this.individualDesks = individualDesks.clamp(minIndividualDesks, maxIndividualDesks);
    this.groupRooms = groupRooms.clamp(minGroupRooms, maxGroupRooms);
    if (venueLabel != null && venueLabel.trim().isNotEmpty) {
      this.venueLabel = venueLabel.trim();
    }
    notifyListeners();
  }
}
