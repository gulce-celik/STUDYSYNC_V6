import '../../../core/network/api_client.dart';

class CourseApi {
  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await ApiClient.instance.dio.get('/courses');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> rateCourse({
    required String courseCode,
    required int rating,
  }) async {
    final response = await ApiClient.instance.dio.post(
      '/courses/$courseCode/rating',
      data: {'rating': rating},
    );
    return response.data as Map<String, dynamic>;
  }
}
