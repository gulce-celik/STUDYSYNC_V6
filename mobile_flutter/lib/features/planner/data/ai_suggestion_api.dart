import '../../../core/network/api_client.dart';

class AiSuggestionsPayload {
  AiSuggestionsPayload({
    required this.reserveSuggestions,
    required this.buddySuggestion,
    required this.source,
  });

  final List<Map<String, dynamic>> reserveSuggestions;
  final Map<String, dynamic>? buddySuggestion;
  final String source;
}

class AiSuggestionApi {
  Future<AiSuggestionsPayload> getSuggestions() async {
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>('/ai/suggestions');
    final data = response.data ?? {};
    final reserveRaw = data['reserveSuggestions'];
    final reserve = reserveRaw is List
        ? reserveRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];
    final buddyRaw = data['buddySuggestion'];
    final buddy = buddyRaw is Map ? Map<String, dynamic>.from(buddyRaw) : null;
    return AiSuggestionsPayload(
      reserveSuggestions: reserve,
      buddySuggestion: buddy,
      source: data['source']?.toString() ?? 'unknown',
    );
  }
}
