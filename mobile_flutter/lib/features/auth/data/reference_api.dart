import '../../../core/network/api_client.dart';
import 'registration_mock_data.dart';

class ReferenceApi {
  Future<List<RegistrationDepartment>> getDepartments() async { // future is used to return a value later. Like promise
    final response = await ApiClient.instance.dio.get<List<dynamic>>('/reference/departments'); // API call to get the departments
    final raw = response.data ?? const [];
    return raw.map((e) { // map is used to iterate over the list and return a new list.
      final m = Map<String, dynamic>.from(e as Map);
      return RegistrationDepartment( // RegistrationDepartment is a class that is used to store the department information. 
        id: m['id']?.toString() ?? '', // permanent key for the departmen
        name: m['name']?.toString() ?? '',
      );
    }).where((d) => d.id.isNotEmpty && d.name.isNotEmpty).toList();
  }
}
