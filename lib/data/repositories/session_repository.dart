import 'dart:convert';
import '../supabase/supabase_client.dart';

class SessionRepository {
  static Future<Map<String, dynamic>> openSession({
    required String seanceId,
    required double lat,
    required double lng,
    int markingWindowDuration = 15,
  }) async {
    final response = await SupabaseClientProvider.callEdgeFunction(
      'open-session',
      body: {
        'seance_id': seanceId,
        'gps_lat': lat,
        'gps_long': lng,
        'marking_window_duration': markingWindowDuration,
      },
    );

    if (response.status >= 200 && response.status < 300) {
      return jsonDecode(response.data as String) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.data as String) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Erreur lors de l\'ouverture de la session');
    }
  }

  static Future<Map<String, dynamic>> closeSession(String sessionId) async {
    final response = await SupabaseClientProvider.callEdgeFunction(
      'close-session',
      body: {
        'session_id': sessionId,
      },
    );

    if (response.status >= 200 && response.status < 300) {
      return jsonDecode(response.data as String) as Map<String, dynamic>;
    } else {
      final errorData = jsonDecode(response.data as String) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Erreur lors de la clôture de la session');
    }
  }
}
