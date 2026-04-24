import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../reservation/data/reservation_mock_data.dart';
import '../../reservation/domain/reservation_models.dart';
import '../data/lost_found_api.dart';

class _LostRow {
  const _LostRow({
    required this.id,
    required this.workspaceId,
    required this.description,
    required this.reportedAt,
    required this.expiresAt,
  });

  final String id;
  final String workspaceId;
  final String description;
  final String reportedAt;
  final String expiresAt;

  factory _LostRow.fromApi(Map<String, dynamic> m) {
    final reported = m['reportedAt']?.toString() ?? '';
    final rt = DateTime.tryParse(reported) ?? DateTime.now();
    final exp = rt.add(const Duration(hours: 24)).toIso8601String();
    return _LostRow(
      id: m['id']?.toString() ?? '',
      workspaceId: m['workspaceId']?.toString() ?? '',
      description: m['description']?.toString() ?? '',
      reportedAt: reported,
      expiresAt: exp,
    );
  }
}

/// Figma / React `LostFound.tsx` — bilgi kutusu, rapor, harita, liste.
class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  bool _showMap = false;
  late List<_LostRow> _items;
  final _lostFoundApi = LostFoundApi();
  bool _loadingList = true;
  bool _listFromFallback = false;

  static const List<_LostRow> _mockRows = [
    _LostRow(
      id: 'lost-1',
      workspaceId: 'desk-8',
      description: 'Black phone charger (USB-C)',
      reportedAt: '2026-03-10T14:30:00',
      expiresAt: '2026-03-11T14:30:00',
    ),
    _LostRow(
      id: 'lost-2',
      workspaceId: 'group-2',
      description: 'Blue notebook - Algorithms notes',
      reportedAt: '2026-03-10T11:00:00',
      expiresAt: '2026-03-11T11:00:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _items = [];
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loadingList = true;
      _listFromFallback = false;
    });
    try {
      final raw = await _lostFoundApi.getLostItems();
      final mapped = raw.map((e) => _LostRow.fromApi(Map<String, dynamic>.from(e))).toList();
      if (!mounted) return;
      setState(() {
        _items = mapped.isNotEmpty ? mapped : List.of(_mockRows);
        _listFromFallback = mapped.isEmpty;
        _loadingList = false;
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _items = List.of(_mockRows);
        _listFromFallback = true;
        _loadingList = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = List.of(_mockRows);
        _listFromFallback = true;
        _loadingList = false;
      });
    }
  }

  bool _hasLost(String workspaceId) => _items.any((e) => e.workspaceId == workspaceId);

  String _timeRemaining(String expiresAt) {
    final now = DateTime.now();
    final expires = DateTime.tryParse(expiresAt.replaceFirst(' ', 'T'));
    if (expires == null) return '—';
    final h = expires.difference(now).inHours;
    return h > 0 ? '${h}h left' : 'Expired';
  }

  void _openReport() {
    var workspace = ReservationMockData.workspaces.first.id;
    final descCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Report item', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  DropdownButton<String>(
                    value: workspace,
                    isExpanded: true,
                    hint: const Text('Workspace'),
                    items: ReservationMockData.workspaces
                        .map((w) => DropdownMenuItem(value: w.id, child: Text(w.id)))
                        .toList(),
                    onChanged: (v) => setModalState(() => workspace = v ?? workspace),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      if (descCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
                        return;
                      }
                      try {
                        await LostFoundApi().reportLostItem(
                          workspaceId: workspace,
                          description: descCtrl.text.trim(),
                        );
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item reported!')));
                        await _loadItems();
                      } on DioException {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('POST /lost-found failed — check backend')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Color _fill(Workspace ws) {
    if (_hasLost(ws.id)) return const Color(0xFFFBBF24);
    if (ws.status == 'occupied') return const Color(0xFFF87171);
    return const Color(0xFF60A5FA);
  }

  Color _stroke(Workspace ws) {
    if (_hasLost(ws.id)) return const Color(0xFFD97706);
    if (ws.status == 'occupied') return const Color(0xFFDC2626);
    return const Color(0xFF2563EB);
  }

  Widget _buildMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final h = maxW * (ReservationMockData.mapHeight / ReservationMockData.mapWidth);
        final sx = maxW / ReservationMockData.mapWidth;
        final sy = h / ReservationMockData.mapHeight;

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: maxW,
            height: h,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Individual Desks',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  ),
                ),
                Positioned(
                  top: 220 * sy,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Group Rooms',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  ),
                ),
                ...ReservationMockData.workspaces.map((ws) {
                  final w = (ws.type == 'individual' ? 35 : 70) * sx;
                  final hi = (ws.type == 'individual' ? 50 : 100) * sy;
                  final lost = _hasLost(ws.id);
                  return Positioned(
                    left: ws.x * sx,
                    top: ws.y * sy,
                    width: w,
                    height: hi,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _fill(ws),
                        borderRadius: BorderRadius.circular(ws.type == 'individual' ? 3 : 6),
                        border: Border.all(color: _stroke(ws), width: 2),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: ws.type == 'individual'
                                ? Text(
                                    ws.id.split('-').last,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(ws.id,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
                                      Text('Cap: ${ws.capacity}', style: const TextStyle(color: Colors.white, fontSize: 9)),
                                    ],
                                  ),
                          ),
                          if (lost)
                            Positioned(
                              right: 4 * sx,
                              top: 4 * sy,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.maybePop(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lost & Found', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                          const Text('Report and find lost items', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reload',
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _loadingList ? null : _loadItems,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFCE8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE047)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How It Works', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            SizedBox(height: 4),
                            Text(
                              '• Report items after your session\n• Items marked on map (yellow)\n• Auto-expire after 24 hours',
                              style: TextStyle(fontSize: 10, height: 1.4, color: Color(0xFF854D0E)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _openReport,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Report Item', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF9333EA),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => setState(() => _showMap = !_showMap),
                        icon: Icon(_showMap ? Icons.map_outlined : Icons.map_rounded, size: 18),
                        label: Text(_showMap ? 'Hide Map' : 'Show Map', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
                if (_showMap) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Map View', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _legendMini(const Color(0xFF60A5FA), const Color(0xFF2563EB), 'Free'),
                            _legendMini(const Color(0xFFF87171), const Color(0xFFDC2626), 'Busy'),
                            _legendMini(const Color(0xFFFBBF24), const Color(0xFFD97706), 'Lost Item'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildMap(),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Recent reports', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 8),
                if (_loadingList)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ..._items.map(
                  (e) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFEF3C7),
                        child: Icon(Icons.inventory_2_outlined, color: Color(0xFFD97706), size: 20),
                      ),
                      title: Text(e.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      subtitle: Text('${e.workspaceId} • ${_timeRemaining(e.expiresAt)}',
                          style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _legendMini(Color fill, Color stroke, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: stroke, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
      ],
    );
  }
}
