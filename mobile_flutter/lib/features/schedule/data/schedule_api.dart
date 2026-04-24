import '../../../core/network/api_client.dart';
import 'schedule_mock_data.dart';

class ScheduleApi {
  /// [GET /schedule/weekly] → `{ "blocks": [...] }`
  Future<List<ScheduleBlock>> getWeekly() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>('/schedule/weekly');
    final root = response.data ?? {};
    final raw = root['blocks'];
    if (raw is! List) return [];
    final out = <ScheduleBlock>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final b = ScheduleBlockMapper.fromApi(m);
      if (b != null) out.add(b);
    }
    return out;
  }

  /// [PUT /schedule/weekly] — gövde: `{ "blocks": [...] }`
  Future<Map<String, dynamic>> putWeekly(List<ScheduleBlock> blocks) async {
    final response = await ApiClient.instance.dio.put<Map<String, dynamic>>(
      '/schedule/weekly',
      data: {
        'blocks': blocks.map(ScheduleBlockMapper.toApi).toList(),
      },
    );
    return response.data ?? {};
  }
}
