import '../../features/reservation/domain/reservation_models.dart';

/// Auto-places desks and group rooms on a simple grid (any building / library).
abstract final class CampusLayoutGenerator {
  static const double mapWidth = 330;
  static const int _cols = 8;
  static const int _deskCellW = 40;
  static const int _deskCellH = 65;
  static const int _originX = 12;
  static const int _originY = 35;

  static double mapHeightFor({required int individualCount, required int groupCount}) {
    final deskRows = individualCount == 0 ? 0 : (individualCount + _cols - 1) ~/ _cols;
    final groupY = _originY + deskRows * _deskCellH + (groupCount > 0 ? 15 : 0);
    return groupY + (groupCount > 0 ? 110 : 40);
  }

  static List<Workspace> build({
    required int individualCount,
    required int groupCount,
  }) {
    final desks = List<Workspace>.generate(individualCount, (i) {
      final demoOccupied = individualCount > 6 && (i == 0 || i == 6 || i == individualCount - 1);
      return Workspace(
        id: 'desk-${i + 1}',
        type: 'individual',
        capacity: 1,
        status: demoOccupied ? 'occupied' : 'available',
        x: _originX + (i % _cols) * _deskCellW,
        y: _originY + (i ~/ _cols) * _deskCellH,
      );
    });

    if (groupCount == 0) return desks;

    final deskRows = (individualCount + _cols - 1) ~/ _cols;
    final groupY = _originY + deskRows * _deskCellH + 15;
    final groups = List<Workspace>.generate(groupCount, (i) {
      final x = groupCount <= 1
          ? _originX
          : _originX + (i * ((mapWidth - 82) / (groupCount - 1))).round();
      return Workspace(
        id: 'group-${i + 1}',
        type: 'group',
        capacity: 4 + (i % 2) * 2,
        status: i == 1 && groupCount > 1 ? 'occupied' : 'available',
        x: x,
        y: groupY,
      );
    });

    return [...desks, ...groups];
  }
}
