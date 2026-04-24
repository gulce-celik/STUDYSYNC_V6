import '../../../core/network/api_client.dart';
import 'registration_mock_data.dart';

class ReferenceApi {
  Future<List<RegistrationDepartment>> getDepartments() async {
    final response = await ApiClient.instance.dio.get<List<dynamic>>('/reference/departments');
    final raw = response.data ?? const [];
    return raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return RegistrationDepartment(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
      );
    }).where((d) => d.id.isNotEmpty && d.name.isNotEmpty).toList();
  }
}
