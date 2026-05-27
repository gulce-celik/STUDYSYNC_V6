import '../../../core/network/api_client.dart';

class GuidedChatResponse {
  GuidedChatResponse({
    required this.message,
    required this.source,
    required this.topic,
    required this.courseCode,
  });

  final String message;
  final String source;
  final String topic;
  final String courseCode;

  factory GuidedChatResponse.fromJson(Map<String, dynamic> json) {
    return GuidedChatResponse(
      message: json['message']?.toString() ?? '',
      source: json['source']?.toString() ?? 'unknown',
      topic: json['topic']?.toString() ?? '',
      courseCode: json['courseCode']?.toString() ?? '',
    );
  }
}

class GuidedChatCourseOption {
  const GuidedChatCourseOption({required this.code, required this.name});

  final String code;
  final String name;

  factory GuidedChatCourseOption.fromJson(Map<String, dynamic> json) {
    return GuidedChatCourseOption(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class GuidedChatApi {
  /// Backend catalog ∩ (your schedule ∪ enrolled courses), with official names.
  Future<List<GuidedChatCourseOption>> fetchAllowedCourses() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      '/ai/guided-chat/courses',
    );
    final raw = response.data?['courses'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => GuidedChatCourseOption.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.code.isNotEmpty)
        .toList();
  }

  Future<GuidedChatResponse> ask({
    required String courseCode,
    required String topic,
  }) async {
    final response = await ApiClient.instance.dio.post<Map<String, dynamic>>(
      '/ai/guided-chat',
      data: {
        'courseCode': courseCode,
        'topic': topic,
      },
    );
    return GuidedChatResponse.fromJson(response.data ?? {});
  }
}
