import '../../../core/network/api_client.dart';

class StudyBuddyApi {
  Future<List<Map<String, dynamic>>> getSuggestions({
    required String courseCode,
    required String slotId,
  }) async {
    final response = await ApiClient.instance.dio.get(
      '/study-buddies/suggestions',
      queryParameters: {'courseCode': courseCode, 'slotId': slotId},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
