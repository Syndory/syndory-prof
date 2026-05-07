import '../../../data/supabase/supabase_client.dart';
import '../../../data/models/seance_model.dart';

class CalendarRepository {
  static Future<List<SeanceModel>> getSessionsForDate(DateTime date) async {
    final client = SupabaseClientProvider.client;
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Non authentifié');

    final dateStr = date.toIso8601String().split('T')[0];

    final response = await client
        .from('seances')
        .select('*, matieres(name), classes(name), salles(name)')
        .eq('professor_id', user.id)
        .eq('date', dateStr)
        .eq('status', 'publié')
        .order('start_time');

    return (response as List)
        .map((e) => SeanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
